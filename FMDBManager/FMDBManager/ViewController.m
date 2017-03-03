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
    
    
    
    //    //删除旧数据
    //    [FMDBManage deleteFromTable:[Person class] WithString:[NSString stringWithFormat:@"1=1"]];
    //    for (Person *tmpObj in dataArr) {
    //        //添加
    //        [FMDBManage insertProgramWithObject:tmpObj];
    //
    //    }
    //
    //    //获取数据
    //    NSArray *tmpArr = [FMDBManage getDataFromTable:[Person class] WithString:@"1=1"];
    //    for (Person *tmpObj in tmpArr) {
    //        NSLog(@"tmpObj:%@", tmpObj);
    //    }
    
    
    
    NSMutableArray *dataArr3 = [NSMutableArray arrayWithCapacity:0];
    NSLog(@"dataArr2.count:%ld", dataArr2.count);
    for (News *tmpObj in dataArr2) {
        NewsCollectionObject *news = [[NewsCollectionObject alloc]init];
        news.type = @"News";
        news.title = tmpObj.title;
        news.content = tmpObj.content;
        news.imgsUrlArr = [tmpObj.imgsUrlArr componentsJoinedByString:@"#"];
        
        [dataArr3 addObject:news];
        
    }
    
    [FMDBManage deleteFromTable:[NewsCollectionObject class] WithString:@"type='News'"];
    //添加
    NSArray *newsTmpArr0 = [FMDBManage getDataFromTable:[NewsCollectionObject class] WithString:[NSString stringWithFormat:@"%@", @"type='News'"]];
    NSLog(@"newsTmpArr0.count:%ld", newsTmpArr0.count);
    
    NSLog(@"dataArr3.count:%ld", dataArr3.count);
    for (NewsCollectionObject *tmpObj in dataArr3) {
        [FMDBManage insertProgramWithObject:tmpObj];
    }
    
    
    NSArray *newsTmpArr = [FMDBManage getDataFromTable:[NewsCollectionObject class] WithString:[NSString stringWithFormat:@"%@", @"type='News'"]];
    for (NewsCollectionObject *tmp in newsTmpArr) {
        NSLog(@"tmp title:%@, content:%@, imgs:%@", tmp.title, tmp.content, tmp.imgsUrlArr);
    }
    
    
    
    /*
     iOS开发数据库篇—FMDB简单介绍
     http://www.cnblogs.com/wendingding/p/3871848.html
     
     sqlite3存储数据的类型
     NULL：标识一个NULL值
     INTERGER：整数类型
     REAL：浮点数
     TEXT：字符串
     BLOB：二进制数
     
     1.数据库创建，根据路径创建数据库
     2.打开数据库
     3.在数据库下创建表 增删改查(都需要打开关闭数据库)
     create table if not exists  tableName (con_id integer primary key  autoincrement, con_name text , con_gender text, con_qq text, con_tel text, con_photo blob)
     //blob:代表二进制
     4.关闭数据库
     
     
     增删改查
     增：
     //部分添加
     insert into ContactList(con_name, con_gender, con_qq, con_tel, con_photo)values(?,?, ?, ? , ?)
     //整体添加
     insert into tableName values()
     
     删除：
     整体删除 delete from tableName
     根据条件删除 delete from tableName where 条件
     //删除表的格式
     drop table tableName
     drop table if exists 表名
     
     修改：
     update tableName set 字段 = ‘值’ where 条件判断;
     
     查找:
     select *from tableName where 条件;
     
     select指令基本格式：
     列
     select columns from table_name [where expression];
     a、查询输出所有数据记录
     select * from table_name;
     b、限制输出数据记录数量
     select * from table_name limit 5;//跳过0条数据，取5条数据
     select * from table_name limit 数字1,数字2;
     数字1的意思是前面跳过多少条数据
     数字2的意思是本次查询多少条数据
     
     通过条件判断来查询对应的数据（例如：年龄大于等于25）
     select *from table_name where age >= 25;
     
     通过条件判断来查询对应的数据,使用like关键字（名字以l开头）
     select *from table_name where name like 'l%';
     
     
     c、升序输出某列数据记录（默认是升序）
     select * from table_name order by field asc;
     d、降序输出某列数据记录
     select * from table_name order by field desc;
     e、条件查询
     select * from table_name where expression;
     select * from table_name where field in ('val1', 'val2', 'val3');
     select * from table_name where field between val1 and val2;
     f、查询记录数目
     select count (*) from table_name;
     g、区分列数据
     select distinct field from table_name;
     有一些字段的值可能会重复出现，distinct去掉重复项，将列中各字段值单个列出。
     */
    
    
    
    
    
    /*
     在SQL结构化查询语言中，LIKE语句有着至关重要的作用。
     　　LIKE语句的语法格式是：select * from 表名 where 字段名 like 对应值（子串），它主要是针对字符型字段的，它的作用是在一个字符型字段列中检索包含对应子串的。
     　　A:% 包含零个或多个字符的任意字符串： 1、LIKE'Mc%' 将搜索以字母 Mc 开头的所有字符串（如 McBadden）。
     　　2、LIKE'%inger' 将搜索以字母 inger 结尾的所有字符串（如 Ringer、Stringer）。
     　　3、LIKE'%en%' 将搜索在任何位置包含字母 en 的所有字符串（如 Bennet、Green、McBadden）。
     　　B:_（下划线） 任何单个字符：LIKE'_heryl' 将搜索以字母 heryl 结尾的所有六个字母的名称（如 Cheryl、Sheryl）。
     　　C：[ ] 指定范围 ([a-f]) 或集合 ([abcdef]) 中的任何单个字符：
     
     1，LIKE'[CK]ars[eo]n' 将搜索下列字符串：Carsen、Karsen、Carson 和 Karson（如 Carson）。
     　　2、LIKE'[M-Z]inger' 将搜索以字符串 inger 结尾、以从 M 到 Z 的任何单个字母开头的所有名称（如 Ringer）。
     　　D：[^] 不属于指定范围 ([a-f]) 或集合 ([abcdef]) 的任何单个字符：LIKE'M[^c]%' 将搜索以字母 M 开头，并且第二个字母不是 c 的所有名称（如MacFeather）。
     　　E：* 它同于DOS命令中的通配符，代表多个字符：c*c代表cc,cBc,cbc,cabdfec等多个字符。
     　　F：？同于DOS命令中的？通配符，代表单个字符 :b?b代表brb,bFb等
     　　G：# 大致同上，不同的是代只能代表单个数字。k#k代表k1k,k8k,k0k 。
     　　F：[!] 排除 它只代表单个字符
     　　下面我们来举例说明一下：
     　　例1，查询name字段中包含有“明”字的。
     　　select * from table1 where name like '%明%'
     　　例2，查询name字段中以“李”字开头。
     　　select * from table1 where name like '李*'
     　　例3，查询name字段中含有数字的。
     　　select * from table1 where name like '%[0-9]%'
     　　例4，查询name字段中含有小写字母的。
     　　select * from table1 where name like '%[a-z]%'
     　　例5，查询name字段中不含有数字的。
     　　select * from table1 where name like '%[!0-9]%'
     　　以上例子能列出什么值来显而易见。但在这里，我们着重要说明的是通配符“*”与“%”的区别。
     　　很多朋友会问，为什么我在以上查询时有个别的表示所有字符的时候用"%"而不用“*”？先看看下面的例子能分别出现什么结果：
     　　select * from table1 where name like '*明*'
     　　select * from table1 where name like '%明%'
     　　大家会看到，前一条语句列出来的是所有的记录，而后一条记录列出来的是name字段中含有“明”的记录，所以说，当我们作字符型字段包含一个子串的查询时最好采用“%”而不用“*”,用“*”的时候只在开头或者只在结尾时，而不能两端全由“*”代替任意字符的情况下。
     */
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
