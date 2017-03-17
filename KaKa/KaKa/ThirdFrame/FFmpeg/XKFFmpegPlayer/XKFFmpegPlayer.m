#import "XKFFmpegPlayer.h"

#import "KxMovieDecoder.h"
#import "KxAudioManager.h"

#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
#include "libavutil/pixdesc.h"

#define MIN_BUFFERED_DURATION       0.0
#define MAX_BUFFERED_DURATION       4.0

@interface XKFFmpegPlayer ()

@property (nonatomic) KxMovieDecoder *decoder;
@property (nonatomic) dispatch_queue_t dispatchQueue;

@property (nonatomic) BOOL decoding;
@property (nonatomic) BOOL interrupted;

@property (nonatomic) NSMutableArray *videoFrames;
@property (nonatomic) CGFloat moviePosition;

@property (nonatomic) NSMutableArray *audioFrames;
@property (nonatomic) NSData *currentAudioFrame;
@property (nonatomic) NSUInteger currentAudioFramePos;

@property (nonatomic) CGFloat bufferedDuration;
@property (nonatomic) BOOL buffered;

@property (nonatomic) NSTimeInterval tickCorrectionTime;
@property (nonatomic) NSTimeInterval tickCorrectionPosition;
@property (nonatomic) NSUInteger tickCounter;

@end

@implementation XKFFmpegPlayer

- (void)dealloc {
    _delegate = nil;
    self.decoder = nil;
}

