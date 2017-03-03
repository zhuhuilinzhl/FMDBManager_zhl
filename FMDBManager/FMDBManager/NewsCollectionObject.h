//
//  NewsCollectionObject.h
//  FMDBManager
//
//  Created by 朱 on 2017/2/17.
//  Copyright © 2017年 朱. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsCollectionObject : NSObject
@property (nonatomic, copy)NSString *type;

@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *content;
@property (nonatomic, copy)NSString *imgsUrlArr;
@end
