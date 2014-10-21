//
//  MenuScene.m
//  thivam
//
//  Created by Ivan Borsa on 17/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "MenuScene.h"

@interface MenuScene()

@property (nonatomic) PadNode *playButton;
@property (nonatomic) PadNode *historyButton;
@property (nonatomic) PadNode *bgPad;

@end

@implementation MenuScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.backgroundColor = [UIColor blackColor];
    
    [self initEnvironment];
}

-(void)initEnvironment
{
    [self removeAllChildren];
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _playButton = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(150, 60) andGridSize:CGSizeMake(7, 3) withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _playButton.name = @"playbutton";
    _playButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0 + 35);
    
    SKLabelNode *playLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    playLabel.position = CGPointMake(0, 0);
    playLabel.text = @"PLAY";
    playLabel.fontSize = 25;
    playLabel.fontColor = [UIColor whiteColor];
    playLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    playLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    playLabel.name = @"playbutton";
    [_playButton addChild:playLabel];
    
    _historyButton = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(150, 60) andGridSize:CGSizeMake(7, 3) withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _historyButton.name = @"history";
    _historyButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0 - 35);
    
    SKLabelNode *historyLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    historyLabel.position = CGPointMake(0, 0);
    historyLabel.text = @"HISTORY";
    historyLabel.fontSize = 25;
    historyLabel.fontColor = [UIColor whiteColor];
    historyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    historyLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    historyLabel.name = @"history";
    [_historyButton addChild:historyLabel];
    
    IBActionDescriptor *boomActionDesc_button = [[IBActionDescriptor alloc] init];
    boomActionDesc_button.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        double distX_abs = fabs((double)targetNode.columnIndex - (double)sourcePosition.x);
        double distY_abs = fabs((double)targetNode.rowIndex - (double)sourcePosition.y);
        double damping = (distX_abs + distY_abs) / ((double)_playButton.gridSize.width - 1 + (double)_playButton.gridSize.height - 1);
        
        SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.5 + damping * 0.5 duration:.3], [SKAction scaleTo:1.3 - damping * 0.3 duration:.3], [SKAction group:@[[SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
            
        }]]]]];
        [targetNode runAction:scaleSequence];
    };
    
    IBActionDescriptor *boomActionDesc_bg = [[IBActionDescriptor alloc] init];
    boomActionDesc_bg.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        double distX_abs = fabs((double)targetNode.columnIndex - (double)sourcePosition.x);
        double distY_abs = fabs((double)targetNode.rowIndex - (double)sourcePosition.y);
        double damping = (distX_abs + distY_abs) / ((double)_bgPad.gridSize.width - 1 + (double)_bgPad.gridSize.height - 1);
        
        SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.5 + damping * 0.5 duration:.3], [SKAction scaleTo:1.3 - damping * 0.3 duration:.3], [SKAction group:@[[SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
            
        }]]]]];
        [targetNode runAction:scaleSequence];
    };
    
    IBConnectionDescriptor *boomConn = [[IBConnectionDescriptor alloc] init];
    boomConn.connectionType = kConnectionTypeNeighbours_close;
    boomConn.isAutoFired = YES;
    boomConn.autoFireDelay = 0.05;
    
    CGSize bgGridSize = CGSizeMake(10, 15);
    
    bgColorCodes = [NSArray arrayWithObjects:@"8D8EF2", @"787AD6", @"1E21F7", @"1D1FA1", nil];
    //_nodeCount = bgGridSize.width * bgGridSize.height;
    _bgPad = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:bgGridSize withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_touch forActionType:@"boom" isInteractive:NO withborderColor:[UIColor blackColor]];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:boomActionDesc_bg andConnectionDescriptor:boomConn forActionType:@"boom"];
    _bgPad.alpha = .6;
    [self addChild:_bgPad];
    _bgPad.disableOnFirstTrigger = NO;
    
    [_playButton loadActionDescriptor:boomActionDesc_button andConnectionDescriptor:boomConn forActionType:@"boom"];
    [_historyButton loadActionDescriptor:boomActionDesc_button andConnectionDescriptor:boomConn forActionType:@"boom"];
    [self addChild:_playButton];
    [self addChild:_historyButton];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    BOOL touched = NO;
    NSArray *nodes = [self nodesAtPoint:positionInScene];
    for (SKNode *node in nodes) {
        if ([node.name isEqualToString:@"playbutton"] && !touched) {
            touched = YES;
            [self runAction:[SKAction sequence:@[[SKAction runBlock:^{
                [_playButton triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
            }], [SKAction waitForDuration:1], [SKAction runBlock:^{
                [_sceneDelegate playClicked];
            }]]]];
        } else if ([node.name isEqualToString:@"history"] && !touched) {
            touched = YES;
            [self runAction:[SKAction sequence:@[[SKAction runBlock:^{
                [_historyButton triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
            }], [SKAction waitForDuration:1], [SKAction runBlock:^{
                [_sceneDelegate historyClicked];
            }]]]];
        }
    }
}

@end
