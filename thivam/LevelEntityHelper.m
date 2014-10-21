//
//  LevelEntityHelper.m
//  thivam
//
//  Created by Ivan Borsa on 21/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "LevelEntityHelper.h"

@implementation LevelEntityHelper

-(id)initWithEntity:(LevelEntity *)entity
{
    if (self = [super init]) {
        self.levelIndex = entity.levelIndex.intValue;
        self.levelInfo = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:entity.levelInfo];
    }
    return self;
}

@end
