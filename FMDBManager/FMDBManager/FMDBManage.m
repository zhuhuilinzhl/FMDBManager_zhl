//
//  FMDBManage.m
//  YunNanTong
//
//  Created by  on 16/8/25.
//  Copyright © 2016年 . All rights reserved.
//

#import "FMDBManage.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import <objc/runtime.h>

static FMDatabase *db = nil;

@implementation FMDBManage

//反射读取对象属性
+ (NSArray*)propertyKeys:(id) object
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:outCount];
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        //  c语言的字符串转换
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [keys addObject:propertyName];
    }
    free(properties);
    return keys;
}

//数据库路径
+(NSString *)databaseFilePath
{
    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [filePath objectAtIndex:0];
    NSString *dbFilePath = [documentPath stringByAppendingPathComponent:@"db.sqlite"];
    //在Documents下创建一个数据库
    NSLog(@"dbFilePath:%@", dbFilePath);
    return dbFilePath;
}

//数据库创建，根据路径创建数据库
+(void)creatDatabase
{
    db = [FMDatabase databaseWithPath:[self databaseFilePath]];
}

//表的创建
+(void)creatTableWithObject:(id) object
{
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!db) {
        [self creatDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    //为数据库设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    NSString *tableName = [NSString stringWithFormat:@"%@",[object class]];
    
    //判断数据库中是否已经存在这个表，如果不存在则创建该表
    if([db tableExists:tableName] == NO)
    {
        //获取对象所有key
        NSArray *keys = [self propertyKeys:object];
        
        //  设置表头和表尾
        NSString *sqlString = @"";
        
        NSString *headerString = [NSString stringWithFormat:@"create table %@ (",[object class]];
        NSString *footerString = @")";
        
        //  中间的字符串长度设置为64
        NSMutableString *midString=[NSMutableString stringWithCapacity:64];
        
        for (int i = 0; i < [keys count]; i++)
        {
            NSString *keyString = [keys objectAtIndex:i];
            
            if (i == [keys count] - 1)
            {
                [midString appendFormat:@"%@ text",keyString];
                break;
            }
            [midString appendFormat:@"%@ text,",keyString];;
        }
        
        sqlString = [NSString stringWithFormat:@"%@%@%@",headerString,midString,footerString];
        [db executeUpdate:sqlString];
    }
}

//programobject表插入数据
//插入数据
+ (void) insertProgramWithObject:(id) object
{
    NSString *tableName = [NSString stringWithFormat:@"%@",[object class]];
//    if (!db)
//    {
//        [self creatTableWithObject:object];
//    }
    
//    if (![db open]) {
//        NSLog(@"数据库打开失败");
//        return;
//    }
    
    //[db setShouldCacheStatements:YES];
    
    if(![db tableExists:tableName])
    {
        [self creatTableWithObject:object];
    }
    
    //获取对象所有key
    NSArray *keys = [self propertyKeys:object];
    
    NSString *sqlString = @"";
    
    NSString *headerString = [NSString stringWithFormat:@"insert into %@ ",[object class]];
    
    NSMutableString *midKeyString=[NSMutableString stringWithCapacity:64];
    NSMutableString *midValueString=[NSMutableString stringWithCapacity:64];
    
    for (int i = 0; i < [keys count]; i++)
    {
        NSString *keyString = [NSString stringWithFormat:@"%@",[keys objectAtIndex:i]];
        
        NSString *valueString = [NSString stringWithFormat:@"%@",[object valueForKey:keyString]]; 
        
        if (i == [keys count] - 1)
        {
            [midKeyString appendFormat:@"%@",keyString];
            [midValueString appendFormat:@"\"%@\"",valueString];
            
            break;
        }
        
        [midKeyString appendFormat:@"%@,",keyString];
        [midValueString appendFormat:@"\"%@\",",[valueString stringByReplacingOccurrencesOfString:@"\"" withString:@"<<>>"]];
        
    }
    
    sqlString = [NSString stringWithFormat:@"%@(%@) values (%@)",headerString,midKeyString,midValueString];
    
    //-1表示没有数据
    sqlString = [sqlString stringByReplacingOccurrencesOfString:@"(null)" withString:@"-1"];
    NSLog(@"sqlString:%@", sqlString);
    [db executeUpdate:sqlString];
}

//program 表数据读取
//获取所有数据
+(NSMutableArray *)getDataFromTable:(id)table WithString:(NSString *) string
{
    NSString *tableName = [NSString stringWithFormat:@"%@",table];
    
    if (!db)
    {
        [self creatDatabase];
    }
    
    if (![db open])
    {
        return nil;
    }
    
    [db setShouldCacheStatements:YES];
    
    if(![db tableExists:tableName])
    {
        return nil;
    }
    
    //定义一个可变数组，用来存放查询的结果，返回给调用者
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    NSString *sqlString = [NSString stringWithFormat:@"select * from %@ where %@",tableName,string];
    //定义一个结果集，存放查询的数据
    FMResultSet *rs = [db executeQuery:sqlString];
    
    NSArray *keys = nil;
    
    //判断结果集中是否有数据，如果有则取出数据
    while ([rs next])
    {
        id tmpObject = [[NSClassFromString(tableName) alloc] init];
        //获取对象所有key
        keys = [self propertyKeys:tmpObject];
        
        for (int i = 0; i < [keys count]; i++)
        {
            NSString *keyString = [keys objectAtIndex:i];
            [tmpObject setValue:[rs stringForColumn:keyString] forKey:keyString];
        }
        
        [tableArray addObject:tmpObject];
    }
    return tableArray;
}

+ (void) deleteFromTable:(id)table WithString:(NSString *) string
{
    if ([string isEqualToString:@""] || string == nil || [string isEqualToString:@"(null)"] || !(string.length > 0))
    {
        //表示没有特殊要求，对全表进行扫描
        string = @"1=1";
    }
    
    NSString *tableName = [NSString stringWithFormat:@"%@",table];
    if (!db)
    {
        [self creatDatabase];
    }
    
    if (![db open])
    {
        return;
    }
    
    [db setShouldCacheStatements:YES];
    
    if(![db tableExists:tableName])
    {
        //如果不存在 就返回
        return;
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"delete from %@ where %@",tableName,string];
    NSLog(@"delete:%@", sqlString);
    [db executeUpdate:sqlString];
    
}

+ (void) updateTable:(id)table setString:(NSString *) setString WithString:(NSString *) string
{
    if ([string isEqualToString:@""] || string == nil || [string isEqualToString:@"(null)"])
    {
        string = @"1=1";
    }
    
    if ([setString isEqualToString:@""] || setString == nil || [setString isEqualToString:@"(null)"])
    {
        //setString为空，就返回
        return;
    }
    
    NSString *tableName = [NSString stringWithFormat:@"%@",[table class]];
    if (!db)
    {
        [self creatDatabase];
    }
    
    if (![db open])
    {
        return;
    }
    
    [db setShouldCacheStatements:YES];
    
    if(![db tableExists:tableName])
    {
        [self creatTableWithObject:[table class]];
    }
    
    NSString *sqlString1 = [NSString stringWithFormat:@"select * from %@ where %@",tableName,string];
    FMResultSet *rs = [db executeQuery:sqlString1];
    
    if (rs.next)
    {
        NSString *sqlString = [NSString stringWithFormat:@"update %@ set %@ where %@",tableName,setString,string];
        [db executeUpdate:sqlString];
    }
    else
    {
        [self insertProgramWithObject:table];
    }
}

//+ (void) updateDBWithNewVersion
//{
//    NSString *currentVer = [NSString stringWithFormat:@"vvv%@",[MetaData getCurrVer]];
//    NSString *currentJudge = [[NSUserDefaults standardUserDefaults] objectForKey:currentVer];
//    if ([currentJudge isEqualToString:@"1"] == NO) {
//        @try {
//            
//            //读取用户收藏的数据
//            NSArray *userTmpArr = [FMDBManage getDataFromTable:[userObject class] WithString:@"1=1"];
//            
//            //关闭数据库
//            if ([db open]) {
//                [db close];
//            }
//            
//            NSError *error = nil;
//            //删除数据库
//            if ([[NSFileManager defaultManager] fileExistsAtPath:[self databaseFilePath]]) {
//                
//                [[NSFileManager defaultManager] removeItemAtPath:[self databaseFilePath] error:&error];
//            }
//            if (error) {
//                DLog(@"数据库升级中 删除错误error----%@",error.description);
//            }
//            
//            // 重新写入用户登录数据
//            userObject  *userObj = [userTmpArr firstObject];
//            [FMDBManage insertProgramWithObject:userObj];
//            
//            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:currentVer];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//        @catch (NSException *exception) {
//            NSError *error = nil;
//            //删除数据库
//            if ([[NSFileManager defaultManager] fileExistsAtPath:[self databaseFilePath]]) {
//                
//                [[NSFileManager defaultManager] removeItemAtPath:[self databaseFilePath] error:&error];
//            }
//            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:currentVer];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }
//}

/**
 *  清除db文件
 */
//+ (void)clearDBFile
//{
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[FMDBManage databaseFilePath]]) {
//        [[NSFileManager defaultManager] removeItemAtPath:[FMDBManage databaseFilePath] error:nil];
//    }
//}

@end
