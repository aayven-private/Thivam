//
//  IBToken.h
//  thivam
//
//  Created by Ivan Borsa on 13/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IBActionDescriptor.h"

@interface IBToken : NSObject<NSMutableCopying>

@property (nonatomic) NSString *tokenId;
@property (nonatomic) NSString *tokenType;
@property (nonatomic) CGPoint currentPosition;

@property (nonatomic) NSMutableDictionary *userInfo;

@property (nonatomic) IBActionDescriptor *enterAction;
@property (nonatomic) IBActionDescriptor *exitAction;

@property (nonatomic) BOOL isAlive;
@property (nonatomic) BOOL shouldCopyToken;

@end
