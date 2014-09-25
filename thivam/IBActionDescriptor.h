//
//  IBActionDescriptor.h
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IBActionNodeActor;

typedef void(^nodeAction)(id<IBActionNodeActor>target, NSDictionary *userInfo);

@interface IBActionDescriptor : NSObject

@property (copy) nodeAction action;
@property (nonatomic) NSDictionary *userInfo;

@end