+ (UIImage *)takeSnapshot:(NSURL *)url {
    
    av_register_all();
    avformat_network_init();
    
    AVFormatContext *formatCtx = avformat_alloc_context();
    
    if (avformat_open_input(&formatCtx, [url.absoluteString cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL) < 0) {
        
        if (formatCtx) {
            avformat_free_context(formatCtx);
        }
        
        return nil;
    }
    
    if (avformat_find_stream_info(formatCtx, NULL) < 0) {
        
        avformat_close_input(&formatCtx);
        return nil;
    }
    
    //
    
    AVFrame *videoFrame = NULL;
    AVCodecContext *videoCodecCtx = NULL;
    NSInteger videoStream = -1;
    
    for (int i = 0; i < formatCtx->nb_streams; i++) {
        if (formatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO) {
            if ((formatCtx->streams[i]->disposition & AV_DISPOSITION_ATTACHED_PIC) == 0) {
                
                // get a pointer to the codec context for the video stream
                AVCodecContext *codecCtx = formatCtx->streams[i]->codec;
                
                // find the decoder for the video stream
                AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
                if (!codec) {
                    if (formatCtx) {
                        avformat_close_input(&formatCtx);
                        formatCtx = NULL;
                    }
                    
                    return nil;
                }
                
                // open codec
                if (avcodec_open2(codecCtx, codec, NULL) < 0) {
                    if (formatCtx) {
                        avformat_close_input(&formatCtx);
                        formatCtx = NULL;
                    }
                    
                    return nil;
                }
                
                videoFrame = av_frame_alloc();
                
                if (!videoFrame) {
                    avcodec_close(codecCtx);
                    
                    if (formatCtx) {
                        avformat_close_input(&formatCtx);
                        formatCtx = NULL;
                    }
                    
                    return nil;
                }
                
                videoCodecCtx = codecCtx;
                videoStream = i;
                
                break;
            }
        }
    }
    
    //
    
    AVPacket packet;
    
    BOOL finished = NO;
    
    AVPicture picture;
    struct SwsContext *swsContext = NULL;
    
    NSUInteger linesize = 0;
    NSData *rgb;
    
    int width = 0;
    int height = 0;
    
    while (!finished) {
        
        if (av_read_frame(formatCtx, &packet) < 0) {
            break;
        }
        
        if (packet.stream_index == videoStream) {
            
            int pktSize = packet.size;
            
            while (pktSize > 0) {
                
                int gotframe = 0;
                int len = avcodec_decode_video2(videoCodecCtx,
                                                videoFrame,
                                                &gotframe,
                                                &packet);
                
                if (len < 0) {
                    break;
                }
                
                if (gotframe) {
                    
                    //
                    
                    if (avpicture_alloc(&picture,
                                        AV_PIX_FMT_RGB24,
                                        videoCodecCtx->width,
                                        videoCodecCtx->height) < 0) {
                        
                        if (videoFrame) {
                            
                            av_free(videoFrame);
                            videoFrame = NULL;
                        }
                        
                        if (videoCodecCtx) {
                            
                            avcodec_close(videoCodecCtx);
                            videoCodecCtx = NULL;
                        }
                        
                        if (formatCtx) {
                            avformat_close_input(&formatCtx);
                            formatCtx = NULL;
                        }
                        
                        return nil;
                    }
                    
                    swsContext = sws_getCachedContext(swsContext,
                                                      videoCodecCtx->width,
                                                      videoCodecCtx->height,
                                                      videoCodecCtx->pix_fmt,
                                                      videoCodecCtx->width,
                                                      videoCodecCtx->height,
                                                      AV_PIX_FMT_RGB24,
                                                      SWS_FAST_BILINEAR,
                                                      NULL, NULL, NULL);
                    
                    if (!swsContext) {
                        
                        avpicture_free(&picture);
                        
                        if (videoFrame) {
                            
                            av_free(videoFrame);
                            videoFrame = NULL;
                        }
                        
                        if (videoCodecCtx) {
                            
                            avcodec_close(videoCodecCtx);
                            videoCodecCtx = NULL;
                        }
                        
                        if (formatCtx) {
                            avformat_close_input(&formatCtx);
                            formatCtx = NULL;
                        }
                        
                        return nil;
                    }
                    
                    //
                    
                    sws_scale(swsContext,
                              (const uint8_t **)videoFrame->data,
                              videoFrame->linesize,
                              0,
                              videoCodecCtx->height,
                              picture.data,
                              picture.linesize);
                    
                    linesize = picture.linesize[0];
                    rgb = [NSData dataWithBytes:picture.data[0]
                                         length:linesize * videoCodecCtx->height];
                    
                    width = videoCodecCtx->width;
                    height = videoCodecCtx->height;
                    
                    finished = YES;
                }
                
                if (len == 0)
                    break;
                
                pktSize -= len;
            }
        }
        
        av_free_packet(&packet);
    }
    
    UIImage *image = nil;
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(rgb));
    if (provider) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace) {
            CGImageRef imageRef = CGImageCreate(width,
                                                height,
                                                8,
                                                24,
                                                linesize,
                                                colorSpace,
                                                kCGBitmapByteOrderDefault,
                                                provider,
                                                NULL,
                                                YES,
                                                kCGRenderingIntentDefault);
            
            if (imageRef) {
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
            CGColorSpaceRelease(colorSpace);
        }
        CGDataProviderRelease(provider);
    }
    
    //
    
    videoStream = -1;
    
    if (swsContext) {
        sws_freeContext(swsContext);
        swsContext = NULL;
    }
    
    avpicture_free(&picture);
    
    if (videoFrame) {
        
        av_free(videoFrame);
        videoFrame = NULL;
    }
    
    if (videoCodecCtx) {
        
        avcodec_close(videoCodecCtx);
        videoCodecCtx = NULL;
    }
    
    if (formatCtx) {
        avformat_close_input(&formatCtx);
        formatCtx = NULL;
    }
    
    return image;
}

- (void)setOutputWidth:(int)outputWidth {
    _outputWidth = outputWidth;
}

- (void)setOutputHeight:(int)outputHeight {
    _outputHeight = outputHeight;
}

- (NSString *)path {
    return self.decoder.path;
}

- (BOOL)isEOF {
    return self.decoder.isEOF;
}

