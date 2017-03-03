//
//  FMDBManage.h
//  YunNanTong
//
//  Created by  on 16/8/25.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDBManage : NSObject

+ (void) insertProgramWithObject:(id) object;

+ (NSMutableArray *)getDataFromTable:(id)table WithString:(NSString *) string;

+ (void) deleteFromTable:(id)table WithString:(NSString *) string;

+ (void) updateTable:(id)table setString:(NSString *) setString WithString:(NSString *) string;

+ (void)clearDBFile;

//升级数据库，删除用户登录数据
//+ (void) updateDBWithNewVersion;

@end
