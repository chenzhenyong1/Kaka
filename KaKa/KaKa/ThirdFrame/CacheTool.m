//
//  CacheTool.m
//  KaKa
//
//  Created by 深圳市 秀软科技有限公司 on 16/8/23.
//  Copyright © 2016年 深圳市秀软科技有限公司. All rights reserved.
//

#import "CacheTool.h"
#import <FMDB.h>

@implementation CacheTool

static FMDatabaseQueue *_queue;

+ (void)setup
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"KaKa.sqlite"];
    
    _queue  = [FMDatabaseQueue databaseQueueWithPath:path];
    [_queue inDatabase:^(FMDatabase *db) {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]] ) {
            // 创建摄像机列表
            [db executeUpdate:@"create table if not exists CameraList (id integer primary key autoincrement,macAddress text,ipAddress text,name text,bgImage text,addTime text,userId text);"];
            // 游记
            [db executeUpdate:@"create table if not exists Travel (id integer primary key autoincrement,cameraMac text,userId text,startTime text,endTime text,endMileage text,tirpMileage text,tirpTime text,startPostion text,endPostion text,startPostionShow text,endPostionShow text,deleted integer,flag text);"];
            // 游记详情
            [db executeUpdate:@"create table if not exists TravelDetail (id integer primary key autoincrement,pid integer,date text,time text,type text,gps text,fileName text,mood text,shared integer);"];
            // 时间线
            [db executeUpdate:@"create table if not exists TimeLine (id integer primary key autoincrement,cameraMac text,userId text,startMileage text,time text unique,date text,type text,media text,endMileage text,gps text,tirpMileage text,tirpTime text);"];
        }
        
    }];
}
/**
 *  查询摄像机列表
 *
 *  @return 查询到的摄像机数据
 */
+ (NSMutableArray *)queryCameraList {
    
    [self setup];
    
    __block  NSMutableArray *getArray = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from CameraList where userId = ? order by addTime DESC", UserName];
        
        NSMutableArray *tempArray = [NSMutableArray new];
        while (rs.next) {
            
            NSString *macAddress = [rs stringForColumn:@"macAddress"];
            NSString *ipAddress = [rs stringForColumn:@"ipAddress"];
            NSString *name = [rs stringForColumn:@"name"];
            NSString *bgImage = [rs stringForColumn:@"bgImage"];
            NSString *addTime = [rs stringForColumn:@"addTime"];
            NSString *userName = [rs stringForColumn:@"userId"];
            
            CameraListModel *model = [[CameraListModel alloc] init];
            model.macAddress = macAddress;
            model.ipAddress = ipAddress;
            model.name = name;
            model.bgImage = bgImage;
            model.addTime = addTime;
            model.userName = userName;
            
            [tempArray addObject:model];
        }
        getArray = tempArray;
        
        [rs close];
    }];
    
    [_queue close];
    
    return  getArray;

}
/**
 *  根据mac地址查询摄像机
 *
 *  @param macAddress 要查询的摄像机
 *
 *  @return 查询到的摄像机
 */
