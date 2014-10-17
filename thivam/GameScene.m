//
//  GameScene.m
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "GameScene.h"
#import <CoreMotion/CoreMotion.h>
#import "IBMatrix.h"
#import "CommonTools.h"
#import "IBActionPad.h"
#import "PadNode.h"
#import "SimulationNode.h"

@interface GameScene()

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval currentBgTriggerInterval;
@property (nonatomic) NSTimeInterval bgTriggerInterval;

@property (nonatomic) PadNode *gamePad;
@property (nonatomic) PadNode *bgPad;

@property (atomic) int actionFinishedCount;
@property (nonatomic) int nodeCount;

@property (nonatomic) CGSize gridSize;

@property (nonatomic) NSMutableArray *checkIds;

@property (nonatomic) int brickPlaceCheckCount;
@property (nonatomic) BOOL currentCheckSpotGood;

@property (nonatomic) CGPoint nextBrickSpot;

@property (nonatomic) NSString *currentGameType;

@property (nonatomic) IBToken *playerToken;

@property (nonatomic) NSMutableSet *enemies;

@property (nonatomic) BOOL isInVerticalOrder;
@property (nonatomic) BOOL isInHorizontallOrder;
@property (nonatomic) BOOL isFlipping;

@property (nonatomic) CGPoint referencePoint;
@property (nonatomic) CGPoint simulationReferencePoint;

@property (nonatomic) IBActionPad *simulationPad;
@property (nonatomic) int simulationCount;

@property (nonatomic) NSDictionary *currentLevelInfo;

@property (nonatomic) BOOL levelCompleted;

@property (nonatomic) PadNode *resetNode;
@property (nonatomic) PadNode *menuButton;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.actionFinishedCount = 0;
    self.nodeCount = 0;
    self.checkIds = [NSMutableArray array];
    self.nextBrickSpot = CGPointMake(-1, -1);
    self.enemies = [NSMutableSet set];
    self.brickPlaceCheckCount = 0;
    self.currentCheckSpotGood = YES;
    
    self.referencePoint = CGPointMake(2, 2);
    
    [self initEnvironment];
}

-(void)initEnvironment
{
    [self removeAllChildren];
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.contactTestBitMask = kObjectCategoryActionPad;
    self.physicsBody.categoryBitMask = kObjectCategoryFrame;
    self.physicsBody.collisionBitMask = kObjectCategoryActionPad;
    self.physicsWorld.contactDelegate = self;
    
    _currentBgTriggerInterval = 0;
    _bgTriggerInterval = 5;
    
    IBActionDescriptor *boomActionDesc = [[IBActionDescriptor alloc] init];
    boomActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
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
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"8D8EF2", @"787AD6", @"1E21F7", @"1D1FA1", nil];
    //_nodeCount = bgGridSize.width * bgGridSize.height;
    _bgPad = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:bgGridSize withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:[UIColor blackColor]];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:boomActionDesc andConnectionDescriptor:boomConn forActionType:@"boom"];
    _bgPad.alpha = .6;
    [self addChild:_bgPad];
    _bgPad.disableOnFirstTrigger = NO;
    _bgPad.name = @"permanent";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self simulateGameGridWithGridSize:CGSizeMake(4, 4) andNumberOfClicks:2 andNumberOfTargets:2 withReferenceNode:YES];
    });
}

