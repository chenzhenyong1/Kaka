#import "RTSPPlayer.h"
#import "Utilities.h"
#import "AudioStreamer.h"

@interface RTSPPlayer ()
@property (nonatomic, retain) AudioStreamer *audioController;

@property (nonatomic, retain) NSDate *lastReadDate;
@end

@interface RTSPPlayer (private)
-(void)convertFrameToRGB;
-(UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height;
-(void)savePicture:(AVPicture)pFrame width:(int)width height:(int)height index:(int)iFrame;
-(void)setupScaler;
@end

@implementation RTSPPlayer

@synthesize audioController = _audioController;
@synthesize audioPacketQueue,audioPacketQueueSize;
@synthesize _audioStream, audioCodecContext;
@synthesize emptyAudioBuffer;

@synthesize outputWidth, outputHeight;

- (void)setOutputWidth:(int)newValue
{
    if (outputWidth != newValue) {
        outputWidth = newValue;
        [self setupScaler];
    }
}

- (void)setOutputHeight:(int)newValue
{
    if (outputHeight != newValue) {
        outputHeight = newValue;
        [self setupScaler];
    }
}

- (UIImage *)currentImage
{
    if (!pFrame->data[0]) return nil;
    [self convertFrameToRGB];
    return [self imageFromAVPicture:picture width:outputWidth height:outputHeight];
}

- (double)duration
{
    return (double)pFormatCtx->duration / AV_TIME_BASE;
}

- (double)currentTime
{
    AVRational timeBase = pFormatCtx->streams[videoStream]->time_base;
    return packet.pts * (double)timeBase.num / timeBase.den;
}

- (int)sourceWidth
{
    return pCodecCtx->width;
}

- (int)sourceHeight
{
    return pCodecCtx->height;
}

- (id)initWithVideo:(NSString *)moviePath usesTcp:(BOOL)usesTcp
{
    _moviePath = moviePath;
    
    if (!(self=[super init])) return nil;
    
    AVCodec         *pCodec;
    
    // Register all formats and codecs
    
    avcodec_register_all();
    av_register_all();
    avformat_network_init();
    
    // Set the RTSP Options
    AVDictionary *opts = 0;
    if (usesTcp)
        av_dict_set(&opts, "rtsp_transport", "tcp", 0);
    
    pFormatCtx = avformat_alloc_context();
    AVIOInterruptCB cb = {interrupt_callback, (__bridge void *)(self)};
    pFormatCtx->interrupt_callback = cb;
    
    if (avformat_open_input(&pFormatCtx, [moviePath UTF8String], NULL, &opts) !=0 ) {
        av_log(NULL, AV_LOG_ERROR, "Couldn't open file\n");
        goto initError;
    }
    // Retrieve stream information
    self.lastReadDate = [NSDate date];
    if (avformat_find_stream_info(pFormatCtx,NULL) < 0) {
        av_log(NULL, AV_LOG_ERROR, "Couldn't find stream information\n");
        goto initError;
    }
    
    
    // Find the first video stream
    videoStream=-1;
    audioStream=-1;
    
    for (int i=0; i<pFormatCtx->nb_streams; i++) {
        if (pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
            NSLog(@"found video stream");
            videoStream=i;
        }
        
        if (pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO) {
            audioStream=i;
            NSLog(@"found audio stream");
        }
    }
    
    if (videoStream==-1 && audioStream==-1) {
        goto initError;
    }
    
    // Get a pointer to the codec context for the video stream 得到一个指向视频编解码器的上下文
    pCodecCtx = pFormatCtx->streams[videoStream]->codec;
    
    // Find the decoder for the video stream 找到视频解码器
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    if (pCodec == NULL) {
        av_log(NULL, AV_LOG_ERROR, "Unsupported codec!\n");
        goto initError;
    }
    
    // Open codec
    if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0) {
        av_log(NULL, AV_LOG_ERROR, "Cannot open video decoder\n");
        goto initError;
    }
    
    if (audioStream > -1 ) {
        NSLog(@"set up audiodecoder");
        [self setupAudioDecoder];
    }
    
    // Allocate video frame  分配视频帧
    pFrame = av_frame_alloc();
    
    outputWidth = pCodecCtx->width;
    self.outputHeight = pCodecCtx->height;
    NSLog(@"width = %d  === height = %d",pCodecCtx->width,pCodecCtx->height);
    return self;
    
initError:
    return nil;
}

static int interrupt_callback(void *ctx)
{
    if (!ctx)
        return 0;
    __unsafe_unretained RTSPPlayer *p = (__bridge RTSPPlayer *)ctx;
    NSDate *now = [NSDate date];
    if (p.lastReadDate) {
        NSTimeInterval timeInterval = [now timeIntervalSinceDate:p.lastReadDate];
        if (timeInterval >= 0.5) {
            return 1;
        }
    }

    return 0;
}


- (void)setupScaler
{
    // Release old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    // Allocate RGB picture
    avpicture_alloc(&picture, PIX_FMT_RGB24, outputWidth, outputHeight);
    
    // Setup scaler
    static int sws_flags =  SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(pCodecCtx->width,
                                     pCodecCtx->height,
                                     pCodecCtx->pix_fmt,
                                     outputWidth,
                                     outputHeight,
                                     PIX_FMT_RGB24,
                                     sws_flags, NULL, NULL, NULL);
    
}

