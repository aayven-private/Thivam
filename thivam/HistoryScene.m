//
//  HistoryScene.m
//  thivam
//
//  Created by Ivan Borsa on 21/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "HistoryScene.h"
#import "Constants.h"
#import "PadNode.h"
#import "LevelManager.h"

@interface HistoryScene()

@property (nonatomic) NSMutableArray *levelNodes;
@property (nonatomic) int currentLevelIndex;
@property (nonatomic) PadNode *menuButton;
@property (nonatomic) PadNode *bgPad;

@end

@implementation HistoryScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.backgroundColor = [UIColor blackColor];
    self.levelNodes = [NSMutableArray array];
    
    [self removeAllChildren];
    
    NSNumber *userLevelIndex = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentLevelIndexKey];
    if (!userLevelIndex) {
        userLevelIndex = [NSNumber numberWithInt:1];
    }
    _currentLevelIndex = userLevelIndex.intValue - 1;
    
    //!!!!
    //_currentLevelIndex = 7;
    
    //_currentEndIndex = _currentLevelIndex;
    
    [self initEnvironment];
}

-(void)initEnvironment
{
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftRecognizer.numberOfTouchesRequired = 1;
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftRecognizer];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightRecognizer.numberOfTouchesRequired = 1;
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightRecognizer];
    
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
    
    _bgPad = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:bgGridSize withPhysicsBody:NO andNodeColorCodes:@[@"8D8EF2", @"787AD6", @"1E21F7", @"1D1FA1"] andInteractionMode:kInteractionMode_touch forActionType:@"boom" isInteractive:NO withborderColor:[UIColor blackColor]];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:boomActionDesc_bg andConnectionDescriptor:boomConn forActionType:@"boom"];
    _bgPad.alpha = .6;
    [self addChild:_bgPad];
    _bgPad.disableOnFirstTrigger = NO;
    
    _menuButton = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(150, 60) andGridSize:CGSizeMake(7, 3) withPhysicsBody:NO andNodeColorCodes:@[@"FF0000"] andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _menuButton.name = @"menu";
    _menuButton.position = CGPointMake(self.size.width / 2, self.size.height - 50);
    
    IBActionDescriptor *boomActionDesc_button = [[IBActionDescriptor alloc] init];
    boomActionDesc_button.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        double distX_abs = fabs((double)targetNode.columnIndex - (double)sourcePosition.x);
        double distY_abs = fabs((double)targetNode.rowIndex - (double)sourcePosition.y);
        double damping = (distX_abs + distY_abs) / ((double)_menuButton.gridSize.width - 1 + (double)_menuButton.gridSize.height - 1);
        
        SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.5 + damping * 0.5 duration:.3], [SKAction scaleTo:1.3 - damping * 0.3 duration:.3], [SKAction group:@[[SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
            
        }]]]]];
        [targetNode runAction:scaleSequence];
    };
    
    
    SKLabelNode *menuLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    menuLabel.position = CGPointMake(0, 0);
    menuLabel.text = @"MENU";
    menuLabel.fontSize = 25;
    menuLabel.fontColor = [UIColor whiteColor];
    menuLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    menuLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    menuLabel.name = @"menu";
    [_menuButton addChild:menuLabel];

    [_menuButton loadActionDescriptor:boomActionDesc_button andConnectionDescriptor:boomConn forActionType:@"boom"];
    [self addChild:_menuButton];
    
    for (int i=0; i<4; i++) {
        PadNode *levelNode = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(80, 80) andGridSize:CGSizeMake(3, 3) withPhysicsBody:NO andNodeColorCodes:@[@"FF0000"] andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
        levelNode.hidden = YES;
        SKLabelNode *indexLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
        indexLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        indexLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        indexLabel.fontSize = 22;
        indexLabel.position = CGPointMake(0, 0);
        indexLabel.fontColor = [UIColor blackColor];
        indexLabel.userInteractionEnabled = NO;
        levelNode.infoLabel = indexLabel;
        [levelNode addChild:levelNode.infoLabel];
        levelNode.name = @"levelnode";
        [_levelNodes addObject:levelNode];
        [self addChild:levelNode];
        
        IBActionDescriptor *boomActionDesc_levelNode = [[IBActionDescriptor alloc] init];
        boomActionDesc_levelNode.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
            GameObject *targetNode = (GameObject *)target;
            CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
            double distX_abs = fabs((double)targetNode.columnIndex - (double)sourcePosition.x);
            double distY_abs = fabs((double)targetNode.rowIndex - (double)sourcePosition.y);
            double damping = (distX_abs + distY_abs) / ((double)levelNode.gridSize.width - 1 + (double)levelNode.gridSize.height - 1);
            
            SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.5 + damping * 0.5 duration:.3], [SKAction scaleTo:1.3 - damping * 0.3 duration:.3], [SKAction group:@[[SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
                
            }]]]]];
            [targetNode runAction:scaleSequence];
        };
        
        [levelNode loadActionDescriptor:boomActionDesc_levelNode andConnectionDescriptor:boomConn forActionType:@"boom"];
    }
    [self initGridWithAnimation:NO];
    //int numOfNodes = (currentLevelIndex.intValue < 4 ? currentLevelIndex.intValue : 4);
}