-(void)simulateGameGridWithGridSize:(CGSize)gridSize andNumberOfClicks:(int)clickNum andNumberOfTargets:(int)targetNum withReferenceNode:(BOOL)withReference
{
    __block NSMutableDictionary *nodes = [NSMutableDictionary dictionary];
    __block int actualSimulationCount = 0;
    _simulationCount = clickNum * gridSize.height * gridSize.width;
    __block NSMutableSet *targetPoints = [NSMutableSet set];
    __block NSMutableArray *clicks = [NSMutableArray array];
    IBActionDescriptor *boomActionDesc = [[IBActionDescriptor alloc] init];
    boomActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        SimulationNode *targetNode = (SimulationNode *)target;
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        
        int distX = (int)targetNode.columnIndex - (int)sourcePosition.x;
        int distY = (int)targetNode.rowIndex - (int)sourcePosition.y;
        
        int distX_ref = targetNode.columnIndex - _simulationReferencePoint.x;
        int distY_ref = targetNode.rowIndex - _simulationReferencePoint.y;

        targetNode.nodeValue += withReference ? (distX_ref + distY_ref) + (distX + distY) : (distX + distY);
        
        actualSimulationCount++;
        if (_simulationCount == actualSimulationCount) {
            NSMutableDictionary *targetValues = [NSMutableDictionary dictionary];
            
            for (NSValue *targetPoint in targetPoints) {
                CGPoint tp = targetPoint.CGPointValue;
                SimulationNode *node = [nodes objectForKey:[NSString stringWithFormat:@"%d%d", (int)tp.x, (int)tp.y]];
                [targetValues setObject:[NSNumber numberWithInt:node.nodeValue] forKey:[NSString stringWithFormat:@"%d%d", node.columnIndex, node.rowIndex]];
            }
            
            NSMutableDictionary *levelInfo = [NSMutableDictionary dictionary];
            if (withReference) {
                [levelInfo setObject:[NSValue valueWithCGPoint:_simulationReferencePoint] forKey:@"reference_point"];
            }
            [levelInfo setObject:targetValues forKey:@"targets"];
            [levelInfo setObject:clicks forKey:@"clicks"];
            [levelInfo setObject:[NSValue valueWithCGSize:gridSize] forKey:@"grid_size"];
            [self saveLevel:levelInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadLevel:levelInfo];
            });
            //[self simulateGameGridWithGridSize:gridSize andNumberOfClicks:clickNum andNumberOfTargets:targetNum];
        }
    };
    
    IBConnectionDescriptor *boomConn = [[IBConnectionDescriptor alloc] init];
    boomConn.connectionType = kConnectionTypeNeighbours_close;
    boomConn.isAutoFired = YES;
    boomConn.autoFireDelay = 0;
    
    _simulationPad = [[IBActionPad alloc] initGridWithSize:gridSize andNodeInitBlock:^id<IBActionNodeActor>(int row, int column){
        SimulationNode *node = [[SimulationNode alloc] init];
        node.columnIndex = column;
        node.rowIndex = row;
        [nodes setObject:node forKey:[NSString stringWithFormat:@"%d%d", column, row]];
        return node;
    } andActionHeapSize:30];
    [_simulationPad createGridWithNodesActivated:YES];
    [_simulationPad.unifiedActionDescriptors setObject:@[boomActionDesc] forKey:@"boom"];
    [_simulationPad loadConnectionMapWithDescriptor:boomConn forActionType:@"boom"];
    
    
    
    int columnIndex = [CommonTools getRandomNumberFromInt:0 toInt:gridSize.width - 1];
    int rowIndex = [CommonTools getRandomNumberFromInt:0 toInt:gridSize.height - 1];
    _simulationReferencePoint = CGPointMake(columnIndex, rowIndex);
    //_simulationReferencePoint = CGPointMake(2, 2);
    
    NSMutableArray *allPoints = [NSMutableArray array];
    for (int i=0; i<gridSize.width; i++) {
        for (int j=0; j<gridSize.height; j++) {
            [allPoints addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
        }
    }
    
    for (int i=0; i<targetNum; i++) {
        int randomIndex = [CommonTools getRandomNumberFromInt:0 toInt:allPoints.count - 1];
        
        NSValue *point = [allPoints objectAtIndex:randomIndex];
        
        [targetPoints addObject:point];
        
        [allPoints removeObject:point];
    }
    
    for (int i=0; i<clickNum; i++) {
        int columnIndex = [CommonTools getRandomNumberFromInt:0 toInt:gridSize.width - 1];
        int rowIndex = [CommonTools getRandomNumberFromInt:0 toInt:gridSize.height - 1];
        CGPoint clickPoint = CGPointMake(columnIndex, rowIndex);
        [_simulationPad triggerNodeAtPosition:clickPoint forActionType:@"boom" withuserInfo:nil withNodeReset:NO];
        [clicks addObject:[NSValue valueWithCGPoint:clickPoint]];
    }
}

