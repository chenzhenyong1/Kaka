//
//  FMDBTools.m
//  KaKa
//
//  Created by Change_pan on 16/8/17.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "FMDBTools.h"
#import "FMDB.h"
#import "CollectModel.h"
#import "MyTools.h"
@implementation FMDBTools

static FMDatabase *_db;

+(void)initialize
{
    //1.打开数据库
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Collect.db"];
    NSLog(@"======path====== %@",path);
    _db = [FMDatabase databaseWithPath:path];
    
    //打开
    [_db open];
    
    //2.创建表
    
    //收藏表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_collect (id integer PRIMARY KEY, imageUrl text NOT NULL, type text NOT NULL, userName text NOT NULL);"];// id  imageUrl
    
    //需要新增的字段
    if(![_db columnExists:@"collectTime" inTableWithName:@"t_collect"]){
        [_db executeUpdate:@"ALTER TABLE t_collect ADD COLUMN collectTime text"];
    }
    
    //轨迹表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_path (id integer PRIMARY KEY,file_name text NOT NULL,collect text NOT NULL,del text NOT NULL,user_name text NOT NULL,mac_adr text NOT NULL,endMileage text,startMileage text,tirpMileage text,tirpTime text,start_lat text,start_long text,end_lat text,end_long text,start_address text)"];
    
    //下载文件
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_download (id integer PRIMARY KEY, fileName text NOT NULL, is_del text NOT NULL);"];
    
}

#pragma mark -收藏

/** 保存文件路径到数据库 */
+ (BOOL)saveContactsWithImageUrl:(NSString *)imageUrl type:(NSString *)type
{
    NSString *currentTimeStr = [MyTools getCurrentStandarTimeWithMinute1];
    NSString *sqlStr = @"INSERT INTO t_collect (imageUrl,type,userName,collectTime) VALUES (?,?,?,?)";

   BOOL isSave = [_db executeUpdate:sqlStr,imageUrl,type,UserName,currentTimeStr];
    return isSave;

}

/** 获取文件路径 */
+ (NSMutableArray *)getImageUrlsFromDataBaseWithName:(NSString *)name
{
    
    
    NSMutableArray *imageUrls = [[NSMutableArray alloc] init];
    
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_collect WHERE userName = %@ ORDER BY collectTime DESC",name];
    while (set.next) {
        
        CollectModel *model = [[CollectModel alloc] init];
        model.collectSoruce = [set stringForColumn:@"imageUrl"];
        model.collectType = [set stringForColumn:@"type"];
        [imageUrls addObject:model];
    }
    
    return imageUrls;
}

/** 查询某一条数据是否存在 */
+ (BOOL)selectContactMember:(NSString *)imageUrl userName:(NSString *)userName
{

    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_collect WHERE imageUrl = %@ AND userName = %@",imageUrl,userName];
    
    return set.next;

}

/** 删除数据 */
+ (BOOL)deleteCollectWithimageUrl:(NSString *)url
{
    BOOL isDeleteSuccess = NO;
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_collect WHERE imageUrl = %@ AND userName = %@",url, UserName];
    while (set.next)
    {
        if ([_db executeUpdateWithFormat:@"DELETE FROM t_collect WHERE imageUrl = %@ AND userName = %@",url, UserName])
        {
            MMLog(@"删除成功!");
            isDeleteSuccess = YES;
        }
        else
        {
            MMLog(@"删除失败!");
        }
    }
    
    return isDeleteSuccess;
}

#pragma mark - 轨迹
//保存轨迹文件
+(BOOL)savePathDataWithFile_name:(NSString *)file_name collect:(NSString *)collect del:(NSString *)del user_name:(NSString *)user_name mac_adr:(NSString *)mac_adr endMileage:(NSString *)endMileage startMileage:(NSString *)startMileage tirpMileage:(NSString *)tirpMileage tirpTime:(NSString *)tirpTime
{
    NSString *sqlStr = @"INSERT INTO t_path (file_name,collect,del,user_name,mac_adr,endMileage,startMileage,tirpMileage,tirpTime) VALUES (?,?,?,?,?,?,?,?,?)";
    
    BOOL isSave = [_db executeUpdate:sqlStr,file_name,collect,del,user_name,mac_adr,endMileage,startMileage,tirpMileage,tirpTime];
    return isSave;
}