-(void)initGridWithAnimation:(BOOL)withAnimation
{
    int numOfNodes = _currentEndIndex % 4;
    if (numOfNodes == 0 && _currentLevelIndex >= 4) {
        numOfNodes = 4;
    }
    
    for (int i=numOfNodes; i>=1; i--) {
        PadNode *levelNode = [_levelNodes objectAtIndex:i - 1];
        levelNode.hidden = NO;
        int levelIndex = _currentEndIndex - (numOfNodes - i);
        levelNode.nodeIndex = levelIndex;
        
        levelNode.infoLabel.text = [NSString stringWithFormat:@"%d", levelIndex];
        
        CGPoint blockPosition;
        switch (i) {
            case 4: {
                blockPosition = CGPointMake(self.size.width / 2 + 80, self.size.height / 2 - 80);
            } break;
            case 3: {
                blockPosition = CGPointMake(self.size.width / 2 - 80, self.size.height / 2 - 80);
            } break;
            case 2: {
                blockPosition = CGPointMake(self.size.width / 2 + 80, self.size.height / 2 + 80);
            } break;
            case 1: {
                blockPosition = CGPointMake(self.size.width / 2 - 80, self.size.height / 2 + 80);
            } break;
        }
        
        if (withAnimation) {
            [levelNode runAction:[SKAction group:@[[SKAction fadeAlphaTo:1 duration:.3], [SKAction moveTo:blockPosition duration:.3], [SKAction scaleTo:1 duration:.3]]]];
        } else {
            levelNode.alpha = 1;
            levelNode.position = blockPosition;
        }
        
    }
    for (int i=numOfNodes+1; i<5; i++) {
        PadNode *invisibleNode = [_levelNodes objectAtIndex:i - 1];
        invisibleNode.hidden = YES;
        CGPoint blockPosition;
        switch (i) {
            case 4: {
                blockPosition = CGPointMake(self.size.width / 2 + 80, self.size.height / 2 - 80);
            } break;
            case 3: {
                blockPosition = CGPointMake(self.size.width / 2 - 80, self.size.height / 2 - 80);
            } break;
            case 2: {
                blockPosition = CGPointMake(self.size.width / 2 + 80, self.size.height / 2 + 80);
            } break;
            case 1: {
                blockPosition = CGPointMake(self.size.width / 2 - 80, self.size.height / 2 + 80);
            } break;
        }
        invisibleNode.position = blockPosition;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    BOOL touched = NO;
    NSArray *nodes = [self nodesAtPoint:positionInScene];
    for (SKNode *node in nodes) {
        if ([node.name isEqualToString:@"menu"] && !touched) {
            touched = YES;
            [_menuButton triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
            [_menuButton runAction:[SKAction sequence:@[[SKAction waitForDuration:.8], [SKAction runBlock:^{
                [_sceneDelegate menuClicked];
            }]]]];
        } else if ([node.name isEqualToString:@"levelnode"] && !touched) {
            touched = YES;
            PadNode *clickedLevel = (PadNode *)node;
            LevelManager *manager = [[LevelManager alloc] init];
            LevelEntityHelper *level = [manager getLevelForIndex:clickedLevel.nodeIndex];
            if (level) {
                [clickedLevel triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
                [clickedLevel runAction:[SKAction sequence:@[[SKAction waitForDuration:.8], [SKAction runBlock:^{
                    [_sceneDelegate historyLevelClicked:level];
                }]]]];
            }
        }
    }
}

-(IBAction)swipeRight:(UISwipeGestureRecognizer *)sender
{
    if (_currentEndIndex <= 4) {
        return;
    }
    int currentNodeCount = _currentEndIndex % 4;
    if (currentNodeCount == 0) {
        _currentEndIndex -= 4;
    } else {
        _currentEndIndex -= currentNodeCount;
    }
    if (_currentEndIndex < 4) {
        _currentEndIndex = 4;
    }
    for (PadNode *levelNode in _levelNodes) {
        [levelNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction fadeAlphaTo:0 duration:.3], [SKAction moveTo:CGPointMake(self.size.width / 2.0, self.size.height / 2.0) duration:.3], [SKAction scaleTo:.1 duration:.3]]], [SKAction runBlock:^{
            
        }]]]];
    }
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:.6], [SKAction runBlock:^{
        
        [self initGridWithAnimation:YES];
    }]]]];
}

-(IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender
{
    if (_currentEndIndex >= _currentLevelIndex) {
        return;
    }
    _currentEndIndex += 4;
    if (_currentEndIndex > _currentLevelIndex) {
        _currentEndIndex = _currentLevelIndex;
    }
    for (PadNode *levelNode in _levelNodes) {
        [levelNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction fadeAlphaTo:0 duration:.3], [SKAction moveTo:CGPointMake(self.size.width / 2.0, self.size.height / 2.0) duration:.3], [SKAction scaleTo:.1 duration:.3]]], [SKAction runBlock:^{
            
        }]]]];
    }
    
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:.6], [SKAction runBlock:^{
        
        [self initGridWithAnimation:YES];

    }]]]];
}

@end