-(void)loadLevel:(NSDictionary *)levelInfo
{
    for (SKNode *node in self.children) {
        if (![node.name isEqual:@"permanent"]) {
            [node removeFromParent];
        }
    }
    //[self removeAllChildren];
    
    _levelCompleted = NO;
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _resetNode = [[PadNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(150, 60) andGridSize:CGSizeMake(7, 3) withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _resetNode.name = @"reset";
    _resetNode.position = CGPointMake(self.size.width / 2, 50);
    
    SKLabelNode *resetLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    resetLabel.position = CGPointMake(0, 0);
    resetLabel.text = @"RESET";
    resetLabel.fontSize = 25;
    resetLabel.fontColor = [UIColor whiteColor];
    resetLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    resetLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    resetLabel.name = @"reset";
    [_resetNode addChild:resetLabel];
    
    IBActionDescriptor *boomActionDesc_button = [[IBActionDescriptor alloc] init];
    boomActionDesc_button.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        double distX_abs = fabs((double)targetNode.columnIndex - (double)sourcePosition.x);
        double distY_abs = fabs((double)targetNode.rowIndex - (double)sourcePosition.y);
        double damping = (distX_abs + distY_abs) / ((double)_resetNode.gridSize.width - 1 + (double)_resetNode.gridSize.height - 1);
        
        SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.5 + damping * 0.5 duration:.3], [SKAction scaleTo:1.3 - damping * 0.3 duration:.3], [SKAction group:@[[SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
            
        }]]]]];
        [targetNode runAction:scaleSequence];
    };
    
    _menuButton = [[PadNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(150, 60) andGridSize:CGSizeMake(7, 3) withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _menuButton.name = @"menu";
    _menuButton.position = CGPointMake(self.size.width / 2, self.size.height - 50);
    
    SKLabelNode *menuLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    menuLabel.position = CGPointMake(0, 0);
    menuLabel.text = @"MENU";
    menuLabel.fontSize = 25;
    menuLabel.fontColor = [UIColor whiteColor];
    menuLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    menuLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    menuLabel.name = @"menu";
    [_menuButton addChild:menuLabel];
    
    IBConnectionDescriptor *boomConn = [[IBConnectionDescriptor alloc] init];
    boomConn.connectionType = kConnectionTypeNeighbours_close;
    boomConn.isAutoFired = YES;
    boomConn.autoFireDelay = 0.05;
    
    [_resetNode loadActionDescriptor:boomActionDesc_button andConnectionDescriptor:boomConn forActionType:@"boom"];
    [self addChild:_resetNode];
    
    [_menuButton loadActionDescriptor:boomActionDesc_button andConnectionDescriptor:boomConn forActionType:@"boom"];
    [self addChild:_menuButton];
    
    /*_resetNode = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(150, 60)];
    _resetNode.position = CGPointMake(self.size.width / 2, 50);
    _resetNode.name = @"reset";
    [self addChild:_resetNode];
    SKSpriteNode *innerNode = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(140, 50)];
    SKLabelNode *resetLabel = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Medium"];
    [_resetNode addChild:innerNode];
    resetLabel.fontColor = [UIColor blackColor];
    resetLabel.fontSize = 20;
    resetLabel.text = @"Reset";
    resetLabel.position = CGPointMake(0, 0);
    resetLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    resetLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    [innerNode addChild:resetLabel];*/
    
    _currentLevelInfo = levelInfo;
    
    __block NSMutableSet *matchingNodes = [NSMutableSet set];
    NSValue *refPoint_val = [levelInfo objectForKey:@"reference_point"];
    if (refPoint_val) {
        _referencePoint = refPoint_val.CGPointValue;
    } else {
        _referencePoint = CGPointMake(-1, -1);
    }
    
    NSValue *gridSize_val = [levelInfo objectForKey:@"grid_size"];
    _gridSize = gridSize_val.CGSizeValue;
    
    __block NSDictionary *targetValues = [levelInfo objectForKey:@"targets"];
    
    IBActionDescriptor *boomActionDesc = [[IBActionDescriptor alloc] init];
    boomActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //if (!targetNode.isActionSource && !targetNode.isBlocker) {
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        double distX_abs = fabs((double)targetNode.columnIndex - (double)sourcePosition.x);
        double distY_abs = fabs((double)targetNode.rowIndex - (double)sourcePosition.y);
        double damping = (distX_abs + distY_abs) / ((double)_gamePad.gridSize.width - 1 + (double)_gamePad.gridSize.height - 1);
        
        int distX = (int)targetNode.columnIndex - (int)sourcePosition.x;
        int distY = (int)targetNode.rowIndex - (int)sourcePosition.y;
        
        int distX_ref = targetNode.columnIndex - _referencePoint.x;
        int distY_ref = targetNode.rowIndex - _referencePoint.y;

        int valueDiff = CGPointEqualToPoint(_referencePoint, CGPointMake(-1, -1)) ? (distX + distY) : ((distX_ref + distY_ref) + (distX + distY));
        
        targetNode.zPosition = 100 - damping * 10;
        ((InteractionNode *)targetNode).nodeValue += valueDiff;

        SKLabelNode *helperLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
        helperLabel.fontSize = 18;
        helperLabel.fontColor = [UIColor whiteColor];
        NSString *helperText = valueDiff <= 0 ? [NSString stringWithFormat:@"%d", valueDiff] : [NSString stringWithFormat:@"+%d", valueDiff];
        helperLabel.text = helperText;
        helperLabel.position = CGPointMake(self.size.width / 2 + targetNode.position.x, self.size.height / 2 + targetNode.position.y);
        helperLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        helperLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        helperLabel.zPosition = 999;
        [self addChild:helperLabel];
        [helperLabel runAction:[SKAction sequence:@[[SKAction group:@[[SKAction moveByX:0 y:30 duration:1.6], [SKAction fadeAlphaTo:0 duration:1.6]]], [SKAction removeFromParent]]]];
        
        SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.1 + damping * 0.9 duration:.3], [SKAction scaleTo:1.5 - damping * 0.5 duration:.3], [SKAction group:@[[SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
            ((InteractionNode *)targetNode).infoLabel.text = [NSString stringWithFormat:@"%d", ((InteractionNode *)targetNode).nodeValue];
        }]]]]];
        [targetNode runAction:scaleSequence];
        
        if (targetNode.isActionSource) {
            if (((InteractionNode *)targetNode).nodeValue == 0) {
                if (![matchingNodes containsObject:targetNode]) {
                    [matchingNodes addObject:targetNode];
                }
            } else {
                if ([matchingNodes containsObject:targetNode]) {
                    [matchingNodes removeObject:targetNode];
                }
            }
        }
        if (matchingNodes.count == targetValues.allKeys.count && !_levelCompleted) {
            _levelCompleted = YES;
            CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
            [_resetNode runAction:[SKAction fadeAlphaTo:0.0 duration:1.3]];
            [_menuButton runAction:[SKAction fadeAlphaTo:0.0 duration:1.3]];
            [self runAction:[SKAction sequence:@[[SKAction waitForDuration:.8], [SKAction runBlock:^{
                [_gamePad triggerNodeAtPosition:sourcePosition forActionType:@"next_level" withUserInfo:nil forceDisable:NO withNodeReset:NO];
            }], [SKAction waitForDuration:1], [SKAction runBlock:^{
                [self simulateGameGridWithGridSize:_gridSize andNumberOfClicks:2 andNumberOfTargets:targetValues.allKeys.count withReferenceNode:!CGPointEqualToPoint(_referencePoint, CGPointMake(-1, -1))];
            }]]]];
        }
    };
    //_gridSize = CGSizeMake(4, 4);
    
    bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _nodeCount = _gridSize.width * _gridSize.height;
    _gamePad = [[PadNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(300, 300) andGridSize:_gridSize withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_touch forActionType:@"boom" isInteractive:YES withborderColor:[UIColor blackColor]];
    _gamePad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_gamePad loadActionDescriptor:boomActionDesc andConnectionDescriptor:boomConn forActionType:@"boom"];
    [self loadNextLevelEffect];
    _gamePad.alpha = 0;
    _resetNode.alpha = 0;
    _menuButton.alpha = 0;
    [self addChild:_gamePad];
    [_gamePad runAction:[SKAction fadeAlphaTo:1.0 duration:.3]];
    [_resetNode runAction:[SKAction fadeAlphaTo:1.0 duration:.3]];
    [_menuButton runAction:[SKAction fadeAlphaTo:1.0 duration:.3]];
    _gamePad.disableOnFirstTrigger = NO;
    
    if (!CGPointEqualToPoint(_referencePoint, CGPointMake(-1, -1))) {
        GameObject *refNode = [_gamePad getNodeAtPosition:_referencePoint];
        refNode.color = [UIColor blueColor];
    }
    
    for (int column = 0; column < _gamePad.gridSize.width; column++) {
        for (int row = 0; row < _gamePad.gridSize.height; row++) {
            GameObject *node = [_gamePad getNodeAtPosition:CGPointMake(column, row)];
            
            if ([[targetValues allKeys] containsObject:[NSString stringWithFormat:@"%d%d", node.columnIndex, node.rowIndex]]) {
                NSNumber *targetValue = [targetValues objectForKey:[NSString stringWithFormat:@"%d%d", node.columnIndex, node.rowIndex]];

                ((InteractionNode *)node).infoLabel.hidden = NO;
                ((InteractionNode *)node).infoLabel.text = [NSString stringWithFormat:@"%d", -targetValue.intValue];
                ((InteractionNode *)node).nodeValue = -targetValue.intValue;
                node.isActionSource = YES;
                
            } else {
                ((InteractionNode *)node).infoLabel.hidden = YES;
                node.isActionSource = NO;
            }
        }
    }
}