- (void)closeFile {
    if (self.decoder) {
        [self stop];
        [self.decoder closeFile];
    }
}

- (void)load:(NSString *)path
    delegate:(id<XKFFmpegPlayerDelegate>)delegate
{
    self.delegate = delegate;
    
    self.paused = YES;
    
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    [audioManager activateAudioSession];
    
    self.decoder = [[KxMovieDecoder alloc] init];
    self.decoder.outputHeight = _outputHeight;
    self.decoder.outputWidth = _outputWidth;
    
    self.videoFrames = [NSMutableArray array];
    self.audioFrames = [NSMutableArray array];
    
    __weak typeof(self) welf = self;
    
    self.decoder.interruptCallback = ^BOOL() {
        if (welf)
            return welf.interrupted;
        
        return YES;
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        [welf.decoder openFile:path
                         error:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!error)
            {
                welf.dispatchQueue = dispatch_queue_create("com.ffmpegplayer.player", DISPATCH_QUEUE_SERIAL);
                [welf.decoder setupVideoFrameFormat:KxVideoFrameFormatRGB];
                [welf play];
            }
            else if (welf.delegate && [welf.delegate respondsToSelector:@selector(failed:)])
                [welf.delegate failed:error];
        });
    });
}

- (void)play
{
    if (!self.paused)
        return;
    
    if (!(self.decoder.validVideo || self.decoder.validAudio))
        return;
    
    if (self.interrupted)
        return;
    
    self.paused = NO;
    self.interrupted = NO;
    self.tickCorrectionTime = 0;
    self.tickCounter = 0;
    
    [self asyncDecodeFrames];
    
    __weak typeof(self) welf = self;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [welf tick];
    });
    
    if (self.decoder.validAudio)
        [self mute:NO];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playing)]) {
        [self.delegate playing];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

- (void)pause
{
    if (self.paused)
        return;
    
    self.paused = YES;
    [self mute:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(paused)]) {
        [self.delegate paused];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

- (void)stop
{
    [self pause];
    self.interrupted = YES;
    [self freeBufferedFrames];
    
    if (self.dispatchQueue)
        self.dispatchQueue = nil;
}

- (void)mute:(BOOL)onOff
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    
    if (!onOff && self.decoder.validAudio)
    {
        __weak typeof(self) welf = self;
    
        audioManager.outputBlock = ^(float *data, UInt32 numFrames, UInt32 numChannels) {
            [welf audioCallbackFillData:data
                              numFrames:numFrames
                            numChannels:(int)numChannels];
        };
        
        [audioManager play];
    }
    else
    {
        [audioManager pause];
        audioManager.outputBlock = nil;
    }
}

- (void)seek:(float)position
{
    BOOL paused = self.paused;
    [self pause];
    
    __weak typeof(self) welf = self;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [welf updatePosition:position * welf.decoder.duration
                      paused:paused];
    });
}

#pragma mark - Internal

- (void)asyncDecodeFrames
{
    if (self.decoding)
        return;
    
    __weak typeof(self) welf = self;
    
    CGFloat duration = 0.0;
    
    self.decoding = YES;
    if (self.dispatchQueue == nil) {
        return;
    }
    dispatch_async(self.dispatchQueue, ^{
        if (welf.paused)
            return;
        
        BOOL good = YES;
        while (good)
        {
            good = NO;
            @autoreleasepool
            {
                if (welf && welf.decoder && (welf.decoder.validVideo || welf.decoder.validAudio))
                {
                    NSArray *frames = [welf.decoder decodeFrames:duration];
                    if (frames.count)
                        if (welf)
                            good = [welf addFrames:frames];
                }
            }
        }
        
        if (welf)
            welf.decoding = NO;
    });
}

