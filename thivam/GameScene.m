//
//  GameScene.m
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "GameScene.h"
#import <CoreMotion/CoreMotion.h>
#import "InteractionObject.h"
#import "IBMatrix.h"
#import "CommonTools.h"
#import "IBActionPad.h"
#import "ImageHelper.h"
#import "PadNode.h"

@interface GameScene()

@property (nonatomic) NSMutableArray *gameObjects;

@property (nonatomic) int rows;
@property (nonatomic) int columns;

@property (nonatomic) SKSpriteNode *bgImage;

@property (nonatomic) ImageHelper *imageHelper;
@property (nonatomic) UIImage *sourceImage;

@property (nonatomic) SKAction *colorAction;
@property (nonatomic) SKAction *pulseAction;
@property (nonatomic) SKAction *rotateAction;

@property (nonatomic) PadNode *padNode;

@property (nonatomic) double xAccel;
@property (nonatomic) double yAccel;
@property (nonatomic) double zAccel;

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval sensorCheckInterval;
@property (nonatomic) NSTimeInterval currentBgTriggerInterval;
@property (nonatomic) NSTimeInterval bgTriggerInterval;

@property (nonatomic) PadNode *bgPad;

@property (nonatomic) IBActionPad *actionPad;

@property (atomic) int actionFinishedCount;
@property (nonatomic) int nodeCount;

@property (nonatomic) CGSize gridSize;

@end

@implementation GameScene

//static int kRows =  10;
//static int kColumns =  10;

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    //self.imageHelper = [[ImageHelper alloc] init];
    
    self.actionFinishedCount = 0;
    self.nodeCount = 0;
    
    //self.sourceImage = [UIImage imageNamed:@"IMG_0136"];
    //[self.imageHelper loadDataFromImage:self.sourceImage];
    [self startMotionManager];
    [self initEnvironment];
}

-(void)initEnvironment
{
    [self removeAllChildren];
    
    
    /*self.bgImage = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"IMG_0136"]];
    self.bgImage.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    self.bgImage.size = CGSizeMake(self.size.width, self.size.height);
    //self.bgImage.alpha = 0.5;
    self.bgImage.zPosition = 0;
    self.bgImage.userInteractionEnabled = NO;
    [self addChild:self.bgImage];*/
    
    self.colorAction = [SKAction colorizeWithColor:[UIColor colorWithRed:[CommonTools getRandomFloatFromFloat:0 toFloat:1] green:[CommonTools getRandomFloatFromFloat:0 toFloat:1] blue:[CommonTools getRandomFloatFromFloat:0 toFloat:1] alpha:1] colorBlendFactor:1 duration:.3];
    self.pulseAction = [SKAction sequence:@[[SKAction scaleTo:.2 duration:.3], [SKAction scaleTo:1 duration:.3]]];
    self.rotateAction = [SKAction rotateByAngle:-1.156 duration:.3];
    
    self.gameObjects = [NSMutableArray array];
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.contactTestBitMask = kObjectCategoryActionPad;
    self.physicsBody.categoryBitMask = kObjectCategoryFrame;
    self.physicsBody.collisionBitMask = kObjectCategoryActionPad;
    self.physicsWorld.contactDelegate = self;
    
    //[self createRecordingGrid];
    //[self createGridFromSavedDescription];
    [self createGrid_2];
    //[self createActionPad];
}

