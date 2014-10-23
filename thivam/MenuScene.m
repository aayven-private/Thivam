//
//  MenuScene.m
//  thivam
//
//  Created by Ivan Borsa on 17/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "MenuScene.h"
#import "LevelDescriptor.h"

@interface MenuScene()

@property (nonatomic) PadNode *playButton;
@property (nonatomic) PadNode *historyButton;
@property (nonatomic) PadNode *randomPuzzleButton;
@property (nonatomic) PadNode *diffIncreaseButton;
@property (nonatomic) PadNode *diffDecreaseButton;

@property (nonatomic) PadNode *bgPad;

@property (nonatomic) int difficulty;

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
    
    NSNumber *currentLevel = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentLevelIndexKey];
    if (!currentLevel) {
        currentLevel = [NSNumber numberWithInt:1];
        [[NSUserDefaults standardUserDefaults] setObject:currentLevel forKey:kCurrentLevelIndexKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSNumber *currentDifficulty = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentDifficultyKey];
    if (!currentDifficulty) {
        currentDifficulty = [NSNumber numberWithInt:1];
        [[NSUserDefaults standardUserDefaults] setObject:currentDifficulty forKey:kCurrentDifficultyKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    _difficulty = currentDifficulty.intValue;
    
    LevelDescriptor *desc = [[LevelDescriptor alloc] initWithLevelIndex:currentLevel.intValue];
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _playButton = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(150, 60) andGridSize:CGSizeMake(7, 3) withPhysicsBody:NO andNodeColorCodes:@[desc.gridColorScheme] andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _playButton.name = @"playbutton";
    _playButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0 + 70);
    
    SKLabelNode *playLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    playLabel.position = CGPointMake(0, 0);
    playLabel.text = @"QUEST";
    playLabel.fontSize = 25;
    playLabel.fontColor = [UIColor blackColor];
    playLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    playLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    playLabel.name = @"playbutton";
    [_playButton addChild:playLabel];
    
    _historyButton = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(150, 60) andGridSize:CGSizeMake(7, 3) withPhysicsBody:NO andNodeColorCodes:@[desc.gridColorScheme] andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _historyButton.name = @"history";
    _historyButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0 - 70);
    
    SKLabelNode *historyLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    historyLabel.position = CGPointMake(0, 0);
    historyLabel.text = @"HISTORY";
    historyLabel.fontSize = 25;
    historyLabel.fontColor = [UIColor blackColor];
    historyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    historyLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    historyLabel.name = @"history";
    [_historyButton addChild:historyLabel];
    
    _randomPuzzleButton = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(150, 60) andGridSize:CGSizeMake(7, 3) withPhysicsBody:NO andNodeColorCodes:@[desc.gridColorScheme] andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _randomPuzzleButton.name = @"puzzle";
    _randomPuzzleButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    
    SKLabelNode *puzzleLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    puzzleLabel.position = CGPointMake(0, 10);
    puzzleLabel.text = @"FREEPLAY";
    puzzleLabel.fontSize = 22;
    puzzleLabel.fontColor = [UIColor blackColor];
    puzzleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    puzzleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    puzzleLabel.name = @"puzzle";
    [_randomPuzzleButton addChild:puzzleLabel];
    
    SKLabelNode *difficultyLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    difficultyLabel.position = CGPointMake(0, -10);
    NSString *diffName = @"";
    switch (_difficulty) {
        case 1: {
            diffName = @"Babyboy";
        } break;
        case 2: {
            diffName = @"Playground";
        } break;
        case 3: {
            diffName = @"Teenager";
        } break;
        case 4: {
            diffName = @"Adult";
        } break;
        case 5: {
            diffName = @"Hardcore";
        } break;
    }
    difficultyLabel.text = diffName;
    _randomPuzzleButton.infoLabel = difficultyLabel;
    difficultyLabel.fontSize = 22;
    difficultyLabel.fontColor = [UIColor blackColor];
    difficultyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    difficultyLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    difficultyLabel.name = @"puzzle";
    [_randomPuzzleButton addChild:difficultyLabel];
    
    _diffIncreaseButton = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(60, 60) andGridSize:CGSizeMake(7, 3) withPhysicsBody:NO andNodeColorCodes:@[desc.gridColorScheme] andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _diffIncreaseButton.name = @"diff_plus";
    _diffIncreaseButton.position = CGPointMake(self.size.width / 2.0 + 115, self.size.height / 2.0);
    
    SKLabelNode *diffIncLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    diffIncLabel.position = CGPointMake(0, 0);
    diffIncLabel.text = @"+";
    diffIncLabel.fontSize = 33;
    diffIncLabel.fontColor = [UIColor blackColor];
    diffIncLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    diffIncLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    diffIncLabel.name = @"diff_plus";
    [_diffIncreaseButton addChild:diffIncLabel];
    
    _diffDecreaseButton = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(60, 60) andGridSize:CGSizeMake(7, 3) withPhysicsBody:NO andNodeColorCodes:@[desc.gridColorScheme] andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _diffDecreaseButton.name = @"diff_minus";
    _diffDecreaseButton.position = CGPointMake(self.size.width / 2.0 - 115, self.size.height / 2.0);
    
    SKLabelNode *diffDecLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    diffDecLabel.position = CGPointMake(0, 0);
    diffDecLabel.text = @"-";
    diffDecLabel.fontSize = 33;
    diffDecLabel.fontColor = [UIColor blackColor];
    diffDecLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    diffDecLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    diffDecLabel.name = @"diff_minus";
    [_diffDecreaseButton addChild:diffDecLabel];
    
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
    
    IBActionDescriptor *levelButtonActionDesc = [[IBActionDescriptor alloc] init];
    levelButtonActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        [targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:.5 duration:.2], [SKAction scaleTo:1 duration:.2]]]];
    };
    
    IBConnectionDescriptor *leftRightConn = [[IBConnectionDescriptor alloc] init];
    leftRightConn.connectionType = kConnectionTypeLinear_leftRight;
    leftRightConn.isAutoFired = YES;
    leftRightConn.autoFireDelay = 0.05;
    
    IBConnectionDescriptor *rightLeftConn = [[IBConnectionDescriptor alloc] init];
    rightLeftConn.connectionType = kConnectionTypeLinear_rightLeft;
    rightLeftConn.isAutoFired = YES;
    rightLeftConn.autoFireDelay = 0.05;
    
    IBConnectionDescriptor *boomConn = [[IBConnectionDescriptor alloc] init];
    boomConn.connectionType = kConnectionTypeNeighbours_close;
    boomConn.isAutoFired = YES;
    boomConn.autoFireDelay = 0.05;
    
    [_randomPuzzleButton loadActionDescriptor:levelButtonActionDesc andConnectionDescriptor:leftRightConn forActionType:@"left_right"];
    [_randomPuzzleButton loadActionDescriptor:levelButtonActionDesc andConnectionDescriptor:rightLeftConn forActionType:@"right_left"];
    [_randomPuzzleButton loadActionDescriptor:boomActionDesc_button andConnectionDescriptor:boomConn forActionType:@"boom"];
    
    CGSize bgGridSize = CGSizeMake(10, 15);
    
    bgColorCodes = [NSArray arrayWithObjects:@"8D8EF2", @"787AD6", @"1E21F7", @"1D1FA1", nil];
    //_nodeCount = bgGridSize.width * bgGridSize.height;
    _bgPad = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:bgGridSize withPhysicsBody:NO andNodeColorCodes:@[desc.bgColorScheme] andInteractionMode:kInteractionMode_touch forActionType:@"boom" isInteractive:NO withborderColor:[UIColor blackColor]];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:boomActionDesc_bg andConnectionDescriptor:boomConn forActionType:@"boom"];
    _bgPad.alpha = .6;
    [self addChild:_bgPad];
    _bgPad.disableOnFirstTrigger = NO;
    
    [_playButton loadActionDescriptor:boomActionDesc_button andConnectionDescriptor:boomConn forActionType:@"boom"];
    [_historyButton loadActionDescriptor:boomActionDesc_button andConnectionDescriptor:boomConn forActionType:@"boom"];
    [self addChild:_playButton];
    [self addChild:_historyButton];
    [self addChild:_randomPuzzleButton];
    [self addChild:_diffDecreaseButton];
    [self addChild:_diffIncreaseButton];
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
        } else if ([node.name isEqualToString:@"diff_plus"] && !touched) {
            touched = YES;
            if (_difficulty < 5) {
                _difficulty++;
                for (int i=0; i<3; i++) {
                    [_randomPuzzleButton triggerNodeAtPosition:CGPointMake(0, i) forActionType:@"left_right" withUserInfo:nil forceDisable:NO withNodeReset:NO];
                }
                [self setPuzzleButtonForDifficulty];
            }
        } else if ([node.name isEqualToString:@"diff_minus"] && !touched) {
            touched = YES;
            if (_difficulty > 1) {
                _difficulty--;
                for (int i=0; i<3; i++) {
                    [_randomPuzzleButton triggerNodeAtPosition:CGPointMake(_randomPuzzleButton.gridSize.width - 1, i) forActionType:@"right_left" withUserInfo:nil forceDisable:NO withNodeReset:NO];
                }
                [self setPuzzleButtonForDifficulty];
            }
        } else if ([node.name isEqualToString:@"puzzle"] && !touched) {
            touched = YES;
            [self runAction:[SKAction sequence:@[[SKAction runBlock:^{
                [_randomPuzzleButton triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
            }], [SKAction waitForDuration:1], [SKAction runBlock:^{
                [_sceneDelegate randomPlayClicked];
            }]]]];
        }
    }
}

-(void)setPuzzleButtonForDifficulty
{
    NSString *diffName = @"";
    switch (_difficulty) {
        case 1: {
            diffName = @"Babyboy";
        } break;
        case 2: {
            diffName = @"Playground";
        } break;
        case 3: {
            diffName = @"Teenager";
        } break;
        case 4: {
            diffName = @"Adult";
        } break;
        case 5: {
            diffName = @"Hardcore";
        } break;
    }
    _randomPuzzleButton.infoLabel.text = diffName;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_difficulty] forKey:kCurrentDifficultyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
