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

@property (nonatomic) BOOL isInVerticalOrder;
@property (nonatomic) BOOL isInHorizontallOrder;
@property (nonatomic) BOOL isFlipping;

@property (nonatomic) CGPoint referencePoint;

@property (nonatomic) NSDictionary *currentLevelInfo;
@property (nonatomic) NSString *currentColorScheme;
@property (nonatomic) NSString *currentBgColorScheme;

@property (nonatomic) PadNode *resetNode;
@property (nonatomic) PadNode *menuButton;
@property (nonatomic) PadNode *helpButton;

@property (nonatomic) BOOL isCompletedLevel;
@property (nonatomic) BOOL isQuestLevel;

@property (nonatomic) NSArray *clicks;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.actionFinishedCount = 0;
    self.nodeCount = 0;
    self.checkIds = [NSMutableArray array];
    self.nextBrickSpot = CGPointMake(-1, -1);
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
}

-(void)loadLevel:(NSDictionary *)levelInfo isCompleted:(BOOL)isCompleted andGridColorScheme:(NSString *)colorScheme andBgColorScheme:(NSString *)bgColorScheme isQuest:(BOOL)isQuest
{
    if (bgColorScheme) {
        [_bgPad recolorizeWithColorScheme:bgColorScheme];
    }
    _isQuestLevel = isQuest;
    _isCompletedLevel = isCompleted;
    _currentColorScheme = colorScheme;
    _currentBgColorScheme = bgColorScheme;
    for (SKNode *node in self.children) {
        if (![node.name isEqual:@"permanent"]) {
            [node removeFromParent];
        }
    }
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _resetNode = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(60, 60) andGridSize:CGSizeMake(5, 5) withPhysicsBody:NO andNodeColorCodes:@[_currentColorScheme] andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _resetNode.name = @"reset";
    
    
    SKLabelNode *resetLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    resetLabel.position = CGPointMake(0, 0);
    resetLabel.text = @"RESET";
    resetLabel.fontSize = 18;
    resetLabel.fontColor = [UIColor blackColor];
    resetLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    resetLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    resetLabel.name = @"reset";
    [_resetNode addChild:resetLabel];
    
    _helpButton = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(60, 60) andGridSize:CGSizeMake(5, 5) withPhysicsBody:NO andNodeColorCodes:@[_currentColorScheme] andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _helpButton.name = @"help";
    
    
    SKLabelNode *helpLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    helpLabel.position = CGPointMake(0, 0);
    helpLabel.text = @"?";
    helpLabel.fontSize = 35;
    helpLabel.fontColor = [UIColor blackColor];
    helpLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    helpLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    helpLabel.name = @"help";
    [_helpButton addChild:helpLabel];
    
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
    
    IBActionDescriptor *boomActionDesc_help = [[IBActionDescriptor alloc] init];
    boomActionDesc_help.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        [targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:.5 duration:.3], [SKAction scaleTo:1.0 duration:.3]]]];
    };
    
    _menuButton = [[PadNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(60, 60) andGridSize:CGSizeMake(5, 5) withPhysicsBody:NO andNodeColorCodes:@[_currentColorScheme] andInteractionMode:kInteractionMode_none forActionType:@"boom" isInteractive:NO withborderColor:nil];
    _menuButton.name = @"menu";
    
    
    SKLabelNode *menuLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
    menuLabel.position = CGPointMake(0, 0);
    menuLabel.text = @"BACK";
    menuLabel.fontSize = 18;
    menuLabel.fontColor = [UIColor blackColor];
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
    
    [_helpButton loadActionDescriptor:boomActionDesc_button andConnectionDescriptor:boomConn forActionType:@"boom"];
    [self addChild:_helpButton];
    
    _currentLevelInfo = levelInfo;
    
    __block NSMutableSet *matchingNodes = [NSMutableSet set];
    __block NSArray *referencePoints =  [levelInfo objectForKey:@"reference_points"];
    
    NSString *gridSize_str = [levelInfo objectForKey:@"grid_size"];
    NSArray* members = [gridSize_str componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @";"]];
    NSNumber *columns = [members objectAtIndex:0];
    NSNumber *rows = [members objectAtIndex:1];
    
    _gridSize = CGSizeMake(columns.intValue, rows.intValue);
    __block int nodeCount = _gridSize.height * _gridSize.width;
    __block int currentNodeCount = 0;
    __block NSDictionary *targetValues = [levelInfo objectForKey:@"targets"];
    
    IBActionDescriptor *boomActionDesc_touchup = [[IBActionDescriptor alloc] init];
    boomActionDesc_touchup.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        currentNodeCount++;
        InteractionNode *targetNode = (InteractionNode *)target;
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        double maxDiff = ((double)_gamePad.gridSize.width - 1 + (double)_gamePad.gridSize.height - 1);
        
        
        int distX = (int)targetNode.columnIndex - (int)sourcePosition.x;
        int distY = (int)targetNode.rowIndex - (int)sourcePosition.y;

        int distX_ref = 0;
        int distY_ref = 0;
        
        for (NSString *refPoint_str in referencePoints) {
            NSArray* members = [refPoint_str componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @";"]];
            NSNumber *columnIndex = [members objectAtIndex:0];
            NSNumber *rowIndex = [members objectAtIndex:1];
            distX_ref += targetNode.columnIndex - columnIndex.intValue;
            distY_ref += targetNode.rowIndex - rowIndex.intValue;
        }

        int valueDiff = (distX_ref + distY_ref) + (distX + distY);
        
        double scaleRatio = ((double)valueDiff / (maxDiff));
        
        scaleRatio = (fabs(scaleRatio) < .5 ? scaleRatio : (scaleRatio / fabs(scaleRatio)) * .5);
        
        targetNode.zPosition = 100 + scaleRatio * 10;
        targetNode.nodeValue += valueDiff;
        if (targetNode.infoNode) {
            [targetNode.infoNode removeFromParent];
            targetNode.infoNode = nil;
        }
        
        SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:1 + scaleRatio duration:.3], [SKAction group:@[[SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
            ((InteractionNode *)targetNode).valueLabel.text = [NSString stringWithFormat:@"%d", ((InteractionNode *)targetNode).nodeValue];
        }]]]]];
        [targetNode runAction:scaleSequence];
        
        if (targetNode.isActionSource) {
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
        if (currentNodeCount == nodeCount) {
            if (matchingNodes.count >= targetValues.allKeys.count) {
                CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
                SKAction *fadeAction = [SKAction fadeAlphaTo:0.0 duration:1.3];
                [_resetNode runAction:fadeAction];
                [_menuButton runAction:fadeAction];
                [_helpButton runAction:fadeAction];
                [self runAction:[SKAction sequence:@[[SKAction waitForDuration:.8], [SKAction runBlock:^{
                    [_gamePad triggerNodeAtPosition:sourcePosition forActionType:@"next_level" withUserInfo:nil forceDisable:NO withNodeReset:NO];
                }], [SKAction waitForDuration:1], [SKAction runBlock:^{
                    if (_isCompletedLevel) {
                        [_sceneDelegate historyClicked];
                    } else {
                        if (_isQuestLevel) {
                            [_sceneDelegate questLevelCompleted];
                        } else {
                            [_sceneDelegate randomLevelCompleted];
                        }
                    }
                }]]]];
            } else {
                currentNodeCount = 0;
            }
        }
    };
    
    IBActionDescriptor *boomActionDesc_touchup_long = [[IBActionDescriptor alloc] init];
    boomActionDesc_touchup_long.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        InteractionNode *targetNode = (InteractionNode *)target;
        
        [targetNode.infoNode runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:.3], [SKAction removeFromParent], [SKAction runBlock:^{
            targetNode.infoNode = nil;
        }]]]];
        
        //[targetNode.infoLabel removeFromParent];
        //targetNode.infoLabel = nil;
        [targetNode runAction:[SKAction scaleTo:1 duration:.3]];
    };
    
    IBActionDescriptor *boomActionDesc_touchdown = [[IBActionDescriptor alloc] init];
    boomActionDesc_touchdown.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        InteractionNode *targetNode = (InteractionNode *)target;
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        double maxDiff = ((double)_gamePad.gridSize.width - 1 + (double)_gamePad.gridSize.height - 1);
        
        
        int distX = (int)targetNode.columnIndex - (int)sourcePosition.x;
        int distY = (int)targetNode.rowIndex - (int)sourcePosition.y;
        
        int distX_ref = 0;
        int distY_ref = 0;
        
        for (NSString *refPoint_str in referencePoints) {
            NSArray* members = [refPoint_str componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @";"]];
            NSNumber *columnIndex = [members objectAtIndex:0];
            NSNumber *rowIndex = [members objectAtIndex:1];
            distX_ref += targetNode.columnIndex - columnIndex.intValue;
            distY_ref += targetNode.rowIndex - rowIndex.intValue;
        }
        
        int valueDiff = (distX_ref + distY_ref) + (distX + distY);
        
        double scaleRatio = ((double)valueDiff / (maxDiff));
        
        scaleRatio = (fabs(scaleRatio) < .3 ? scaleRatio : (scaleRatio / fabs(scaleRatio)) * .3);
        if (targetNode.isActionSource) {
            targetNode.zPosition = 100 + fabs(scaleRatio) * 10;
        } else {
            targetNode.zPosition = 100;
        }
        
        if (targetNode.isActionSource) {
            SKLabelNode *infoLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
            infoLabel = [SKLabelNode labelNodeWithFontNamed:@"Copperplate-Bold"];
            infoLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            infoLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
            infoLabel.fontSize = 17;
            infoLabel.position = CGPointMake(0, 0);
            infoLabel.fontColor = valueDiff < 0 ? [UIColor redColor] : [UIColor greenColor];
            infoLabel.text = valueDiff <= 0 ? [NSString stringWithFormat:@"%d", valueDiff] : [NSString stringWithFormat:@"+%d", valueDiff];
            
            SKSpriteNode *infoNode = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(targetNode.size.width, targetNode.size.height / 2.0)];
            infoNode.alpha = 0;
            infoNode.position = CGPointMake(0, -targetNode.size.height / 4);
            [infoNode addChild:infoLabel];
            
            [infoNode runAction:[SKAction sequence:@[/*[SKAction waitForDuration:.3], */[SKAction fadeAlphaTo:targetNode.isActionSource ? .6 : .4 duration:.3]]]];
            targetNode.infoNode = infoNode;
            [targetNode addChild:targetNode.infoNode];
        }
        
        /*SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:1 + scaleRatio duration:.3], [SKAction group:@[[SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
         ((InteractionNode *)targetNode).infoLabel.text = [NSString stringWithFormat:@"%d", ((InteractionNode *)targetNode).nodeValue];
         }]]]]];*/
        [targetNode runAction:[SKAction scaleTo:1 + scaleRatio duration:.3]];
    };
    
    bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _nodeCount = _gridSize.width * _gridSize.height;
    
    _clicks = [levelInfo objectForKey:@"clicks"];
    
    CGFloat edgeSize = self.size.width - 40;
    if (edgeSize > 450) {
        edgeSize = 450;
    }
    CGSize playAreaSize = CGSizeMake(edgeSize, edgeSize);
    
    
    _gamePad = [[PadNode alloc] initWithColor:[UIColor clearColor] size:playAreaSize andGridSize:_gridSize withPhysicsBody:NO andNodeColorCodes:@[_currentColorScheme] andInteractionMode:kInteractionMode_touch forActionType:@"boom" isInteractive:YES withborderColor:[UIColor blackColor]];
    _gamePad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_gamePad loadActionDescriptor:boomActionDesc_touchup andConnectionDescriptor:boomConn forActionType:@"boom_touchup"];
    [_gamePad loadActionDescriptor:boomActionDesc_touchdown andConnectionDescriptor:boomConn forActionType:@"boom_longtap"];
    [_gamePad loadActionDescriptor:boomActionDesc_touchup_long andConnectionDescriptor:boomConn forActionType:@"boom_touchup_longtap"];
    [_gamePad loadActionDescriptor:boomActionDesc_help andConnectionDescriptor:nil forActionType:@"help"];
    [self loadNextLevelEffect];
    _gamePad.alpha = 0;
    _resetNode.alpha = 0;
    _menuButton.alpha = 0;
    _helpButton.alpha = 0;
    [self addChild:_gamePad];
    SKAction *fadeAction = [SKAction fadeAlphaTo:1.0 duration:.3];
    [_gamePad runAction:fadeAction];
    [_resetNode runAction:fadeAction];
    [_menuButton runAction:fadeAction];
    [_helpButton runAction:fadeAction];
    _gamePad.disableOnFirstTrigger = NO;
    
    _resetNode.position = CGPointMake(self.size.width / 2 + _gamePad.size.width / 2 - _resetNode.size.width / 2, self.size.height / 2 + _gamePad.size.height / 2 + _resetNode.size.height / 2 + 20);
    _helpButton.position = CGPointMake(self.size.width / 2, self.size.height / 2 - _gamePad.size.height / 2 - _helpButton.size.height / 2 - 20);
    _menuButton.position = CGPointMake(self.size.width / 2 - _gamePad.size.width / 2 + _menuButton.size.width / 2, self.size.height / 2 + _gamePad.size.height / 2 + _menuButton.size.height / 2 + 20);
    
    for (NSString *refPoint_str in referencePoints) {
        NSArray* members = [refPoint_str componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @";"]];
        NSNumber *columnIndex = [members objectAtIndex:0];
        NSNumber *rowIndex = [members objectAtIndex:1];
        InteractionNode *refNode = (InteractionNode *)[_gamePad getNodeAtPosition:CGPointMake(columnIndex.intValue, rowIndex.intValue)];
        refNode.color = [UIColor blueColor];
        
        SKSpriteNode *marker = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(3 * refNode.size.width / 4, 3 * refNode.size.height / 4)];
        marker.position = CGPointMake(0, 0);
        marker.userInteractionEnabled = NO;
        if (refNode.valueLabel) {
            [refNode.valueLabel removeFromParent];
        }
        //marker.zPosition = ((InteractionNode *)refNode).infoLabel.zPosition - 1;
        [refNode addChild:marker];
        
        refNode.valueLabel.fontColor = [UIColor whiteColor];
        [marker addChild:refNode.valueLabel];
    }
    
    for (int column = 0; column < _gamePad.gridSize.width; column++) {
        for (int row = 0; row < _gamePad.gridSize.height; row++) {
            GameObject *node = [_gamePad getNodeAtPosition:CGPointMake(column, row)];
            
            if ([[targetValues allKeys] containsObject:[NSString stringWithFormat:@"%d;%d", node.columnIndex, node.rowIndex]]) {
                NSNumber *targetValue = [targetValues objectForKey:[NSString stringWithFormat:@"%d;%d", node.columnIndex, node.rowIndex]];

                ((InteractionNode *)node).valueLabel.hidden = NO;
                ((InteractionNode *)node).valueLabel.text = [NSString stringWithFormat:@"%d", -targetValue.intValue];
                ((InteractionNode *)node).nodeValue = -targetValue.intValue;
                node.isActionSource = YES;
                
            } else {
                ((InteractionNode *)node).valueLabel.hidden = YES;
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
    BOOL touched = NO;
    NSArray *nodes = [self nodesAtPoint:positionInScene];
    SKAction *fadeAction = [SKAction fadeAlphaTo:0.0 duration:.6];
    for (SKNode *node in nodes) {
        if ([node.name isEqualToString:@"reset"] && !touched) {
            touched = YES;
            [_resetNode triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
            [_gamePad runAction:fadeAction];
            [_menuButton runAction:fadeAction];
            [_helpButton runAction:fadeAction];
            [_resetNode runAction:[SKAction sequence:@[fadeAction, [SKAction runBlock:^{
                [self loadLevel:_currentLevelInfo isCompleted:_isCompletedLevel andGridColorScheme:_currentColorScheme andBgColorScheme:_currentBgColorScheme isQuest:_isQuestLevel];
            }]]]];
        } else if ([node.name isEqualToString:@"menu"] && !touched) {
            touched = YES;
            [_menuButton triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
            [_gamePad runAction:fadeAction];
            [_resetNode runAction:fadeAction];
            [_helpButton runAction:fadeAction];
            [_menuButton runAction:[SKAction sequence:@[fadeAction, [SKAction runBlock:^{
                if (_isCompletedLevel) {
                    [_sceneDelegate historyClicked];
                } else {
                    [_sceneDelegate menuClicked];
                }
            }]]]];
        } else if ([node.name isEqualToString:@"help"] && !touched) {
            touched = YES;
            [_helpButton triggerRandomNodeForActionType:@"boom" withUserInfo:nil];
            NSString *click = [_clicks objectAtIndex:0];
            NSArray* members = [click componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @";"]];
            NSNumber *columnIndex = [members objectAtIndex:0];
            NSNumber *rowIndex = [members objectAtIndex:1];
            [_gamePad triggerNodeAtPosition:CGPointMake(columnIndex.intValue, rowIndex.intValue) forActionType:@"help" withUserInfo:nil forceDisable:NO withNodeReset:NO];
            [_helpButton runAction:[SKAction sequence:@[fadeAction, [SKAction removeFromParent]]]];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
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
            ((InteractionNode *)targetNode).valueLabel.text = [NSString stringWithFormat:@"%d", ((InteractionNode *)targetNode).nodeValue];
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