-(void)createActionPad
{
    /*self.anchorPoint = CGPointMake(0.5, 0.5);
    _actionPad = [[IBActionPad alloc] initGridWithSize:CGSizeMake(10, 5) andNodeInitBlock:^id<IBActionNodeActor>(int row, int column) {
        PadNode *node = [[PadNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width / 5, self.size.height / 10) andGridSize:CGSizeMake(3, 3) withPhysicsBody:NO andNodeColorCodes:@[@"123456", @"654321", @"F1F1F1", @"987654"] andInteractionMode:kInteractionMode_none forActionType:@"action"];
        CGPoint blockPosition = CGPointMake(column * node.size.width - self.size.width / 2.0 + node.size.width / 2.0, row * node.size.height - self.size.height / 2.0 + node.size.height / 2.0);
        node.position = blockPosition;
        //node.zPosition = 3;
        [self addChild:node];
        node.rowIndex = row;
        node.columnIndex = column;
        IBActionDescriptor *actionDesc = [[IBActionDescriptor alloc] init];
        actionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
            GameObject *targetNode = (GameObject *)target;
            [targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:.5 duration:.3], [SKAction scaleTo:1.0 duration:.3], [SKAction colorizeWithColor:[ImageHelper getRandomColor] colorBlendFactor:1 duration:.1], [SKAction runBlock:^{
                [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            }]]]];
        };
        IBConnectionDescriptor *connDesc = [[IBConnectionDescriptor alloc] init];
        connDesc.connectionType = kConnectionTypeNeighbours_close;
        connDesc.isAutoFired = YES;
        [node loadActionDescriptor:actionDesc andConnectionDescriptor:connDesc forActionType:@"action"];
        return node;
    }];
    [_actionPad createGridWithNodesActivated:YES];
    IBConnectionDescriptor *connDesc = [[IBConnectionDescriptor alloc] init];
    connDesc.connectionType = kConnectionTypeRandom;
    connDesc.isAutoFired = NO;
    connDesc.userInfo = [NSMutableDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:70], [NSNumber numberWithInt:15]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    
    IBActionDescriptor *actionDesc = [[IBActionDescriptor alloc] init];
    actionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        PadNode *targetNode = (PadNode *)target;
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction runBlock:^{
            [targetNode triggerRandomNodeForActionType:@"action"];
        }], [SKAction scaleTo:1.5 duration:.4]]], [SKAction scaleTo:1.0 duration:.4], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
        }]]]];
    };
    
    [_actionPad.unifiedActionDescriptors setObject:@[actionDesc] forKey:@"action"];
    [_actionPad loadConnectionMapWithDescriptor:connDesc forActionType:@"action"];*/

}

-(void)createRecordingGrid
{
    /*_bgImage.hidden = YES;
    self.userInteractionEnabled = NO;
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        //CGPoint targetPosition = CGPointMake(targetNode.rowIndex, targetNode.columnIndex);
        [targetNode runAction:[SKAction sequence:@[[SKAction colorizeWithColor:[UIColor blueColor] colorBlendFactor:1 duration:0], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
        }]]]];
        //targetNode.color = [UIColor colorWithRed:[CommonTools getRandomFloatFromFloat:0 toFloat:1] green:[CommonTools getRandomFloatFromFloat:0 toFloat:1] blue:[CommonTools getRandomFloatFromFloat:0 toFloat:1] alpha:1];
        //targetNode.isRunningAction = NO;
    };
    
    _bgPad = [[PadNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:CGSizeMake(10, 8) withPhysicsBody:NO andNodeColorCodes:nil andInteractionMode:kInteractionMode_swipe forActionType:@"action"];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:bgActionDesc andConnectionDescriptor:nil forActionType:@"action"];
    
    [self addChild:_bgPad];
    
    [_bgPad startRecording];*/
}

-(void)createGridFromSavedDescription
{
    /*NSString *jsonStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"saved_connections"];
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *deserialized = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    NSNumber *rows = [deserialized objectForKey:@"rows"];
    NSNumber *columns = [deserialized objectForKey:@"columns"];
    
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        //CGPoint targetPosition = CGPointMake(targetNode.rowIndex, targetNode.columnIndex);
        [targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:.5 duration:.3], [SKAction scaleTo:1 duration:2], [SKAction colorizeWithColor:[UIColor blueColor] colorBlendFactor:1 duration:.3], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
        }]]]];
        //targetNode.color = [UIColor colorWithRed:[CommonTools getRandomFloatFromFloat:0 toFloat:1] green:[CommonTools getRandomFloatFromFloat:0 toFloat:1] blue:[CommonTools getRandomFloatFromFloat:0 toFloat:1] alpha:1];
        //targetNode.isRunningAction = NO;
    };
    
    _bgPad = [[PadNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:CGSizeMake(rows.intValue, columns.intValue) withPhysicsBody:NO andNodeColorCodes:@[@"FFFFFF"] andInteractionMode:kInteractionMode_swipe forActionType:@"action"];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:bgActionDesc andConnectionDescriptor:nil forActionType:@"action"];
    [_bgPad loadConnectionsFromDescription:deserialized forActionType:@"action" andIgnoreSource:NO];
    
    [self insertChild:_bgImage atIndex:0];*/
}