-(void)saveLevel:(NSDictionary *)levelDescription
{
    NSLog(@"%@", levelDescription);
}

-(void)loadNextLevelEffect
{
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        
        GameObject *sourceNode = [_gamePad getNodeAtPosition:sourcePosition];
        
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction moveTo:sourceNode.position duration:.5], [SKAction fadeAlphaTo:0.0 duration:.5]]], [SKAction runBlock:^{
            
        }]]]];
    };
    
    IBConnectionDescriptor *bgConn = [[IBConnectionDescriptor alloc] init];
    bgConn.connectionType = kConnectionTypeNeighbours_close;
    bgConn.isAutoFired = YES;
    bgConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:50], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    
    bgConn.autoFireDelay = 0.05;
    
    [_gamePad loadActionDescriptor:bgActionDesc andConnectionDescriptor:bgConn forActionType:@"next_level"];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    
    NSArray *nodes = [self nodesAtPoint:positionInScene];
    for (SKNode *node in nodes) {
        if ([node.name isEqualToString:@"reset"]) {
            [_resetNode triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
            [_gamePad runAction:[SKAction fadeAlphaTo:0.0 duration:.6]];
            [_menuButton runAction:[SKAction fadeAlphaTo:0.0 duration:.6]];
            [_resetNode runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0.0 duration:.6], [SKAction runBlock:^{
                [self loadLevel:_currentLevelInfo];
            }]]]];
        } else if ([node.name isEqualToString:@"menu"]) {
            [_menuButton triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
            [_gamePad runAction:[SKAction fadeAlphaTo:0.0 duration:.6]];
            [_resetNode runAction:[SKAction fadeAlphaTo:0.0 duration:.6]];
            [_menuButton runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0.0 duration:.6], [SKAction runBlock:^{
                [_sceneDelegate menuClicked];
            }]]]];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    CFTimeInterval timeSinceLast = currentTime - _lastUpdateTimeInterval;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
    }
    
    _lastUpdateTimeInterval = currentTime;
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    _currentBgTriggerInterval += timeSinceLast;
    if (_currentBgTriggerInterval > _bgTriggerInterval) {
        _currentBgTriggerInterval = 0;
        
        [_bgPad triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
    }
}