+ (CameraListModel *)queryCameraWithMacAddress:(NSString *)macAddress {
    
    [self setup];
    
    __block  CameraListModel *model;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from CameraList where macAddress = ? and userId = ?",macAddress, UserName];
        if (rs.next) {
        
            NSString *macAddress = [rs stringForColumn:@"macAddress"];
            NSString *ipAddress = [rs stringForColumn:@"ipAddress"];
            NSString *name = [rs stringForColumn:@"name"];
            NSString *bgImage = [rs stringForColumn:@"bgImage"];
            NSString *addTime = [rs stringForColumn:@"addTime"];
            NSString *userName = [rs stringForColumn:@"userId"];
            
            model = [[CameraListModel alloc] init];
            model.macAddress = macAddress;
            model.ipAddress = ipAddress;
            model.name = name;
            model.bgImage = bgImage;
            model.addTime = addTime;
            model.userName = userName;
        }
        
        [rs close];
    }];
    
    [_queue close];
    
    return  model;

}
/**
 *  更新摄像机列表
 *
 *  @param model 更新的摄像机
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)updateCameraListWithCameraListModel:(CameraListModel *)model{
    
    [self setup];
    
    __block BOOL succeedInsert = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from CameraList where macAddress = ? and userId = ?",model.macAddress, UserName];
        if (rs.next) {
            succeedInsert = [db executeUpdate:@"update CameraList set ipAddress = ?,name = ?,bgImage = ?,addTime = ? where macAddress = ? and userId = ?", model.ipAddress,model.name,model.bgImage,model.addTime, model.macAddress, UserName];
        } else {
            succeedInsert = [db executeUpdate:@"insert into CameraList (macAddress,ipAddress,name,bgImage,addTime,userId) values (?,?,?,?,?,?)",model.macAddress,model.ipAddress,model.name,model.bgImage,model.addTime,UserName];
        }
        
        [rs close];
        
    }];
    
    [_queue close];
    
    return succeedInsert;
}

#pragma mark - 游记
/**
 *  根据用户名查询游记
 *
 *  @param userName 用户名
 *
 *  @return @return 查询到的AlbumsTravelModel数据
 */
+ (NSMutableArray *)queryTravelsWithUserName:(NSString *)userName {
    
    [self setup];
    
    __block  NSMutableArray *getArray = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *tempArray = [NSMutableArray new];
        
        FMResultSet *rs = [db executeQuery:@"select * from Travel where userId = ? order by endTime desc", userName];
        while (rs.next) {
            
            BOOL deleted = [rs boolForColumn:@"deleted"];
            if (deleted) {
                // 删除的游记不显示
                continue;
            }
            
            NSString *startTime = [rs stringForColumn:@"startTime"];
            NSString *endTime = [rs stringForColumn:@"endTime"];
            if ([startTime longLongValue] > [endTime longLongValue]) {
                continue;
            }
            
            NSInteger travelId = [rs intForColumn:@"id"];
            NSArray *travelDetailArray = [CacheTool queryTravelDetailWithTravelId:travelId];
            if (travelDetailArray.count == 0) {
                continue;
            }
            
            AlbumsTravelModel *model = [[AlbumsTravelModel alloc] init];
            model.travelId = [rs intForColumn:@"id"];
            model.userId = [rs stringForColumn:@"userId"];
            model.startTime = [rs stringForColumn:@"startTime"];
            model.endTime = [rs stringForColumn:@"endTime"];
            model.cameraMac = [rs stringForColumn:@"cameraMac"];
            model.endMileage = [rs stringForColumn:@"endMileage"];
            model.tirpMileage = [rs stringForColumn:@"tirpMileage"];
            model.tirpTime = [rs stringForColumn:@"tirpTime"];
            model.startPostion = [rs stringForColumn:@"startPostion"];
            model.endPostion = [rs stringForColumn:@"endPostion"];
            model.startPostionShow = [rs stringForColumn:@"startPostionShow"];
            model.endPostionShow = [rs stringForColumn:@"endPostionShow"];
            model.deleted = [rs boolForColumn:@"deleted"];
            model.flag = [rs stringForColumn:@"flag"];
            
            [tempArray addObject:model];
        }
        
        getArray = tempArray;
        
        [rs close];
    }];
    
    [_queue close];
    
    return  getArray;
}

/**
 *  根据travelId查询游记
 *
 *  @param userName 用户名
 *
 *  @return @return 查询到的AlbumsTravelModel数据
 */