- (BOOL)addFrames:(NSArray *)frames
{
    if (self.decoder.validVideo)
    {
        @synchronized(self.videoFrames)
        {
            for (KxMovieFrame *frame in frames)
            {
                if (frame.type == KxMovieFrameTypeVideo)
                {
                    [self.videoFrames addObject:frame];
                    self.bufferedDuration += frame.duration;
                }
            }
        }
    }
    
    if (self.decoder.validAudio)
    {
        @synchronized(self.audioFrames)
        {
            for (KxMovieFrame *frame in frames)
            {
                if (frame.type == KxMovieFrameTypeAudio)
                {
                    [self.audioFrames addObject:frame];
                    if (!self.decoder.validVideo)
                        self.bufferedDuration += frame.duration;
                }
            }
        }
    }
    
    return !self.paused && self.bufferedDuration < MAX_BUFFERED_DURATION;
}

- (void)tick
{
    if (self.buffered && ((self.bufferedDuration > MIN_BUFFERED_DURATION) || self.decoder.isEOF))
    {
        self.tickCorrectionTime = 0;
        self.buffered = NO;
        if (self.delegate)
        {
            if (self.paused) {
                if ([self.delegate respondsToSelector:@selector(paused)]) {
                    [self.delegate paused];
                }
                [UIApplication sharedApplication].idleTimerDisabled = NO;
            }
            else {
                if ([self.delegate respondsToSelector:@selector(playing)]) {
                    [self.delegate playing];
                }
                [UIApplication sharedApplication].idleTimerDisabled = YES;
            }
        }
    }
    
    CGFloat interval = 0;
    if (!self.buffered)
        interval = [self presentFrame];
    
    if (!self.paused)
    {
        NSUInteger leftFrames = (self.decoder.validVideo ? self.videoFrames.count : 0) + (self.decoder.validAudio ? self.audioFrames.count : 0);
        
        if (leftFrames == 0)
        {
            if (self.decoder.isEOF)
            {
                [self pause];
                if (self.delegate && [self.delegate respondsToSelector:@selector(tick:duration:)])
                    [self.delegate tick:self.moviePosition - self.decoder.startTime
                               duration:self.decoder.duration];
                return;
            }
            
            if (MIN_BUFFERED_DURATION > 0 && !self.buffered)
            {
                self.buffered = YES;
                if (self.delegate && [self.delegate respondsToSelector:@selector(loading)])
                    [self.delegate loading];
            }
        }

        if (!leftFrames || !(self.bufferedDuration > MIN_BUFFERED_DURATION))
            [self asyncDecodeFrames];
        
        NSTimeInterval correction = [self tickCorrection];
        NSTimeInterval time = MAX(interval + correction, 0.01);
        
        __weak typeof(self) welf = self;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [welf tick];
        });
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tick:duration:)])
        [self.delegate tick:self.moviePosition - self.decoder.startTime
                   duration:self.decoder.duration];
}

- (CGFloat)tickCorrection
{
    if (self.buffered)
        return 0;
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!self.tickCorrectionTime)
    {
        self.tickCorrectionTime = now;
        self.tickCorrectionPosition = self.moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = self.moviePosition - self.tickCorrectionPosition;
    NSTimeInterval dTime = now - self.tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    if (correction > 1.0 || correction < -1.0)
    {
        correction = 0;
        self.tickCorrectionTime = 0;
    }
    
    return correction;
}

- (CGFloat)presentFrame
{
    CGFloat interval = 0;
    
    if (self.decoder.validVideo)
    {
        KxVideoFrame *frame;
        
        @synchronized(self.videoFrames)
        {
            if (self.videoFrames.count > 0)
            {
                frame = self.videoFrames[0];
                [self.videoFrames removeObjectAtIndex:0];
                self.bufferedDuration -= frame.duration;
            }
        }
        
        if (frame)
            interval = [self presentVideoFrame:frame];
    }
    
    return interval;
}

