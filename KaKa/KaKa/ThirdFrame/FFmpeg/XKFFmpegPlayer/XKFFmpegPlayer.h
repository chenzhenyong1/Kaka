#import <UIKit/UIKit.h>

@protocol XKFFmpegPlayerDelegate;

@interface XKFFmpegPlayer : NSObject

+ (UIImage *)takeSnapshot:(NSURL *)url;

/* Output image size. Set to the source size by default. */
@property (nonatomic) BOOL paused;
@property (readonly, nonatomic) BOOL isEOF;
/* Output image size. Set to the source size by default. */
@property (nonatomic) int outputWidth, outputHeight;

@property (readonly, nonatomic, strong) NSString *path;

@property (weak, nonatomic) id<XKFFmpegPlayerDelegate> delegate;

- (void)load:(NSString *)path
    delegate:(id<XKFFmpegPlayerDelegate>)delegate;

- (void)play;
- (void)pause;
- (void)stop;

-(void)closeFile;

- (void)mute:(BOOL)onOff;
- (void)seek:(float)position;

@end

@interface XKFFmpegPlayerView : UIImageView

@property (nonatomic) XKFFmpegPlayer *player;

@end

@protocol XKFFmpegPlayerDelegate <NSObject>

- (void)loading;
- (void)failed:(NSError *)error;

- (void)playing;
- (void)paused;

- (void)tick:(float)position
    duration:(float)duration;

- (void)presentFrame:(UIImage *)image;

@end
