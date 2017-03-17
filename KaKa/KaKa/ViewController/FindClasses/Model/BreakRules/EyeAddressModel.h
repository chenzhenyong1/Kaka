//
//  EyeAddressModel.h
//  KakaFind
//
//  Created by 陈振勇 on 16/8/16.
//  Copyright © 2016年 陈振勇. All rights reserved.
//  违章地理信息

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface EyeAddressModel : NSObject

/** 违章地点 */
@property (nonatomic, copy) NSString *address;

/** 违章的经纬度  */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
