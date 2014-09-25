//
//  InteractionObject.h
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"

@interface InteractionObject : NSObject

-(id)initWithAction:(NSString *)action target:(GameObject *)target andSource:(GameObject *)source;

@property (nonatomic) GameObject *sourceObject;
@property (nonatomic) GameObject *targetObject;
@property (nonatomic) NSString *actionType;

@end
