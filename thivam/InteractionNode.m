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
@synthesize isActionSource = _isActionSource;
@synthesize isBlocker = _isBlocker;

-(id)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:[UIColor blackColor] size:size]) {
        //self.objectType = kObjectTypeInteractionNode;
        self.userInteractionEnabled = NO;
        self.isActionSource = NO;
        self.isBlocker = NO;
        /*self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.physicsBody.dynamic = NO;
        self.physicsBody.affectedByGravity = NO;
        self.zRotation = 0;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = 0;*/
        //self.isRunningAction = NO;

        SKSpriteNode *innerNode = [[SKSpriteNode alloc] initWithColor:color size:CGSizeMake(size.width - 5, size.height - 5)];
        innerNode.position = CGPointMake(0, 0);
        [self addChild:innerNode];
        
        self.infoLabel = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Medium"];
        self.infoLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        self.infoLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.infoLabel.fontSize = 15;
        self.infoLabel.position = CGPointMake(0, 0);
        self.infoLabel.fontColor = [UIColor blackColor];
        self.infoLabel.text = @"0";
        [self addChild:self.infoLabel];
        
        self.nodeValue = 0;
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
    
    //[self.delegate nodeActionTaken:@"match" withUserInfo:[NSDictionary dictionaryWithObjects:@[[NSValue valueWithCGPoint:CGPointMake(_columnIndex, _rowIndex)], [UIColor redColor]] forKeys:@[@"position", @"matchcolor"]]];
    
    [self.delegate nodeTriggeredAtRow:_rowIndex andColumn:_columnIndex forActionType:_userActionType withUserInfo:nil];
    
    //NSLog(@"%@", NSStringFromCGPoint(CGPointMake(_rowIndex, _columnIndex)));
    //[self.delegate nodeTriggeredAtRow:_rowIndex andColumn:_columnIndex forActionType:_userActionType withUserInfo:[NSMutableDictionary dictionary]];
}

@end
