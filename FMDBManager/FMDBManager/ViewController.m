//
//  ViewController.m
//  FMDBManager
//
//  Created by 朱 on 2017/3/3.
//  Copyright © 2017年 朱会林. All rights reserved.
//

#import "ViewController.h"
#import "FMDBManage.h"
#import "Person.h"
#import "News.h"
#import "NewsCollectionObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     1、  SQL中使用了where 1=1 ，很优美的解决了参数中ageValue为空时SQL语法错误的情况。但是当表中的数据量比较大的时候查询速度会非常慢，很可能会造成非常大的性能损失。
     
     “where 1=1”是表示选择全部    “where 1=2”全部不选，
     
     
     2、  加了“1=1”的过滤条件以后数据库系统就无法使用索引等查询优化策略，数据库系统将会被迫对每行数据进行扫描（也就是全表扫描）以比较此行是否满足过滤条件，因此如果数据检索对性能有比较高的要求就不要使用这种“where 1=1”的方式来偷懒。
     */
    
    
    NSMutableArray *dataArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *dataArr2 = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < 5; i++) {
        Person *person = [[Person alloc]init];
        person.name = [NSString stringWithFormat:@"name%d", i+1];
        person.gender = [NSString stringWithFormat:@"gender%d", i+1];
        [dataArr addObject:person];
        
        News *news = [[News alloc]init];
        news.title = [NSString stringWithFormat:@"title%d", i+1];
        news.content = [NSString stringWithFormat:@"content%d", i+1];
        
        news.imgsUrlArr = @[@"http://www.baidu.com1", @"http://www.baidu.com2", @"http://www.baidu.com3", @"http://www.baidu.com4", @"http://www.baidu.com5"];
        [dataArr2 addObject:news];
    }
    
    
    /*
     第一种：简单类型的model  
           直接把一种类型的model添加到存储到这种类型的表中，不对存储的model做任何改变。
     */
        //删 旧数据
        [FMDBManage deleteFromTable:[Person class] WithString:[NSString stringWithFormat:@"1=1"]];
    /*
     对于“where 1=1”，见最上面的解释，简单来说就是选择全部的意思，加上与不加上1=1，表示的意思相同。
     */
        for (Person *tmpObj in dataArr) {
            //增  如果全表只有一种类型的model，可以这么写
            [FMDBManage insertProgramWithObject:tmpObj];
    
        }
    
        //查找 数据
        NSArray *tmpArr = [FMDBManage getDataFromTable:[Person class] WithString:@"1=1"];
        for (Person *tmpObj in tmpArr) {
            NSLog(@"tmpObj:%@", tmpObj);
        }

    
    
    
    /*
     第二种：稍微复杂的model（比如：字段里有数组）。
           这个表中可以存储多种类型的model，各种model之间用一个值（比如：type）作为标记，表示不同的种类，因此需要一个转换model的过程，转换model的时候需要注意：如果原来的model中有数组可以转换为string类型存储，因为数组没办法存储。
     */
    //转换数据，把News类型的model转换为NewsCollectionObject（存储类型的model），多了一个type字段
    NSMutableArray *dataArr3 = [NSMutableArray arrayWithCapacity:0];
    for (News *tmpObj in dataArr2) {
        NewsCollectionObject *news = [[NewsCollectionObject alloc]init];
        news.type = @"News";
        news.content = tmpObj.content;
        news.imgsUrlArr = [tmpObj.imgsUrlArr componentsJoinedByString:@"#"];
        
        [dataArr3 addObject:news];
    }
    
    //删除 旧数据
    [FMDBManage deleteFromTable:[NewsCollectionObject class] WithString:@"type='News'"];
    
    NSLog(@"dataArr3.count:%ld", dataArr3.count);
    //添加
    for (NewsCollectionObject *tmpObj in dataArr3) {
        [FMDBManage insertProgramWithObject:tmpObj];
    }
    
    //查找
    NSArray *newsTmpArr = [FMDBManage getDataFromTable:[NewsCollectionObject class] WithString:[NSString stringWithFormat:@"%@", @"type='News'"]];
    //展示存储的数据
    for (NewsCollectionObject *tmp in newsTmpArr) {
        News *newsObj = [[News alloc]init];
        newsObj.title = tmp.title;
        newsObj.content = tmp.content;
        newsObj.imgsUrlArr = [tmp.imgsUrlArr componentsSeparatedByString:@"#"];
        NSLog(@"tmp title:%@, content:%@, imgs:%@", newsObj.title, newsObj.content, newsObj.imgsUrlArr);
    }

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