/** 根据文件名保存起始结束经纬度 */

+(BOOL)savePathDataWithStart_lat:(NSString *)start_lat start_long:(NSString *)start_long end_lat:(NSString *)end_lat end_long:(NSString *)end_long start_address:(NSString *)start_address file_name:(NSString *)file_name
{
    
    BOOL isSussess = [_db executeUpdateWithFormat:@"UPDATE t_path SET start_address = %@,start_lat = %@,start_long =%@,end_lat =%@,end_long =%@ WHERE file_name = %@",start_address,start_lat,start_long,end_lat,end_long,file_name];
    return isSussess;
    
}





/** 根据用户获取轨迹数据 */
+ (NSMutableArray *)getPathsFromDataBaseWithUser_name:(NSString *)user_name
{
    
    
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_path WHERE user_name = %@",user_name];
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    while (set.next) {
        AlbumsPathModel *pathModel = [[AlbumsPathModel alloc] init];
        
        pathModel.fileName = [set stringForColumn:@"file_name"];
        pathModel.collect = [set stringForColumn:@"collect"];
        pathModel.del = [set stringForColumn:@"del"];
        pathModel.user_name = [set stringForColumn:@"user_name"];
        pathModel.mac_adr = [set stringForColumn:@"mac_adr"];
        pathModel.endMileage = [set stringForColumn:@"endMileage"];
        pathModel.startMileage = [set stringForColumn:@"startMileage"];
        pathModel.tirpMileage = [set stringForColumn:@"tirpMileage"];
        pathModel.tirpTime = [set stringForColumn:@"tirpTime"];
        pathModel.start_lat = [set stringForColumn:@"start_lat"];
        pathModel.start_long = [set stringForColumn:@"start_long"];
        pathModel.end_lat = [set stringForColumn:@"end_lat"];
        pathModel.end_long = [set stringForColumn:@"end_long"];
        pathModel.start_address = [set stringForColumn:@"start_address"];
        
        [contacts addObject:pathModel];
    }
    
    return contacts;
}

/** 根据用户获取轨迹数据 */
+ (NSMutableArray *)getPathsFromDataBaseWithMac_adr:(NSString *)mac_adr
{
    
    
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_path WHERE mac_adr = %@",mac_adr];
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    while (set.next) {
        AlbumsPathModel *pathModel = [[AlbumsPathModel alloc] init];
        
        pathModel.fileName = [set stringForColumn:@"file_name"];
        pathModel.collect = [set stringForColumn:@"collect"];
        pathModel.del = [set stringForColumn:@"del"];
        pathModel.user_name = [set stringForColumn:@"user_name"];
        pathModel.mac_adr = [set stringForColumn:@"mac_adr"];
        pathModel.endMileage = [set stringForColumn:@"endMileage"];
        pathModel.startMileage = [set stringForColumn:@"startMileage"];
        pathModel.tirpMileage = [set stringForColumn:@"tirpMileage"];
        pathModel.tirpTime = [set stringForColumn:@"tirpTime"];
        pathModel.start_lat = [set stringForColumn:@"start_lat"];
        pathModel.start_long = [set stringForColumn:@"start_long"];
        pathModel.end_lat = [set stringForColumn:@"end_lat"];
        pathModel.end_long = [set stringForColumn:@"end_long"];
        pathModel.start_address = [set stringForColumn:@"start_address"];
        
        [contacts addObject:pathModel];
    }
    
    return contacts;
}