-(void)createGrid_1
{
    /*bgTriggerInterval = [CommonTools getRandomFloatFromFloat:.4 toFloat:.5];
    _currentBgTriggerInterval = 0;
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        //CGPoint targetPosition = CGPointMake(targetNode.rowIndex, targetNode.columnIndex);
        [targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:.5 duration:.3], [SKAction scaleTo:2.5 duration:.9], [SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
        }]]]];
        //targetNode.color = [UIColor colorWithRed:[CommonTools getRandomFloatFromFloat:0 toFloat:1] green:[CommonTools getRandomFloatFromFloat:0 toFloat:1] blue:[CommonTools getRandomFloatFromFloat:0 toFloat:1] alpha:1];
        //targetNode.isRunningAction = NO;
    };
    
    IBConnectionDescriptor *bgConn = [[IBConnectionDescriptor alloc] init];
    bgConn.connectionType = kConnectionTypeLinear_bottomUp;
    bgConn.isAutoFired = YES;
    bgConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:50], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _bgPad = [[PadNode alloc] initWithColor:[UIColor blueColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:CGSizeMake(60, 40) withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_none forActionType:@"action"];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:bgActionDesc andConnectionDescriptor:bgConn forActionType:@"action"];
    [self addChild:_bgPad];*/
    
    
    
    //[_bgPad triggerRandomNode];
    
    /*IBActionDescriptor *padActionDesc = [[IBActionDescriptor alloc] init];
    padActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        //CGPoint targetPosition = CGPointMake(targetNode.rowIndex, targetNode.columnIndex);
        [targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:.5 duration:.3], [SKAction scaleTo:1 duration:.3], [SKAction runBlock:^{
            targetNode.isRunningAction = NO;
        }]]]];
        //targetNode.color = [UIColor colorWithRed:[CommonTools getRandomFloatFromFloat:0 toFloat:1] green:[CommonTools getRandomFloatFromFloat:0 toFloat:1] blue:[CommonTools getRandomFloatFromFloat:0 toFloat:1] alpha:1];
        //targetNode.isRunningAction = NO;
    };
    
    IBConnectionDescriptor *padConn = [[IBConnectionDescriptor alloc] init];
    padConn.connectionType = kConnectionTypeNeighbours_square;
    padConn.isAutoFired = YES;
    padConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:1]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_repeatCount]];
    
    NSArray *padColorCodes = [NSArray arrayWithObjects:@"0505F2", @"0202DE", @"0404C2", @"0202A6", nil];
    _padNode = [[PadNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(50, 50) andGridSize:CGSizeMake(5, 5) withPhysicsBody:YES andNodeColorCodes:padColorCodes andInteractionMode:kInteractionMode_touch];
    [_padNode loadActionDescriptor:padActionDesc andConnectionDescriptor:padConn];
    _padNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [self addChild:_padNode];*/
}

