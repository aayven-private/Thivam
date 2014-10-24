//
//  InteractionNode.m
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "InteractionNode.h"

@interface InteractionNode()

@property (nonatomic) BOOL isLongTap;
@property (nonatomic) NSTimer *longTapTimer;

@end

@implementation InteractionNode

@synthesize rowIndex = _rowIndex;
@synthesize columnIndex = _columnIndex;
@synthesize userActionType = _userActionType;
@synthesize color1 = _color1;
@synthesize color2 = _color2;
@synthesize isActionSource = _isActionSource;
@synthesize isBlocker = _isBlocker;

-(id)initWithColor:(UIColor *)color size:(CGSize)size andBorderColor:(UIColor *)borderColor
{
    if (borderColor) {
        self = [super initWithColor:borderColor size:size];
    } else {
        self = [super initWithColor:color size:size];
    }
    if (self) {
        self.userInteractionEnabled = NO;
        self.isActionSource = NO;
        self.isBlocker = NO;
        
        if (borderColor) {
            _innerNode = [[SKSpriteNode alloc] initWithColor:color size:CGSizeMake(size.width - 5, size.height - 5)];
            _innerNode.position = CGPointMake(0, 0);
            [self addChild:_innerNode];
        }
        
        self.valueLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
        self.valueLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        self.valueLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        self.valueLabel.fontSize = 22;
        self.valueLabel.position = CGPointMake(0, 0);
        self.valueLabel.fontColor = [UIColor blackColor];
        self.valueLabel.text = @"0";
        [self addChild:self.valueLabel];
        
        self.isLongTap = NO;
        self.nodeValue = 0;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _longTapTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(longTap:) userInfo:nil repeats:NO];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_longTapTimer invalidate];
    _longTapTimer = nil;
    if (_isLongTap) {
        [self.delegate nodeTriggeredAtRow:_rowIndex andColumn:_columnIndex forActionType:[NSString stringWithFormat:@"%@_touchup_longtap", _userActionType] withUserInfo:nil];
    } else {
        [self.delegate nodeTriggeredAtRow:_rowIndex andColumn:_columnIndex forActionType:[NSString stringWithFormat:@"%@_touchup", _userActionType] withUserInfo:nil];
    }
    _isLongTap = NO;
}

-(void)longTap:(NSTimer *)sender
{
    _isLongTap = YES;
    [self.delegate nodeTriggeredAtRow:_rowIndex andColumn:_columnIndex forActionType:[NSString stringWithFormat:@"%@_longtap", _userActionType] withUserInfo:nil];
}

@end