+ (AlbumsTravelModel *)queryTravelsWithTravelId:(NSString *)travelId {
    [self setup];
    
    __block  AlbumsTravelModel *model = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from Travel where id = ?", travelId];
        while (rs.next) {
//            // 正在进行的游记不显示
//            NSString *endTime = [rs stringForColumn:@"endTime"];
//            if (endTime.length == 0) {
//                continue;
//            }
//            
//            BOOL deleted = [rs boolForColumn:@"deleted"];
//            if (deleted) {
//                // 删除的游记不显示
//                continue;
//            }
            NSString *flag = [rs stringForColumn:@"flag"];
//            if (![flag isEqualToString:@"0"]) {
//                // 没有完成的游记不显示
//                continue;
//            }
//            
//            NSString *startTime = [rs stringForColumn:@"startTime"];
//            if (startTime.length < 14 || endTime.length < 14) {
//                continue;
//            }
//            
//            if ([startTime longLongValue] > [endTime longLongValue]) {
//                continue;
//            }
            
            BOOL deleted = [rs boolForColumn:@"deleted"];
            if (deleted) {
                // 删除的游记不显示
                continue;
            }
            
            NSString *startTime = [rs stringForColumn:@"startTime"];
            NSString *endTime = [rs stringForColumn:@"endTime"];
            if ([startTime longLongValue] > [endTime longLongValue]) {
                continue;
            }
            
            model = [[AlbumsTravelModel alloc] init];
            model.travelId = [rs intForColumn:@"id"];
            model.userId = [rs stringForColumn:@"userId"];
            model.startTime = [rs stringForColumn:@"startTime"];
            model.endTime = [rs stringForColumn:@"endTime"];
            model.cameraMac = [rs stringForColumn:@"cameraMac"];
            model.endMileage = [rs stringForColumn:@"endMileage"];
            model.tirpMileage = [rs stringForColumn:@"tirpMileage"];
            model.tirpTime = [rs stringForColumn:@"tirpTime"];
            model.startPostion = [rs stringForColumn:@"startPostion"];
            model.endPostion = [rs stringForColumn:@"endPostion"];
            model.startPostionShow = [rs stringForColumn:@"startPostionShow"];
            model.endPostionShow = [rs stringForColumn:@"endPostionShow"];
            model.deleted = [rs boolForColumn:@"deleted"];
            model.flag = flag;
        }
        
        [rs close];
    }];
    
    [_queue close];
    
    return  model;

}

/**
 *  根据摄像机mac地址、用户名查找正在进行中的游记，即只有开始，没有结束的游记
 *
 *  @param cameraMac 要查找的mac地址
 *  @param userName  要查找的用户
 *
 *  @return 游记数据
 */
+ (NSMutableArray *)queryTravelsUncompleteWithCameraMac:(NSString *)cameraMac userName:(NSString *)userName {
    
    [self setup];
    
    __block  NSMutableArray *getArray = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *tempArray = [NSMutableArray new];
        FMResultSet *rs = [db executeQuery:@"select * from Travel where userId = ? and cameraMac = ?", userName, cameraMac];
        while (rs.next) {
            // 找到只有开始，没有结束的游记
            NSString *flag = [rs stringForColumn:@"flag"];
            if ([flag isEqualToString:@"0"]) {
                // 游记已经完成
                continue;
            }
            
            BOOL deleted = [rs boolForColumn:@"deleted"];
            if (deleted) {
                // 删除的游记不显示
                continue;
            }

            AlbumsTravelModel *model = [[AlbumsTravelModel alloc] init];
            model.travelId = [rs intForColumn:@"id"];
            model.userId = [rs stringForColumn:@"userId"];
            model.startTime = [rs stringForColumn:@"startTime"];
            model.endTime = [rs stringForColumn:@"endTime"];
            model.cameraMac = [rs stringForColumn:@"cameraMac"];
            model.endMileage = [rs stringForColumn:@"endMileage"];
            model.tirpMileage = [rs stringForColumn:@"tirpMileage"];
            model.tirpTime = [rs stringForColumn:@"tirpTime"];
            model.startPostion = [rs stringForColumn:@"startPostion"];
            model.endPostion = [rs stringForColumn:@"endPostion"];
            model.startPostionShow = [rs stringForColumn:@"startPostionShow"];
            model.endPostionShow = [rs stringForColumn:@"endPostionShow"];
            model.deleted = [rs boolForColumn:@"deleted"];
            model.flag = flag;

            [tempArray addObject:model];
        }
        
        getArray = tempArray;
        [rs close];
    }];
    
    [_queue close];
    
    return  getArray;

}