- (CGFloat)presentVideoFrame:(KxVideoFrame *)frame
{
    KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB *)frame;
    
    if (self.delegate) {
        UIImage *image = nil;
        
        @try {
            image = [rgbFrame asImage];
        } @catch (NSException *exception) {
            image = nil;
        }
        
        if ([self.delegate respondsToSelector:@selector(presentFrame:)]) {
            [self.delegate presentFrame:image];
        }
        
    }
    
    self.moviePosition = frame.position;
    
    return frame.duration;
}

- (void)audioCallbackFillData:(float *)outData
                    numFrames:(int)numFrames
                  numChannels:(int)numChannels
{
    if (self.buffered)
    {
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }
    
    @autoreleasepool
    {
        while (numFrames > 0)
        {
            if (!self.currentAudioFrame)
            {
                @synchronized(self.audioFrames)
                {
                    NSUInteger count = self.audioFrames.count;
                    
                    if (count > 0)
                    {
                        KxAudioFrame *frame = self.audioFrames[0];
                        
                        if (self.decoder.validVideo)
                        {
                            CGFloat delta = self.moviePosition - frame.position;
                            
                            if (delta < -2.0)
                            {
                                memset(outData, 0, numFrames * numChannels * sizeof(float));
                                break;
                            }
                            
                            [self.audioFrames removeObjectAtIndex:0];
                            
                            if (delta > 2.0 && count > 1)
                                continue;
                        }
                        else
                        {
                            [self.audioFrames removeObjectAtIndex:0];
                            self.moviePosition = frame.position;
                            self.bufferedDuration -= frame.duration;
                        }
                        
                        self.currentAudioFramePos = 0;
                        self.currentAudioFrame = frame.samples;
                    }
                }
            }
            
            if (self.currentAudioFrame)
            {
                void *bytes = (Byte *)self.currentAudioFrame.bytes + self.currentAudioFramePos;
                NSUInteger bytesLeft = (self.currentAudioFrame.length - self.currentAudioFramePos);
                NSUInteger frameSizeOf = numChannels * sizeof(float);
                NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    self.currentAudioFramePos += bytesToCopy;
                else
                    self.currentAudioFrame = nil;
            }
            else
            {
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                break;
            }
        }
    }
}

- (void)updatePosition:(CGFloat)position
                paused:(BOOL)paused
{
    [self freeBufferedFrames];
    
    position = MIN(self.decoder.duration - 1, MAX(0, position));
    
    __weak typeof(self) welf = self;
    
    dispatch_async(self.dispatchQueue, ^{
        if (!welf)
            return;
        
        welf.decoder.position = position;
        
        if (!paused)
        {
            [welf decodeFrames];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (welf)
                {
                    welf.moviePosition = welf.decoder.position;
                    [welf presentFrame];
                    if (welf.delegate && [welf.delegate respondsToSelector:@selector(tick:duration:)])
                        [welf.delegate tick:welf.moviePosition - welf.decoder.startTime
                                   duration:welf.decoder.duration];
                    [welf play];
                }
            });
        }
        else
        {
            [welf decodeFrames];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (welf)
                {
                    welf.moviePosition = welf.decoder.position;
                    [welf presentFrame];
                    if (welf.delegate && [welf.delegate respondsToSelector:@selector(tick:duration:)])
                        [welf.delegate tick:welf.moviePosition - welf.decoder.startTime
                                   duration:welf.decoder.duration];
                }
            });
        }        
    });
}

- (void)freeBufferedFrames
{
    @synchronized(self.videoFrames)
    {
        [_videoFrames removeAllObjects];
    }
    
    @synchronized(self.audioFrames)
    {
        [self.audioFrames removeAllObjects];
        self.currentAudioFrame = nil;
    }
    
    self.bufferedDuration = 0;
}

- (BOOL)decodeFrames
{
    NSArray *frames = nil;
    
    if (self.decoder.validVideo || self.decoder.validAudio)
        frames = [self.decoder decodeFrames:0];
    
    if (frames.count)
        return [self addFrames:frames];
    
    return NO;
}

@end

@implementation XKFFmpegPlayerView

@end