-(void)createGrid_2
{
    _bgTriggerInterval = [CommonTools getRandomFloatFromFloat:2 toFloat:3];
    _currentBgTriggerInterval = 0;
    
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;

        CGPoint blockPosition = CGPointMake(targetNode.columnIndex * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, targetNode.rowIndex * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);

        //NSArray *colorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
        
        //NSArray *colorCodes = [NSArray arrayWithObjects:@"1017E8", @"060DD4", @"040AB8", @"02079C", nil];
        
        //int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)colorCodes.count - 1)];
        //UIColor *blockColor = [CommonTools stringToColor:[colorCodes objectAtIndex:colorIndex]];
        UIColor *bgColor = [userInfo objectForKey:@"matchcolor"];
        _bgPad.color = bgColor;
        //CGPoint positionInView = CGPointMake(targetNode.columnIndex * targetNode.size.width + targetNode.size.width / 2.0, (_bgPad.gridSize.width - 1 - targetNode.rowIndex) * targetNode.size.height + targetNode.size.height / 2.0);
        //UIColor *blockColor = [_sceneDelegate getColorAtPosition:positionInView];
        
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction colorizeWithColor:targetNode.baseColor colorBlendFactor:1 duration:2.5], [SKAction rotateByAngle:-2*M_PI duration:2.5], [SKAction moveTo:blockPosition duration:2.5], [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:2.5], [SKAction fadeAlphaTo:1 duration:1.5]]]]], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            _actionFinishedCount++;
            if (_actionFinishedCount == _nodeCount) {
                _actionFinishedCount = 0;
                _bgPad.isDisabled = NO;
                [self revertGrid_2];
                //_bgPad.color = bgColor;
            }
        }]]]];
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];

    };
     
    IBConnectionDescriptor *bgConn = [[IBConnectionDescriptor alloc] init];
    bgConn.connectionType = kConnectionTypeNeighbours_close;
    bgConn.isAutoFired = YES;
    bgConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:5], [NSNumber numberWithInt:2]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    bgConn.ignoreSource = NO;
    bgConn.manualCleanup = YES;
    bgConn.autoFireDelay = 0.05;
    
    /*IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        
        //UIColor *originalColor = targetNode.color;
        
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction scaleTo:.5 duration:.1], [SKAction fadeAlphaTo:.5 duration:.1]]], [SKAction group:@[[SKAction scaleTo:1.0 duration:.2], [SKAction fadeAlphaTo:1.0 duration:.2]]], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
        }]]]];
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];
        
    };
    
    IBConnectionDescriptor *bgConn = [[IBConnectionDescriptor alloc] init];
    bgConn.connectionType = kConnectionTypeNeighbours_close;
    bgConn.isAutoFired = YES;
    bgConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:100], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    bgConn.ignoreSource = NO;
    bgConn.manualCleanup = YES;
    bgConn.autoFireDelay = 0.05;*/
    
    
    IBActionDescriptor *fireActionDesc_up = [[IBActionDescriptor alloc] init];
    fireActionDesc_up.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //UIColor *originalColor = targetNode.color;
        
        UIColor *blockColor = [userInfo objectForKey:@"targetcolor"];
        
        targetNode.color1 = blockColor;
        [targetNode runAction:[SKAction sequence:@[[SKAction colorizeWithColor:blockColor colorBlendFactor:1 duration:.15], [SKAction colorizeWithColor:targetNode.baseColor colorBlendFactor:1 duration:.15], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            targetNode.color1 = nil;
        }]]]];
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];
        
    };
    
    IBActionDescriptor *fireActionDesc_down = [[IBActionDescriptor alloc] init];
    fireActionDesc_down.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //UIColor *originalColor = targetNode.color;
        
        UIColor *blockColor = [userInfo objectForKey:@"targetcolor"];
        
        
        targetNode.color2 = blockColor;
        [targetNode runAction:[SKAction sequence:@[[SKAction colorizeWithColor:blockColor colorBlendFactor:1 duration:.15], [SKAction colorizeWithColor:targetNode.baseColor colorBlendFactor:1 duration:.15], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            targetNode.color2 = nil;
        }]]]];
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];
        
    };
    
    IBConnectionDescriptor *fireConn_down = [[IBConnectionDescriptor alloc] init];
    fireConn_down.connectionType = kConnectionTypeLinear_topBottom;
    fireConn_down.isAutoFired = YES;
    fireConn_down.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:100], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    fireConn_down.ignoreSource = YES;
    fireConn_down.autoFireDelay = .1;
    
    IBConnectionDescriptor *fireConn_up = [[IBConnectionDescriptor alloc] init];
    fireConn_up.connectionType = kConnectionTypeLinear_bottomUp;
    fireConn_up.isAutoFired = YES;
    fireConn_up.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:100], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    fireConn_up.ignoreSource = YES;
    fireConn_up.autoFireDelay = .1;
    
    _gridSize = CGSizeMake(30, 20);
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _nodeCount = _gridSize.width * _gridSize.height;
    _bgPad = [[PadNode alloc] initWithColor:[UIColor blueColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:_gridSize withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_touch forActionType:@"action"];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:bgActionDesc andConnectionDescriptor:bgConn forActionType:@"action"];
    [_bgPad loadActionDescriptor:fireActionDesc_down andConnectionDescriptor:fireConn_down forActionType:@"fire_down"];
    [_bgPad loadActionDescriptor:fireActionDesc_up andConnectionDescriptor:fireConn_up forActionType:@"fire_up"];
    [self addChild:_bgPad];
    _bgPad.disableOnFirstTrigger = NO;
    //[_bgPad triggerRandomNode];    
}