/**
 *  更新游记
 *
 *  @param model 更新的游记数据
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)updateTravelWithTravelModel:(AlbumsTravelModel *)travelModel {
    
    [self setup];
    
    __block BOOL succeedInsert = NO;
    [_queue inDatabase:^(FMDatabase *db) {
    
        FMResultSet *rs = [db executeQuery:@"select * from Travel where id = ?",@(travelModel.travelId)];
        
        if (rs.next) {
            succeedInsert = [db executeUpdate:@"update Travel set startTime = ?,endTime = ?,endMileage = ?,tirpMileage = ?,tirpTime = ?,startPostion = ?,endPostion = ?,startPostionShow = ?,endPostionShow = ?,deleted = ?,flag = ? where id = ?",travelModel.startTime,travelModel.endTime, travelModel.endMileage, travelModel.tirpMileage, travelModel.tirpTime, travelModel.startPostion, travelModel.endPostion, travelModel.startPostionShow, travelModel.endPostionShow, @(travelModel.deleted), travelModel.flag, @(travelModel.travelId)];
            
        } else {
            succeedInsert = [db executeUpdate:@"insert into Travel (userId,startTime,endTime,cameraMac,endMileage,tirpMileage,tirpTime,startPostion,endPostion,startPostionShow,endPostionShow,deleted,flag) values (?,?,?,?,?,?,?,?,?,?,?,?,?)",travelModel.userId,travelModel.startTime,travelModel.endTime,travelModel.cameraMac,travelModel.endMileage,travelModel.tirpMileage,travelModel.tirpTime,travelModel.startPostion,travelModel.endPostion,travelModel.startPostionShow,travelModel.endPostionShow,@(travelModel.deleted),travelModel.flag];
        }
        
        [rs close];
        
    }];
    
    [_queue close];
    
    return succeedInsert;
}

/**
 *  根据游记Id删除游记
 *
 *  @param travelId 要删除的游记id
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)deleteTravelWithTravelId:(NSInteger)travelId {
    [self setup];
    
    __block BOOL succeedInsert = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from Travel where id = ?",@(travelId)];
        if (rs.next) {
            succeedInsert = [db executeUpdate:@"update Travel set deleted = ? where id = ?", @"1",@(travelId)];
        }
        [rs close];
    }];
    
    [_queue close];
    
    return succeedInsert;
}

/**
 *  根据游记Id删除空游记
 *
 *  @param travelId 要删除的游记id
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)deleteEmptyTravelWithTravelId:(NSInteger)travelId {
    [self setup];
    
    __block BOOL succeedDelete = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        
        succeedDelete = [db executeUpdate:@"delete from Travel where id = ?",@(travelId)];
    }];
    
    [_queue close];
    
    return succeedDelete;
}

// 游记详情
/**
 *  根据游记Id查询游记详情
 *
 *  @param travelId 要查找的游记id
 *
 *  @return 游记详情数据
 */
+ (NSMutableArray *)queryTravelDetailWithTravelId:(NSInteger)travelId {
    
    [self setup];
    
    __block  NSMutableArray *getArray = nil;
    [_queue inDatabase:^(FMDatabase *db) {

        NSMutableArray *tempArray = [NSMutableArray new];
        FMResultSet *rs = [db executeQuery:@"select * from TravelDetail where pid = ?", @(travelId)];
        while (rs.next) {
            
            NSString *time = [rs stringForColumn:@"time"];
            if (time.length == 0) {
                continue;
            }
            
            AlbumsTravelDetailModel *model = [[AlbumsTravelDetailModel alloc] init];
            model.detailId = [rs intForColumn:@"id"];
            model.travelId = travelId;
            model.date = [rs stringForColumn:@"date"];
            model.time = [rs stringForColumn:@"time"];
            model.type = [rs stringForColumn:@"type"];
            model.gps = [rs stringForColumn:@"gps"];
            model.fileName = [rs stringForColumn:@"fileName"];
            model.mood = [rs stringForColumn:@"mood"];
            model.shared = [rs boolForColumn:@"shared"];
            [tempArray addObject:model];
        }
        
        getArray = tempArray;
        [rs close];
    }];
    
    [_queue close];
    
    return  getArray;

}

