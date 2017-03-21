//
//  FMDBManage.h
//  YunNanTong
//
//  Created by  on 16/8/25.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDBManage : NSObject

//增
+ (void) insertProgramWithObject:(id) object;
//查
+ (NSMutableArray *)getDataFromTable:(id)table WithString:(NSString *) string;

//删
+ (void) deleteFromTable:(id)table WithString:(NSString *) string;

//改
+ (void) updateTable:(id)table setString:(NSString *) setString WithString:(NSString *) string;

/*
 使用时步骤：1、引入FMDB数据库  2、把FMDBManage的.h 和 .m文件拉进工程里。
          使用的具体情况可以参照本工程的ViewController.m文件
 */

//+ (void)clearDBFile;

//升级数据库，删除用户登录数据
//+ (void) updateDBWithNewVersion;

@end
