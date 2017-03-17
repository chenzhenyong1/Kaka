//
//  FMDBTools.h
//  KaKa
//
//  Created by Change_pan on 16/8/17.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlbumsPathModel.h"
@interface FMDBTools : NSObject

#pragma mark - 收藏

/** 保存文件路径到数据库 */
+ (BOOL)saveContactsWithImageUrl:(NSString *)imageUrl type:(NSString *)type;

/** 获取文件路径 */
+ (NSMutableArray *)getImageUrlsFromDataBaseWithName:(NSString *)name;

/** 查询某一条数据是否存在 */
+ (BOOL)selectContactMember:(NSString *)imageUrl userName:(NSString *)userName;

/** 删除数据 */
+ (BOOL)deleteCollectWithimageUrl:(NSString *)url;


#pragma mark - 轨迹
/** 保存文件 */
+(BOOL)savePathDataWithFile_name:(NSString *)file_name collect:(NSString *)collect del:(NSString *)del user_name:(NSString *)user_name mac_adr:(NSString *)mac_adr endMileage:(NSString *)endMileage startMileage:(NSString *)startMileage tirpMileage:(NSString *)tirpMileage tirpTime:(NSString *)tirpTime;

/** 根据文件名保存起始结束经纬度 */

+(BOOL)savePathDataWithStart_lat:(NSString *)start_lat start_long:(NSString *)start_long end_lat:(NSString *)end_lat end_long:(NSString *)end_long start_address:(NSString *)start_address file_name:(NSString *)file_name;

/** 根据用户获取轨迹数据 */
+ (NSMutableArray *)getPathsFromDataBaseWithUser_name:(NSString *)user_name;

/** 根据用户获取轨迹数据 */
+ (NSMutableArray *)getPathsFromDataBaseWithMac_adr:(NSString *)mac_adr;

/** 根据file_name获取轨迹数据 */
+ (AlbumsPathModel *)getPathsFromDataBaseWithFile_name:(NSString *)file_name;

/** 查询某一条数据是否存在 */
+ (BOOL)selectPathWithFile_name:(NSString *)file_name userName:(NSString *)userName;

/** 查询某条数据是否被删除 */
+ (BOOL)selectPathIsDelWithFile_name:(NSString *)file_name userName:(NSString *)userName;

/** 根据file_name修改删除状态 */
+ (BOOL)updatePathdelWithFile_name:(NSString *)file_name userName:(NSString *)userName;

/** 根据file_name修改起始地址 */
+ (BOOL)updatePathdelWithFile_name:(NSString *)file_name start_address:(NSString *)start_address userName:(NSString *)userName;




#pragma mark - 下载文件

//保存数据
+ (BOOL)saveDownloadFileWithFileName:(NSString *)fileName is_del:(NSString *)del;

//根据fileName修改删除状态
+ (BOOL)updateDowloaddelWithFile_name:(NSString *)file_name;

/** 查询某一条数据是否存在 */
+ (BOOL)selectDownloadWithFile_name:(NSString *)file_name;

/** 查询某条数据是否被删除 */
+ (BOOL)selectDownloadIsDelWithFile_name:(NSString *)file_name;
+ (BOOL)deleteDownloadWithFile_name:(NSString *)file_name;

@end