- (void)seekTime:(double)seconds
{
    AVRational timeBase = pFormatCtx->streams[videoStream]->time_base;
    int64_t targetFrame = (int64_t)((double)timeBase.den / timeBase.num * seconds);
    avformat_seek_file(pFormatCtx, videoStream, targetFrame, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(pCodecCtx);
}

- (void)dealloc
{
    // Free scaler
    sws_freeContext(img_convert_ctx);
    
    // Free RGB picture
    avpicture_free(&picture);
    
    // Free the packet that was allocated by av_read_frame
    av_free_packet(&packet);
    
    // Free the YUV frame
    av_free(pFrame);
    
    // Close the codec
    if (pCodecCtx) avcodec_close(pCodecCtx);
    
    // Close the video file
    if (pFormatCtx) {
        pFormatCtx->interrupt_callback.opaque = NULL;
        pFormatCtx->interrupt_callback.callback = NULL;
        avformat_close_input(&pFormatCtx);
        pFormatCtx = NULL;
    }
    
    [_audioController _stopAudio];
    _audioController = nil;
    
    audioPacketQueue = nil;
    
    audioPacketQueueLock = nil;
}

- (BOOL)stepFrame
{
    // AVPacket packet;
    int frameFinished=0;
    self.lastReadDate = [NSDate date];
    while (!frameFinished && av_read_frame(pFormatCtx, &packet) >=0 ) {
        // Is this a packet from the video stream?
        if(packet.stream_index==videoStream) {
            // Decode video frame
            avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
        }
        
        if (packet.stream_index==audioStream) {
            // NSLog(@"audio stream");
            [audioPacketQueueLock lock];
            
            audioPacketQueueSize += packet.size;
            [audioPacketQueue addObject:[NSMutableData dataWithBytes:&packet length:sizeof(packet)]];
            
            [audioPacketQueueLock unlock];
            
            if (!primed) {
                primed=YES;
                [_audioController _startAudio];
            }
            
            if (emptyAudioBuffer) {
                [_audioController enqueueBuffer:emptyAudioBuffer];
            }
        }
        
        self.lastReadDate = [NSDate date];
    }
    
    return frameFinished!=0;
}

- (void)convertFrameToRGB
{
    sws_scale(img_convert_ctx,
              (const uint8_t *const *)pFrame->data,
              pFrame->linesize,
              0,
              pCodecCtx->height,
              picture.data,
              picture.linesize);
}

- (UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height
{
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       pict.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}

- (void)setupAudioDecoder
{
    if (audioStream >= 0) {
        _audioBufferSize = 192000;
        _audioBuffer = av_malloc(_audioBufferSize);
        _inBuffer = NO;
        
        audioCodecContext = pFormatCtx->streams[audioStream]->codec;
        _audioStream = pFormatCtx->streams[audioStream];
        
        AVCodec *codec = avcodec_find_decoder(audioCodecContext->codec_id);
        if (codec == NULL) {
            NSLog(@"Not found audio codec.");
            return;
        }
        
        if (avcodec_open2(audioCodecContext, codec, NULL) < 0) {
            NSLog(@"Could not open audio codec.");
            return;
        }
        
        if (audioPacketQueue) {
            audioPacketQueue = nil;
        }
        audioPacketQueue = [[NSMutableArray alloc] init];
        
        if (audioPacketQueueLock) {
            audioPacketQueueLock = nil;
        }
        audioPacketQueueLock = [[NSLock alloc] init];
        
        if (_audioController) {
            [_audioController _stopAudio];
            _audioController = nil;
        }
        _audioController = [[AudioStreamer alloc] initWithStreamer:self];
    } else {
        pFormatCtx->streams[audioStream]->discard = AVDISCARD_ALL;
        audioStream = -1;
    }
}

- (void)nextPacket
{
    _inBuffer = NO;
}

- (AVPacket*)readPacket
{
    if (_currentPacket.size > 0 || _inBuffer) return &_currentPacket;
    
    NSMutableData *packetData = [audioPacketQueue objectAtIndex:0];
    _packet = [packetData mutableBytes];
    
    if (_packet) {
        if (_packet->dts != AV_NOPTS_VALUE) {
            _packet->dts += av_rescale_q(0, AV_TIME_BASE_Q, _audioStream->time_base);
        }
        
        if (_packet->pts != AV_NOPTS_VALUE) {
            _packet->pts += av_rescale_q(0, AV_TIME_BASE_Q, _audioStream->time_base);
        }
        
        [audioPacketQueueLock lock];
        audioPacketQueueSize -= _packet->size;
        if ([audioPacketQueue count] > 0) {
            [audioPacketQueue removeObjectAtIndex:0];
        }
        [audioPacketQueueLock unlock];
        
        _currentPacket = *(_packet);
    }
    
    return &_currentPacket;
}

- (void)closeAudio
{
    [_audioController _stopAudio];
    primed=NO;
}

- (void)savePPMPicture:(AVPicture)pict width:(int)width height:(int)height index:(int)iFrame
{
    FILE *pFile;
    NSString *fileName;
    int  y;
    
    fileName = [Utilities documentsPath:[NSString stringWithFormat:@"image%04d.ppm",iFrame]];
    // Open file
    NSLog(@"write image file: %@",fileName);
    pFile=fopen([fileName cStringUsingEncoding:NSASCIIStringEncoding], "wb");
    if (pFile == NULL) {
        return;
    }
    
    // Write header
    fprintf(pFile, "P6\n%d %d\n255\n", width, height);
    
    // Write pixel data
    for (y=0; y<height; y++) {
        fwrite(pict.data[0]+y*pict.linesize[0], 1, width*3, pFile);
    }
    
    // Close file
    fclose(pFile);
}

@end