/** 查询某一条数据是否存在 */
+ (BOOL)isExistTravelDetailWithTime:(NSString *)time travelId:(NSInteger)travelId{
    
    [self setup];
    __block BOOL exist = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from TravelDetail where time = ? and pid = ?", time, @(travelId)];
        exist = rs.next;
        [rs close];
    }];
    
    [_queue close];
    
    return exist;
}

/**
 *  更新游记详情
 *
 *  @param detail 要更新的游记详情
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)updateTravelDetailWithDetailModel:(AlbumsTravelDetailModel *)detail {
    
    [self setup];
    
    __block BOOL succeedInsert = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from TravelDetail where id = ?",@(detail.detailId)];
        if (rs.next) {
            succeedInsert = [db executeUpdate:@"update TravelDetail set fileName = ?,mood = ?,shared = ? where id = ?",detail.fileName,detail.mood, @(detail.shared), @(detail.detailId)];
            
        } else {
            succeedInsert = [db executeUpdate:@"insert into TravelDetail (pid,date,time,type,gps,fileName,mood,shared) values (?,?,?,?,?,?,?,?)",@(detail.travelId),detail.date,detail.time,detail.type,detail.gps,detail.fileName,detail.mood,@(detail.shared)];
        }
        
        [rs close];
        
    }];
    
    [_queue close];
    
    return succeedInsert;
}

/**
 *  删除游记详情
 *
 *  @param detailId 要删除的游记详情id
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)deleteTravelDetailWithDetailId:(NSInteger)detailId {
    
    [self setup];
    
    __block BOOL succeedDelete = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        
        succeedDelete = [db executeUpdate:@"delete from TravelDetail where id = ?", @(detailId)];
    }];
    
    [_queue close];
    
    return succeedDelete;
}


#pragma mark - 时间线
/**
 *  根据时间和用户、mac地址查找时间线数据
 *
 *  @param date      日期
 *  @param camereMac mac地址
 *  @param userId    用户
 *
 *  @return 查找到的CameraTime_lineModel数据数组
 */
+ (NSMutableArray *)queryCameraTime_lineListWithDate:(NSString *)date camereMac:(NSString *)camereMac userId:(NSString *)userId {
    
    [self setup];
    
    __block  NSMutableArray *getArray = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *tempArray = [NSMutableArray new];
        
        FMResultSet *rs = nil;
        if (date.length) {
            rs = [db executeQuery:@"select * from TimeLine where userId = ? and cameraMac = ? and date = ?", userId,camereMac,date];
        } else {
            rs = [db executeQuery:@"select * from TimeLine where userId = ? and cameraMac = ?", userId,camereMac];
        }
        
        while (rs.next) {
            
            CameraTime_lineModel *model = [[CameraTime_lineModel alloc] init];
            model.userId = [rs stringForColumn:@"userId"];
            model.cameraMac = [rs stringForColumn:@"cameraMac"];
            model.startMileage = [rs stringForColumn:@"startMileage"];
            model.time = [rs stringForColumn:@"time"];
            model.type = [rs stringForColumn:@"type"];
            model.media = [rs stringForColumn:@"media"];
            model.endMileage = [rs stringForColumn:@"endMileage"];
            model.gps = [rs stringForColumn:@"gps"];
            model.tirpMileage = [rs stringForColumn:@"tirpMileage"];
            model.tirpTime = [rs stringForColumn:@"tirpTime"];
            model.date = [rs stringForColumn:@"date"];
            
            [tempArray addObject:model];
        }
        
        getArray = tempArray;
        
        [rs close];
    }];
    
    [_queue close];
    
    return  getArray;
}

