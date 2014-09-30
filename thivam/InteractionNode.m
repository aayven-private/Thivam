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

@synthesize rowIndex = _rowIndex;
@synthesize columnIndex = _columnIndex;
@synthesize userActionType = _userActionType;
@synthesize color1 = _color1;
@synthesize color2 = _color2;

-(id)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        //self.objectType = kObjectTypeInteractionNode;
        self.userInteractionEnabled = NO;
        /*self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.physicsBody.dynamic = NO;
        self.physicsBody.affectedByGravity = NO;
        self.zRotation = 0;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = 0;*/
        //self.isRunningAction = NO;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*if (_color1 && _color2) {
        if ([_color1 isEqual:_color2]) {
            NSLog(@"MATCH");
            [self.delegate nodeActionTaken:@"match" withUserInfo:[NSDictionary dictionaryWithObjects:@[[NSValue valueWithCGPoint:CGPointMake(_columnIndex, _rowIndex)], _color1] forKeys:@[@"position", @"matchcolor"]]];
        }
    }*/
    
    [self.delegate nodeActionTaken:@"match" withUserInfo:[NSDictionary dictionaryWithObjects:@[[NSValue valueWithCGPoint:CGPointMake(_columnIndex, _rowIndex)], [UIColor blueColor]] forKeys:@[@"position", @"matchcolor"]]];
    
    //NSLog(@"%@", NSStringFromCGPoint(CGPointMake(_rowIndex, _columnIndex)));
    //[self.delegate nodeTriggeredAtRow:_rowIndex andColumn:_columnIndex forActionType:_userActionType];
}

@end