-(void)revertGrid_2
{
    IBActionDescriptor *revertAction = [[IBActionDescriptor alloc] init];
    revertAction.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        
        
        CGPoint blockPosition = CGPointMake((_gridSize.height - 1 - targetNode.columnIndex) * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, (_gridSize.width - 1 - targetNode.rowIndex) * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
        
        //NSArray *colorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
        
        //NSArray *colorCodes = [NSArray arrayWithObjects:@"1017E8", @"060DD4", @"040AB8", @"02079C", nil];
        
        //int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)colorCodes.count - 1)];
        //UIColor *blockColor = [CommonTools stringToColor:[colorCodes objectAtIndex:colorIndex]];
        
        //targetNode.baseColor = blockColor;
        
        //UIColor *bgColor = [userInfo objectForKey:@"matchcolor"];
        
        //CGPoint positionInView = CGPointMake(targetNode.columnIndex * targetNode.size.width + targetNode.size.width / 2.0, (_bgPad.gridSize.width - 1 - targetNode.rowIndex) * targetNode.size.height + targetNode.size.height / 2.0);
        //UIColor *blockColor = [_sceneDelegate getColorAtPosition:positionInView];
        
        UIColor *bgColor = [userInfo objectForKey:@"matchcolor"];
        _bgPad.color = bgColor;
        
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction colorizeWithColor:targetNode.baseColor colorBlendFactor:1 duration:2.5], [SKAction rotateByAngle:-2*M_PI duration:2.5], [SKAction moveTo:blockPosition duration:2.5], [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:2.5], [SKAction fadeAlphaTo:1 duration:1.5]]]]], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            _actionFinishedCount++;
            if (_actionFinishedCount == _nodeCount) {
                _actionFinishedCount = 0;
                _bgPad.isDisabled = NO;
                [self loadGrid_2];
                //_bgPad.color = bgColor;
            }
        }]]]];
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];
        
    };
    [_bgPad loadActionDescriptor:revertAction andConnectionDescriptor:nil forActionType:@"action"];
    //[_bgPad triggerRandomNode];
}

