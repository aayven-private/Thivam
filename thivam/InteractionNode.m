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
        self.userInteractionEnabled = NO;
        self.isActionSource = NO;
        self.isBlocker = NO;

        SKSpriteNode *innerNode = [[SKSpriteNode alloc] initWithColor:color size:CGSizeMake(size.width - 5, size.height - 5)];
        innerNode.position = CGPointMake(0, 0);
        [self addChild:innerNode];
        
        self.infoLabel = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Medium"];
        self.infoLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        self.infoLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.infoLabel.fontSize = 18;
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
    [self.delegate nodeTriggeredAtRow:_rowIndex andColumn:_columnIndex forActionType:_userActionType withUserInfo:nil];
}

@end