/**
 *  根据mac地址、用户查找time之后的时间线数据
 *
 *  @param time      时间
 *  @param camereMac mac地址
 *  @param userId    用户
 *
 *  @return 查找到的CameraTime_lineModel数据数组
 */
+ (NSMutableArray *)queryCameraTime_lineListAfterTime:(NSString *)time camereMac:(NSString *)camereMac userId:(NSString *)userId {
    
    [self setup];
    
    __block  NSMutableArray *getArray = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *tempArray = [NSMutableArray new];
        
        FMResultSet *rs = [db executeQuery:@"select * from TimeLine where userId = ? and cameraMac = ? and time >= ?", userId,camereMac, time];
        
        while (rs.next) {
            
            CameraTime_lineModel *model = [[CameraTime_lineModel alloc] init];
            model.userId = [rs stringForColumn:@"userId"];
            model.cameraMac = [rs stringForColumn:@"cameraMac"];
            model.startMileage = [rs stringForColumn:@"startMileage"];
            model.time = [rs stringForColumn:@"time"];
            model.type = [rs stringForColumn:@"type"];
            model.media = [rs stringForColumn:@"media"];
            model.endMileage = [rs stringForColumn:@"endMileage"];
            model.gps = [rs stringForColumn:@"gps"];
            model.tirpMileage = [rs stringForColumn:@"tirpMileage"];
            model.tirpTime = [rs stringForColumn:@"tirpTime"];
            model.date = [rs stringForColumn:@"date"];
            
            [tempArray addObject:model];
        }
        
        getArray = tempArray;
        
        [rs close];
    }];
    
    [_queue close];
    
    return  getArray;

}

/**
 *  根据mac地址、用户查找一个时间段内的时间线数据
 *
 *  @param fromTime  开始时间
 *  @param toTime    结束时间
 *  @param camereMac mac地址
 *  @param userId    用户
 *
 *  @return 查找到的CameraTime_lineModel数据数组
 */
+ (NSMutableArray *)queryCameraTime_lineListFromTime:(NSString *)fromTime toTime:(NSString *)toTime camereMac:(NSString *)camereMac userId:(NSString *)userId {
    
    [self setup];
    
    __block  NSMutableArray *getArray = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        NSMutableArray *tempArray = [NSMutableArray new];
        
        FMResultSet *rs = [db executeQuery:@"select * from TimeLine where userId = ? and cameraMac = ? and time >= ? and time <= ?", userId,camereMac, fromTime, toTime];
        
        while (rs.next) {
            
            CameraTime_lineModel *model = [[CameraTime_lineModel alloc] init];
            model.userId = [rs stringForColumn:@"userId"];
            model.cameraMac = [rs stringForColumn:@"cameraMac"];
            model.startMileage = [rs stringForColumn:@"startMileage"];
            model.time = [rs stringForColumn:@"time"];
            model.type = [rs stringForColumn:@"type"];
            model.media = [rs stringForColumn:@"media"];
            model.endMileage = [rs stringForColumn:@"endMileage"];
            model.gps = [rs stringForColumn:@"gps"];
            model.tirpMileage = [rs stringForColumn:@"tirpMileage"];
            model.tirpTime = [rs stringForColumn:@"tirpTime"];
            model.date = [rs stringForColumn:@"date"];
            
            [tempArray addObject:model];
        }
        
        getArray = tempArray;
        
        [rs close];
    }];
    
    [_queue close];
    
    return  getArray;

}

/**
 *  根据时间和用户、mac地址查找用户的上次停车数据
 *
 *  @param date      日期
 *  @param camereMac mac地址
 *  @param userId    用户
 *
 *  @return 查找到的CameraTime_lineModel数据数组
 */
