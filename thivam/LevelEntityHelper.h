//
//  LevelEntityHelper.h
//  thivam
//
//  Created by Ivan Borsa on 21/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelEntity.h"

@interface LevelEntityHelper : NSObject

@property (nonatomic) int levelIndex;
@property (nonatomic) NSDictionary *levelInfo;

-(id)initWithEntity:(LevelEntity *)entity;

@end