/** 根据file_name获取轨迹数据 */
+ (AlbumsPathModel *)getPathsFromDataBaseWithFile_name:(NSString *)file_name {
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_path WHERE file_name = %@",file_name];
    
    AlbumsPathModel *pathModel;
    while (set.next) {
        pathModel = [[AlbumsPathModel alloc] init];
        
        pathModel.fileName = [set stringForColumn:@"file_name"];
        pathModel.collect = [set stringForColumn:@"collect"];
        pathModel.del = [set stringForColumn:@"del"];
        pathModel.user_name = [set stringForColumn:@"user_name"];
        pathModel.mac_adr = [set stringForColumn:@"mac_adr"];
        pathModel.endMileage = [set stringForColumn:@"endMileage"];
        pathModel.startMileage = [set stringForColumn:@"startMileage"];
        pathModel.tirpMileage = [set stringForColumn:@"tirpMileage"];
        pathModel.tirpTime = [set stringForColumn:@"tirpTime"];
        pathModel.start_lat = [set stringForColumn:@"start_lat"];
        pathModel.start_long = [set stringForColumn:@"start_long"];
        pathModel.end_lat = [set stringForColumn:@"end_lat"];
        pathModel.end_long = [set stringForColumn:@"end_long"];
        pathModel.start_address = [set stringForColumn:@"start_address"];
    }
    
    return pathModel;

}


/** 查询某一条数据是否存在 */
+ (BOOL)selectPathWithFile_name:(NSString *)file_name userName:(NSString *)userName
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_path WHERE file_name = %@ AND user_name = %@",file_name,userName];
    
    return set.next;
}

/** 查询某条数据是否被删除 */
+ (BOOL)selectPathIsDelWithFile_name:(NSString *)file_name userName:(NSString *)userName
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_path WHERE file_name = %@ AND user_name = %@",file_name,userName];
    
    while (set.next) {
        NSString *del = [set stringForColumn:@"del"];
        if ([del isEqualToString:@"0"])
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return YES;
}


/** 根据file_name修改删除状态 */
+ (BOOL)updatePathdelWithFile_name:(NSString *)file_name userName:(NSString *)userName
{
   BOOL isSussess = [_db executeUpdateWithFormat:@"UPDATE t_path SET del = %@ WHERE file_name = %@ AND user_name = %@",@"1",file_name,userName];
    return isSussess;
}

/** 根据file_name修改起始地址 */
+ (BOOL)updatePathdelWithFile_name:(NSString *)file_name start_address:(NSString *)start_address userName:(NSString *)userName
{
    BOOL isSussess = [_db executeUpdateWithFormat:@"UPDATE t_path SET start_address = %@ WHERE file_name = %@ AND user_name = %@",start_address,file_name,userName];
    return isSussess;
}


#pragma mark - 下载文件

+ (BOOL)saveDownloadFileWithFileName:(NSString *)fileName is_del:(NSString *)del
{
    NSString *sqlStr = @"INSERT INTO t_download (fileName,is_del) VALUES (?,?)";
    
    BOOL isSave = [_db executeUpdate:sqlStr,fileName,del];
    return isSave;
}

/** 根据fileName修改删除状态 */
+ (BOOL)updateDowloaddelWithFile_name:(NSString *)file_name
{
    BOOL isSussess = [_db executeUpdateWithFormat:@"UPDATE t_download SET is_del = %@ WHERE fileName = %@",@"1",file_name];
    return isSussess;
}

/** 查询某一条数据是否存在 */
+ (BOOL)selectDownloadWithFile_name:(NSString *)file_name
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_download WHERE fileName = %@",file_name];
    
    return set.next;
}

/** 查询某条数据是否被删除 */
+ (BOOL)selectDownloadIsDelWithFile_name:(NSString *)file_name
{
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_download WHERE fileName = %@",file_name];
    
    while (set.next) {
        NSString *del = [set stringForColumn:@"is_del"];
        if ([del isEqualToString:@"0"])
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return YES;
}

/** 查询某一条数据是否存在 */
+ (BOOL)deleteDownloadWithFile_name:(NSString *)file_name
{
    BOOL isSussess = [_db executeQueryWithFormat:@"DELETE FROM t_download WHERE fileName = %@",file_name];
    
    return isSussess;
}


@end