+ (CameraTime_lineModel *)queryCameraTime_lineLastStopBeforeDate:(NSString *)beforeDate camereMac:(NSString *)camereMac userId:(NSString *)userId {
    
    [self setup];
    
    __block   CameraTime_lineModel *model = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from TimeLine where userId = ? and cameraMac = ? and time < ? order by time desc limit 0,1", userId,camereMac, beforeDate];
        
        while (rs.next) {
            
            NSString *type = [rs stringForColumn:@"type"];
            if ([type isEqualToString:@"Stop CDR"]) {
                model = [[CameraTime_lineModel alloc] init];
                model.userId = [rs stringForColumn:@"userId"];
                model.cameraMac = [rs stringForColumn:@"cameraMac"];
                model.startMileage = [rs stringForColumn:@"startMileage"];
                model.time = [rs stringForColumn:@"time"];
                model.type = [rs stringForColumn:@"type"];
                model.media = [rs stringForColumn:@"media"];
                model.endMileage = [rs stringForColumn:@"endMileage"];
                model.gps = [rs stringForColumn:@"gps"];
                model.tirpMileage = [rs stringForColumn:@"tirpMileage"];
                model.tirpTime = [rs stringForColumn:@"tirpTime"];
                model.date = [rs stringForColumn:@"date"];
            }
            
            break;
            
        }
        
        [rs close];
    }];
    
    [_queue close];
    
    return  model;

}

/**
 *  根据mac地址查找摄像机最后一次开机时间数据
 *  @param camereMac mac地址
 *  @return 查找到的yyyyMMddHHmmss数据
 */
+ (NSString *)queryCameraTime_lineLastStartCdrTimeWithCamereMac:(NSString *)camereMac {
    [self setup];
    
    __block   NSString *lastStartCdrTime = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from TimeLine where cameraMac = ? order by time desc",camereMac];
        
        while (rs.next) {
            
            NSString *type = [rs stringForColumn:@"type"];
            if ([type isEqualToString:@"Start CDR"]) {
                lastStartCdrTime = [rs stringForColumn:@"time"];
                break;
            }
            
        }
        
        [rs close];
    }];
    
    [_queue close];
    
    return  lastStartCdrTime;

}

/**
 *  插入时间线
 *
 *  @param model 要插入的时间线数据
 *
 *  @return 成功返回YES，失败返回NO
 */
+ (BOOL)insertimeLineWithCameraTime_lineModel:(CameraTime_lineModel *)model {
    [self setup];
    
    __block BOOL succeedInsert = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from TimeLine where userId = ? and cameraMac = ? and time = ?",model.userId,model.cameraMac,model.time];
        if (rs.next) {
            // 如果有，不做处理
        } else {
            succeedInsert = [db executeUpdate:@"insert into TimeLine (userId,cameraMac,startMileage,time,type,media,endMileage,gps,tirpMileage,tirpTime,date) values (?,?,?,?,?,?,?,?,?,?,?)",model.userId,model.cameraMac,model.startMileage,model.time,model.type,model.media,model.endMileage,model.gps,model.tirpMileage,model.tirpTime,model.date];
        }
        [rs close];
    }];
    
    [_queue close];
    
    return succeedInsert;
}

/**
 *  查找最后一次入库的时间
 *
 *  @param userId    用户
 *  @param camereMac mac地址
 *
 *  @return 查找到的时间
 */
+ (NSString *)dateLastUpdateToCameraTimeLineWithUserId:(NSString *)userId camereMac:(NSString *)camereMac {
    
    [self setup];
    
    __block  NSString *date = nil;
    [_queue inDatabase:^(FMDatabase *db) {
    
        FMResultSet *rs = [db executeQuery:@"select * from TimeLine where userId = ? and cameraMac = ? order by id desc limit 0,1", userId, camereMac];
        while (rs.next) {
            date = [rs stringForColumn:@"date"];
        }
        [rs close];
    }];
        
    [_queue close];
        
    return  date;
}

@end
