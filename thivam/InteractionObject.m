//
//  InteractionObject.m
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "InteractionObject.h"

@implementation InteractionObject

-(id)initWithAction:(NSString *)action target:(GameObject *)target andSource:(GameObject *)source
{
    if (self = [super init]) {
        self.targetObject = target;
        self.actionType = action;
        self.sourceObject = source;
        [self.sourceObject.actions addObject:self];
    }
    return self;
}

@end