-(void)loadGrid_2
{
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        
        
        CGPoint blockPosition = CGPointMake(targetNode.columnIndex * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, targetNode.rowIndex * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
        
        //NSArray *colorCodes = [NSArray arrayWithObjects:@"1017E8", @"060DD4", @"040AB8", @"02079C", nil];
        
        //int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)colorCodes.count - 1)];
        //UIColor *blockColor = [CommonTools stringToColor:[colorCodes objectAtIndex:colorIndex]];
        //targetNode.baseColor = blockColor;
        //CGPoint positionInView = CGPointMake(targetNode.columnIndex * targetNode.size.width + targetNode.size.width / 2.0, (_bgPad.gridSize.width - 1 - targetNode.rowIndex) * targetNode.size.height + targetNode.size.height / 2.0);
        //UIColor *blockColor = [_sceneDelegate getColorAtPosition:positionInView];
        UIColor *bgColor = [userInfo objectForKey:@"matchcolor"];
        _bgPad.color = bgColor;
        
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction colorizeWithColor:targetNode.baseColor colorBlendFactor:1 duration:2.5], [SKAction rotateByAngle:-2*M_PI duration:2.5], [SKAction moveTo:blockPosition duration:2.5], [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:2.5], [SKAction fadeAlphaTo:1 duration:1.5]]]]], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            _actionFinishedCount++;
            if (_actionFinishedCount == _nodeCount) {
                _actionFinishedCount = 0;
                _bgPad.isDisabled = NO;
                [self revertGrid_2];
                //_bgPad.color = bgColor;
            }
        }]]]];
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];
        
    };
    [_bgPad loadActionDescriptor:bgActionDesc andConnectionDescriptor:nil forActionType:@"action"];
    //[_bgPad triggerRandomNode];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    /*UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    
    NSArray *objects = [self nodesAtPoint:positionInScene];
    for (SKNode *touchedNode in objects) {
        if ([touchedNode isKindOfClass:[PadNode class]]) {
            [_actionPad triggerNodeAtPosition:CGPointMake(((PadNode *)touchedNode).columnIndex, ((PadNode *)touchedNode).rowIndex)];
        }
    }*/
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
    _padNode.position = CGPointMake(_padNode.position.x + _xAccel * 15, _padNode.position.y + _yAccel * 15);
    
    _currentBgTriggerInterval += timeSinceLast;
    if (_currentBgTriggerInterval > _bgTriggerInterval) {
        _currentBgTriggerInterval = 0;
        _bgTriggerInterval = [CommonTools getRandomFloatFromFloat:2 toFloat:3];
        
        UIColor *blockColor_up;
        int colorIndex_up = [CommonTools getRandomNumberFromInt:0 toInt:3];
        switch (colorIndex_up) {
            case 0: {
                blockColor_up = [UIColor yellowColor];
            } break;
            case 1: {
                blockColor_up = [UIColor greenColor];
            } break;
            case 2: {
                blockColor_up = [UIColor cyanColor];
            } break;
            case 3: {
                blockColor_up = [UIColor brownColor];
            } break;
        }
        
        UIColor *blockColor_down;
        int colorIndex_down = [CommonTools getRandomNumberFromInt:0 toInt:3];
        switch (colorIndex_down) {
            case 0: {
                blockColor_down = [UIColor yellowColor];
            } break;
            case 1: {
                blockColor_down = [UIColor greenColor];
            } break;
            case 2: {
                blockColor_down = [UIColor cyanColor];
            } break;
            case 3: {
                blockColor_down = [UIColor brownColor];
            } break;
        }
        
        int columnIndex_down = [CommonTools getRandomNumberFromInt:2 toInt:_bgPad.gridSize.height - 3];
        
        for (int i=-2; i<3; i++) {
            [_bgPad triggerNodeAtPosition:CGPointMake(i + columnIndex_down, _bgPad.gridSize.width - 1) forActionType:@"fire_down" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        }
        
        int columnIndex_up = [CommonTools getRandomNumberFromInt:2 toInt:_bgPad.gridSize.height - 3];
        
        for (int i=-2; i<3; i++) {
            [_bgPad triggerNodeAtPosition:CGPointMake(i + columnIndex_up, 0) forActionType:@"fire_up" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_up forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        }
        
        //[_bgPad triggerRandomNodeForActionType:@"action"];
        //_bgPad.isDisabled = YES;
        //[_actionPad triggerNodeAtPosition:CGPointMake([CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.height - 1], [CommonTools getRandomNumberFromInt:0 toInt: _actionPad.gridSize.width - 1])];
    }
}

-(void)wipeScreen
{
    //[self removeAllActions];
    //[self initEnvironment];
    
    /*[_bgPad stopRecording];
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        //CGPoint targetPosition = CGPointMake(targetNode.rowIndex, targetNode.columnIndex);
        [targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:.5 duration:.3], [SKAction fadeAlphaTo:.2 duration:.3], [SKAction scaleTo:1 duration:2], [SKAction fadeAlphaTo:1 duration:.3], [SKAction runBlock:^{
            targetNode.isRunningAction = NO;
        }]]]];
        //targetNode.color = [UIColor colorWithRed:[CommonTools getRandomFloatFromFloat:0 toFloat:1] green:[CommonTools getRandomFloatFromFloat:0 toFloat:1] blue:[CommonTools getRandomFloatFromFloat:0 toFloat:1] alpha:1];
        //targetNode.isRunningAction = NO;
    };
    [_bgPad setActionDescriptor:bgActionDesc];
    _bgImage.hidden = NO;*/
}

-(void)startMotionManager
{
    self.motionManager.accelerometerUpdateInterval = self.motionManager.gyroUpdateInterval = self.motionManager.deviceMotionUpdateInterval = self.motionManager.magnetometerUpdateInterval = .01;
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {

        _xAccel = accelerometerData.acceleration.x;
        _yAccel = accelerometerData.acceleration.y;
        _zAccel = accelerometerData.acceleration.z;
        
    }];
}

- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager = nil;
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    
    return motionManager;
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == kObjectCategoryFrame) {
        if (contact.bodyB.categoryBitMask == kObjectCategoryActionPad) {
            //[_padNode triggerRandomNodeForActionType:@"action"];
        }
    } else if (contact.bodyB.categoryBitMask == kObjectCategoryFrame) {
        if (contact.bodyA.categoryBitMask == kObjectCategoryActionPad) {
            //[_padNode triggerRandomNodeForActionType:@"action"];
        }
    }
}

@end
