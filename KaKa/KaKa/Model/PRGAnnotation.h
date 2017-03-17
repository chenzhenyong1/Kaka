//
//  PRGAnnotation.h
//  YunAnJia
//
//  Created by Change_pan on 16/3/9.
//  Copyright © 2016年 com.showsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
@interface PRGAnnotation : NSObject<BMKAnnotation>

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *adviser_id;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *now__address;
@property (nonatomic, copy) NSString *p;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *photo;
@property (nonatomic, copy) NSString *professional;
@property (nonatomic, copy) NSString *weight;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *type;//0 表示开始  1 表示其他  2 表示结束

@property (nonatomic, copy) NSString *time;//游记时间

@end