//----------------

-(void)createGameGrid
{
    self.isInVerticalOrder = YES;
    self.isInHorizontallOrder = YES;
    self.isFlipping = NO;
    self.userInteractionEnabled = YES;
    
    IBActionDescriptor *boomActionDesc = [[IBActionDescriptor alloc] init];
    boomActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //if (!targetNode.isActionSource && !targetNode.isBlocker) {
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        double distX_abs = fabs((double)targetNode.columnIndex - (double)sourcePosition.x);
        double distY_abs = fabs((double)targetNode.rowIndex - (double)sourcePosition.y);
        double damping = (distX_abs + distY_abs) / ((double)_gamePad.gridSize.width - 1 + (double)_gamePad.gridSize.height - 1);
        
        int distX = (int)targetNode.columnIndex - (int)sourcePosition.x;
        int distY = (int)targetNode.rowIndex - (int)sourcePosition.y;
        
        /*SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:0.7 + damping * 0.3 duration:.3], [SKAction scaleTo:1.2 - damping * 0.2 duration:.3]]];
         [targetNode runAction:[SKAction repeatActionForever:scaleSequence]];*/
        
        //targetNode.alpha = 1.0 - damping * 1.5;
        
        int distX_ref = targetNode.columnIndex - _referencePoint.x;
        int distY_ref = targetNode.rowIndex - _referencePoint.y;
        
        /*[targetNode runAction:[SKAction fadeAlphaTo:1.0 - damping * 2.5 duration:.2]];
         [targetNode runAction:[SKAction scaleTo:2.0 - damping duration:.2]];*/
        targetNode.zPosition = 100 - damping * 10;
        //((InteractionNode *)targetNode).nodeValue += (distX + distY);
        ((InteractionNode *)targetNode).nodeValue += (distX_ref + distY_ref) + (distX + distY);
        /*if (!targetNode.isEnemy && !targetNode.isPlayer) {
         SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.1 + damping * 0.9 duration:.3], [SKAction scaleTo:1.5 - damping * 0.5 duration:.3], [SKAction group:@[[SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
         ((InteractionNode *)targetNode).infoLabel.text = [NSString stringWithFormat:@"%d", ((InteractionNode *)targetNode).nodeValue];
         }]]]]];
         [targetNode runAction:scaleSequence];
         } else if (targetNode.isEnemy) {
         IBToken *token = targetNode.token;
         token.isAlive = NO;
         }*/
        
        SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.1 + damping * 0.9 duration:.3], [SKAction scaleTo:1.5 - damping * 0.5 duration:.3], [SKAction group:@[[SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
            ((InteractionNode *)targetNode).infoLabel.text = [NSString stringWithFormat:@"%d", ((InteractionNode *)targetNode).nodeValue];
        }]]]]];
        [targetNode runAction:scaleSequence];
        //}
    };
    
    IBConnectionDescriptor *boomConn = [[IBConnectionDescriptor alloc] init];
    boomConn.connectionType = kConnectionTypeNeighbours_close;
    boomConn.isAutoFired = YES;
    boomConn.autoFireDelay = 0.05;
    
    IBActionDescriptor *swipeActionDesc = [[IBActionDescriptor alloc] init];
    swipeActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        if (!targetNode.isBlocker) {
            CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
            
            double distX = fabs((double)targetNode.columnIndex - (double)sourcePosition.x);
            double distY = fabs((double)targetNode.rowIndex - (double)sourcePosition.y);
            double damping = (distX + distY) / ((double)_gamePad.gridSize.width - 1 + (double)_gamePad.gridSize.height - 1);
            
            /*UIColor *targetColor = [userInfo objectForKey:@"targetColor"];
             
             SKAction *phaseIn = [SKAction group:@[[SKAction colorizeWithColor:targetColor colorBlendFactor:1.0 duration:.3], [SKAction fadeAlphaTo:.5 duration:.3], [SKAction scaleTo:.1 + damping * 0.9 duration:.3]]];
             SKAction *phaseOut = [SKAction group:@[[SKAction colorizeWithColor:targetNode.baseColor colorBlendFactor:1.0 duration:.3], [SKAction fadeAlphaTo:1.0 duration:.3], [SKAction scaleTo:1.0 duration:.3]]];*/
            
            SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.1 + damping * 0.9 duration:.3], [SKAction scaleTo:1.5 - damping * 0.5 duration:.3], [SKAction scaleTo:1 duration:.3]]];
            [targetNode runAction:scaleSequence];
            
            //[targetNode runAction:[SKAction sequence:@[phaseIn, phaseOut]]];
        }
    };
    
    IBConnectionDescriptor *swipeConn = [[IBConnectionDescriptor alloc] init];
    swipeConn.connectionType = kConnectionTypeNeighbours_close;
    swipeConn.isAutoFired = NO;
    swipeConn.autoFireDelay = 0.05;
    
    IBActionDescriptor *brickActionDesc = [[IBActionDescriptor alloc] init];
    brickActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        
        UIColor *blockColor = [userInfo objectForKey:@"targetColor"];
        targetNode.color1 = blockColor;
        [targetNode runAction:[SKAction sequence:@[[SKAction colorizeWithColor:blockColor colorBlendFactor:1.0 duration:.2], [SKAction colorizeWithColor:targetNode.baseColor colorBlendFactor:1.0 duration:2.3]]] completion:^{
            targetNode.color1 = nil;
        }];
    };
    
    IBConnectionDescriptor *brickConn = [[IBConnectionDescriptor alloc] init];
    brickConn.connectionType = kConnectionTypeNeighbours_square;
    brickConn.isAutoFired = NO;
    brickConn.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:kConnectionParameter_counter];
    brickConn.autoFireDelay = 0;
    
    IBActionDescriptor *checkActionDesc = [[IBActionDescriptor alloc] init];
    checkActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        UIColor *checkColor = [userInfo objectForKey:@"checkColor"];
        NSString *checkId = [userInfo objectForKey:@"checkId"];
        if (targetNode.color1 && [targetNode.color1 isEqual:checkColor] && ![_checkIds containsObject:checkId]) {
            [_checkIds addObject:checkId];
            [_gamePad triggerNodeAtPosition:CGPointMake(targetNode.columnIndex, targetNode.rowIndex) forActionType:@"boom" withUserInfo:nil forceDisable:NO withNodeReset:NO];
        } else if (targetNode.color1 && ![targetNode.color1 isEqual:checkColor] && ![_checkIds containsObject:checkId]) {
            [_checkIds addObject:checkId];
            NSLog(@"False check");
        }
        if (_checkIds.count > 50) {
            [_checkIds removeObjectAtIndex:0];
        }
    };
    
    IBConnectionDescriptor *checkActionConn = [[IBConnectionDescriptor alloc] init];
    checkActionConn.connectionType = kConnectionTypeNeighbours_close;
    checkActionConn.isAutoFired = NO;
    checkActionConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    checkActionConn.autoFireDelay = 0;
    
    IBActionDescriptor *checkActionDesc_brickSpot = [[IBActionDescriptor alloc] init];
    checkActionDesc_brickSpot.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        
        _brickPlaceCheckCount++;
        if (targetNode.isBlocker) {
            _currentCheckSpotGood = NO;
        }
        if (_brickPlaceCheckCount == 9) {
            if (_currentCheckSpotGood) {
                NSValue *sourcePos = [userInfo objectForKey:@"position"];
                _nextBrickSpot = sourcePos.CGPointValue;
                _currentCheckSpotGood = YES;
                _brickPlaceCheckCount = 0;
            } else {
                _currentCheckSpotGood = YES;
                _brickPlaceCheckCount = 0;
                
                int columnIndex = [CommonTools getRandomNumberFromInt:5 toInt:_gamePad.gridSize.width - 6];
                int rowIndex = [CommonTools getRandomNumberFromInt:5 toInt:_gamePad.gridSize.height - 6];
                
                [_gamePad triggerNodeAtPosition:CGPointMake(columnIndex, rowIndex) forActionType:@"check_brickspot" withUserInfo:[NSMutableDictionary dictionary] forceDisable:NO withNodeReset:NO];
            }
        }
    };
    
    IBConnectionDescriptor *checkActionConn_brickSpot = [[IBConnectionDescriptor alloc] init];
    checkActionConn_brickSpot.connectionType = kConnectionTypeNeighbours_square;
    checkActionConn_brickSpot.isAutoFired = NO;
    checkActionConn_brickSpot.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:1], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    checkActionConn_brickSpot.autoFireDelay = 0;
    
    _gridSize = CGSizeMake(4, 4);
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _nodeCount = _gridSize.width * _gridSize.height;
    _gamePad = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(300, 300) andGridSize:_gridSize withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_touch forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _gamePad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_gamePad loadActionDescriptor:boomActionDesc andConnectionDescriptor:boomConn forActionType:@"boom"];
    [_gamePad loadActionDescriptor:swipeActionDesc andConnectionDescriptor:swipeConn forActionType:@"swipe"];
    [_gamePad loadActionDescriptor:brickActionDesc andConnectionDescriptor:brickConn forActionType:@"brick"];
    [_gamePad loadActionDescriptor:checkActionDesc andConnectionDescriptor:checkActionConn forActionType:@"check"];
    [_gamePad loadActionDescriptor:checkActionDesc_brickSpot andConnectionDescriptor:checkActionConn_brickSpot forActionType:@"check_brickspot"];
    [self addChild:_gamePad];
    _gamePad.disableOnFirstTrigger = NO;
}
-(void)loadFlipVerticalAction
{
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        _isFlipping = YES;
        GameObject *targetNode = (GameObject *)target;
        CGPoint blockPosition;
        if (_isInVerticalOrder) {
            if (_isInHorizontallOrder) {
                blockPosition = CGPointMake(targetNode.columnIndex * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, (_gridSize.height - 1 - targetNode.rowIndex) * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
            } else {
                blockPosition = CGPointMake((_gridSize.width - 1 - targetNode.columnIndex) * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, (_gridSize.height - 1 - targetNode.rowIndex) * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
            }
        } else {
            if (_isInHorizontallOrder) {
                blockPosition = CGPointMake(targetNode.columnIndex * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, targetNode.rowIndex * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
            } else {
                blockPosition = CGPointMake((_gridSize.width - 1 - targetNode.columnIndex) * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, targetNode.rowIndex * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
            }
        }
        
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction rotateByAngle:-2*M_PI duration:1], [SKAction moveTo:blockPosition duration:1], [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:.5], [SKAction fadeAlphaTo:1 duration:.5]]]]], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            _actionFinishedCount++;
            if (_actionFinishedCount == _nodeCount) {
                _actionFinishedCount = 0;
                [_gamePad setEnabled:YES forAction:[userInfo objectForKey:@"actiontype"]];
                _isInVerticalOrder = !_isInVerticalOrder;
                _isFlipping = NO;
            }
        }]]]];
    };
    
    IBConnectionDescriptor *bgConn = [[IBConnectionDescriptor alloc] init];
    bgConn.connectionType = kConnectionTypeNeighbours_close;
    bgConn.isAutoFired = YES;
    bgConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:50], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    
    bgConn.autoFireDelay = 0.05;
    
    [_gamePad loadActionDescriptor:bgActionDesc andConnectionDescriptor:bgConn forActionType:@"flip_vertical"];
}

