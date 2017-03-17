//
//  EyeAnno.h
//  KakaFind
//
//  Created by 陈振勇 on 16/7/26.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface EyeAnno : NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
/** 类型 */
@property (nonatomic, assign) NSInteger type;
@end
