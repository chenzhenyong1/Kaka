//
//  Credentials.h
//  媒体测试
//
//  Created by 陈振勇 on 16/8/4.
//  Copyright © 2016年 陈振勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Credentials : NSObject

/** bucket */
@property (nonatomic, copy) NSString *bucket;
/** keyId */
@property (nonatomic, copy) NSString *keyId;
/** endPoint */
@property (nonatomic, copy) NSString *endPoint;
/** keyExpiration */
@property (nonatomic, copy) NSString *keyExpiration;
/** cName */
@property (nonatomic, copy) NSString *cName;
/** securityToken */
@property (nonatomic, copy) NSString *securityToken;
/** keySecret */
@property (nonatomic, copy) NSString *keySecret;

//    credentials = [
//    {
//        bucket = ekaka-t,
//        keyId = STS.DZHbafdXX9rj6jVwgVYChL14j,
//        endPoint = oss-cn-shenzhen.aliyuncs.com,
//        keyExpiration = 1470305479000,
//        cName = 0,
//        securityToken = CAES8AMIARKAATGpDH1XUh/d05P66BF1SubP8X1Ih0XtkmzW4E15TO6H6yyq9xLQu287vCRtujCTn6WAFQn+WhexYK328oXKONl9Gto7MOImog9N6krjc/OEI6vTSxYZ2ULdeGpmRu4aMzV3kMLgd3fzi6TZtUlt3mMH9Ez1mgRSx6cPbQgABhTuGh1TVFMuRFpIYmFmZFhYOXJqNmpWd2dWWUNoTDE0aiISMzkxNzE3OTY4NTQ1NzczODU4KgM0MTEwy9SkqOUqOgZSc2FNRDVC0AEKATEaygEKBUFsbG93EosBCgxBY3Rpb25FcXVhbHMSBkFjdGlvbhpzCg1vc3M6UHV0T2JqZWN0Chtvc3M6SW5pdGlhdGVNdWx0aXBhcnRVcGxvYWQKDm9zczpVcGxvYWRQYXJ0Chtvc3M6Q29tcGxldGVNdWx0aXBhcnRVcGxvYWQKGG9zczpBYm9ydE11bHRpcGFydFVwbG9hZBIzCg5SZXNvdXJjZUVxdWFscxIIUmVzb3VyY2UaFwoVYWNzOm9zczoqOio6ZWtha2EtdC8qShAxNjg3MjY3MjUyMDE0MDAxUgUyNjg0MloPQXNzdW1lZFJvbGVVc2VyYABqEjM5MTcxNzk2ODU0NTc3Mzg1OHIGdXBsb2FkeLGXyqn40f8C,
//        keySecret = 2wx97LoGw8JYCWaWHuCZ6bzZK6hkYhhCNYoB2Lq3MpRh
//    }
//                   ]
@end