-(void)loadHorizontalFlipAction
{
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        _isFlipping = YES;
        GameObject *targetNode = (GameObject *)target;
        CGPoint blockPosition;
        if (_isInHorizontallOrder) {
            if (_isInVerticalOrder) {
                blockPosition = CGPointMake((_gridSize.width - 1 - targetNode.columnIndex) * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, targetNode.rowIndex * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
            } else {
                blockPosition = CGPointMake((_gridSize.width - 1 - targetNode.columnIndex) * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, (_gridSize.height - 1 - targetNode.rowIndex) * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
            }
        } else {
            if (_isInVerticalOrder) {
                blockPosition = CGPointMake(targetNode.columnIndex * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, targetNode.rowIndex * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
            } else {
                blockPosition = CGPointMake(targetNode.columnIndex * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, (_gridSize.height - 1 - targetNode.rowIndex) * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
            }
        }
        
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction rotateByAngle:-2*M_PI duration:1], [SKAction moveTo:blockPosition duration:1], [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:.5], [SKAction fadeAlphaTo:1 duration:.5]]]]], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            _actionFinishedCount++;
            if (_actionFinishedCount == _nodeCount) {
                _actionFinishedCount = 0;
                [_gamePad setEnabled:YES forAction:[userInfo objectForKey:@"actiontype"]];
                _isInHorizontallOrder = !_isInHorizontallOrder;
                _isFlipping = NO;
            }
        }]]]];
    };
    
    IBConnectionDescriptor *bgConn = [[IBConnectionDescriptor alloc] init];
    bgConn.connectionType = kConnectionTypeNeighbours_close;
    bgConn.isAutoFired = YES;
    bgConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:50], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    
    bgConn.autoFireDelay = 0.05;
    
    [_gamePad loadActionDescriptor:bgActionDesc andConnectionDescriptor:bgConn forActionType:@"flip_horizontal"];
}

@end
