//
//  InteractionNode.m
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "InteractionNode.h"

@interface InteractionNode()



@end

@implementation InteractionNode

@synthesize isRunningAction = _isRunningAction;
@synthesize rowIndex = _rowIndex;
@synthesize columnIndex = _columnIndex;

-(id)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        //self.objectType = kObjectTypeInteractionNode;
        self.userInteractionEnabled = YES;
        /*self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.physicsBody.dynamic = NO;
        self.physicsBody.affectedByGravity = NO;
        self.zRotation = 0;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = 0;*/
        self.isRunningAction = NO;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate nodeTriggeredAtRow:_rowIndex andColumn:_columnIndex];
}

@end
