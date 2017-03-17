//
//  RTSPClientView.h
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/17.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

struct sockaddr_in;

@interface RTSPClientView : UIImageView
{
    volatile int need_to_closed;
    volatile int rtsp_conn_status;
    NSString* rtsp_url;
    UIImage* video_image;
    
    int pause_flag;
    
    int sock;
    struct sockaddr_in* rtsp_addr;
    int rtsp_addr_len;
    
    CGFloat init_width, init_height; // init size.
}

- (void)rtsp_open:(NSString*) url;
- (void)rtsp_open;
- (void)rtsp_close;
- (int)conn_status; // 1, connected; 0, disconnected; -1, connecting.

- (int)turn_up;
- (int)turn_down;
- (int)turn_left;
- (int)turn_right;
- (int)turn_loop;
- (int)turn_stop;

- (void)play_start;
- (void)play_pause;

- (NSString*)get_rtsp_url;

@end

