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

@property (nonatomic) NSMutableArray *checkIds;

@property (nonatomic) int brickPlaceCheckCount;
@property (nonatomic) BOOL currentCheckSpotGood;

@property (nonatomic) CGPoint nextBrickSpot;

@end

@implementation GameScene

//static int kRows =  10;
//static int kColumns =  10;

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    //self.imageHelper = [[ImageHelper alloc] init];
    
    self.actionFinishedCount = 0;
    self.nodeCount = 0;
    self.checkIds = [NSMutableArray array];
    self.nextBrickSpot = CGPointMake(-1, -1);
    //self.sourceImage = [UIImage imageNamed:@"IMG_0136"];
    //[self.imageHelper loadDataFromImage:self.sourceImage];
    //[self startMotionManager];
    
    self.brickPlaceCheckCount = 0;
    self.currentCheckSpotGood = YES;
    
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
    //[self createGrid_2];
    //[self createActionPad];
    
    [self createGameGrid];
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
    
    self.userInteractionEnabled = NO;
    
    /*IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;

        CGPoint blockPosition = CGPointMake(targetNode.columnIndex * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, (_gridSize.width - 1 - targetNode.rowIndex) * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);

        //NSArray *colorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
        
        NSArray *colorCodes = [NSArray arrayWithObjects:@"1017E8", @"060DD4", @"040AB8", @"02079C", nil];
        
        int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)colorCodes.count - 1)];
        UIColor *blockColor = [CommonTools stringToColor:[colorCodes objectAtIndex:colorIndex]];
        //UIColor *bgColor = [userInfo objectForKey:@"matchcolor"];
        //_bgPad.color = bgColor;
        //CGPoint positionInView = CGPointMake(targetNode.columnIndex * targetNode.size.width + targetNode.size.width / 2.0, (_bgPad.gridSize.width - 1 - targetNode.rowIndex) * targetNode.size.height + targetNode.size.height / 2.0);
        //UIColor *blockColor = [_sceneDelegate getColorAtPosition:positionInView];
        
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction colorizeWithColor:blockColor colorBlendFactor:1 duration:2.5], [SKAction rotateByAngle:-2*M_PI duration:2.5], [SKAction moveTo:blockPosition duration:2.5], [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:2.5], [SKAction fadeAlphaTo:1 duration:1.5]]]]], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            _actionFinishedCount++;
            if (_actionFinishedCount == _nodeCount) {
                _actionFinishedCount = 0;
                [_bgPad setEnabled:YES forAction:[userInfo objectForKey:@"actiontype"]];
                [self revertGrid_2];
                _bgPad.color = [UIColor blueColor];
                //[_bgPad triggerRandomNodeForActionType:[userInfo objectForKey:@"actiontype"] withUserInfo:[userInfo mutableCopy]];
            }
        }]]]];
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];

    };*/
    
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        
        CGPoint targetPosition_screen = CGPointMake(targetNode.columnIndex * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, targetNode.rowIndex * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
        CGPoint sourcePosition_screen = CGPointMake(sourcePosition.x * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, sourcePosition.y * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
        
        CGPoint direction = rwNormalize(rwSub(sourcePosition_screen, targetPosition_screen));
        
        
        double distX = fabs((double)targetNode.columnIndex - (double)sourcePosition.x);
        double distY = fabs((double)targetNode.rowIndex - (double)sourcePosition.y);
        
        double damping = (distX + distY) / ((double)_bgPad.gridSize.height - 1 + (double)_bgPad.gridSize.width - 1);
        
        CGPoint length = CGPointMake((1.0 - damping) * 10 * direction.x, (1-damping) * 10 * direction.y);
        CGPoint destination = rwAdd(targetPosition_screen, length);
        
        SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.1 + damping * 0.9 duration:.3], [SKAction scaleTo:1.5 - damping * 0.5 duration:.3], [SKAction scaleTo:1 duration:.3]]];
        SKAction *moveSequence = [SKAction sequence:@[[SKAction moveTo:destination duration:.3], [SKAction moveTo:targetPosition_screen duration:.3]]];
        
        [targetNode runAction:[SKAction group:@[scaleSequence]]];
    };
    
    /*IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        CGPoint targetPosition = ((NSValue *)[userInfo objectForKey:@"targetPosition"]).CGPointValue;
        CGPoint blockPosition = CGPointMake(targetPosition.x - self.size.width / 2.0, targetPosition.y - self.size.height / 2.0);
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction moveTo:blockPosition duration:2.5], [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:.3], [SKAction fadeAlphaTo:1 duration:.3]]]]], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            _actionFinishedCount++;
            if (_actionFinishedCount == _nodeCount) {
                _actionFinishedCount = 0;
                //[_bgPad setEnabled:YES forAction:[userInfo objectForKey:@"actiontype"]];
            }
        }]]]];
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];
        
    };*/
     
    IBConnectionDescriptor *bgConn = [[IBConnectionDescriptor alloc] init];
    bgConn.connectionType = kConnectionTypeNeighbours_close;
    bgConn.isAutoFired = YES;
    bgConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:50], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];

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
    
    
    IBActionDescriptor *fireActionDesc = [[IBActionDescriptor alloc] init];
    fireActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //UIColor *originalColor = targetNode.color;
        
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        
        if (sourcePosition.x != targetNode.columnIndex || sourcePosition.y != targetNode.rowIndex) {
            UIColor *blockColor = [userInfo objectForKey:@"targetcolor"];
            
            targetNode.color1 = blockColor;
            [targetNode runAction:[SKAction sequence:@[[SKAction colorizeWithColor:blockColor colorBlendFactor:1 duration:.1], [SKAction colorizeWithColor:targetNode.baseColor colorBlendFactor:1 duration:.3], [SKAction runBlock:^{
                [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
                targetNode.color1 = nil;
            }]]]];
        } else {
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
        }
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];
        
    };
    
    /*IBActionDescriptor *fireActionDesc_down = [[IBActionDescriptor alloc] init];
    fireActionDesc_down.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //UIColor *originalColor = targetNode.color;
        
        UIColor *blockColor = [userInfo objectForKey:@"targetcolor"];
        
        
        targetNode.color2 = blockColor;
        [targetNode runAction:[SKAction sequence:@[[SKAction colorizeWithColor:blockColor colorBlendFactor:1 duration:.1], [SKAction colorizeWithColor:targetNode.baseColor colorBlendFactor:1 duration:.3], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            targetNode.color2 = nil;
        }]]]];
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];
        
    };*/
    
    IBConnectionDescriptor *fireConn_down = [[IBConnectionDescriptor alloc] init];
    fireConn_down.connectionType = kConnectionTypeLinear_topBottom;
    fireConn_down.isAutoFired = YES;
    fireConn_down.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:100], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    fireConn_down.autoFireDelay = .1;
    
    IBConnectionDescriptor *fireConn_up = [[IBConnectionDescriptor alloc] init];
    fireConn_up.connectionType = kConnectionTypeLinear_bottomUp;
    fireConn_up.isAutoFired = YES;
    fireConn_up.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:100], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    fireConn_up.autoFireDelay = .1;
    
    IBConnectionDescriptor *fireConn_left = [[IBConnectionDescriptor alloc] init];
    fireConn_left.connectionType = kConnectionTypeLinear_leftRight;
    fireConn_left.isAutoFired = YES;
    fireConn_left.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:100], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    fireConn_left.autoFireDelay = .1;
    
    IBConnectionDescriptor *fireConn_right = [[IBConnectionDescriptor alloc] init];
    fireConn_right.connectionType = kConnectionTypeLinear_rightLeft;
    fireConn_right.isAutoFired = YES;
    fireConn_right.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:100], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    fireConn_right.autoFireDelay = .1;
    
    _gridSize = CGSizeMake(30, 20);
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _nodeCount = _gridSize.width * _gridSize.height;
    _bgPad = [[PadNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:_gridSize withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_touch forActionType:@"action"];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:bgActionDesc andConnectionDescriptor:bgConn forActionType:@"action"];
    [_bgPad loadActionDescriptor:fireActionDesc andConnectionDescriptor:fireConn_down forActionType:@"fire_down"];
    [_bgPad loadActionDescriptor:fireActionDesc andConnectionDescriptor:fireConn_up forActionType:@"fire_up"];
    [_bgPad loadActionDescriptor:fireActionDesc andConnectionDescriptor:fireConn_left forActionType:@"fire_left"];
    [_bgPad loadActionDescriptor:fireActionDesc andConnectionDescriptor:fireConn_right forActionType:@"fire_right"];
    [self addChild:_bgPad];
    _bgPad.disableOnFirstTrigger = NO;
    //[_bgPad triggerRandomNode];    
}

-(void)createGameGrid
{
    _bgTriggerInterval = [CommonTools getRandomFloatFromFloat:2 toFloat:3];
    _currentBgTriggerInterval = 0;
    
    self.userInteractionEnabled = NO;
    
    
    IBActionDescriptor *boomActionDesc = [[IBActionDescriptor alloc] init];
    boomActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        if (!targetNode.isActionSource && !targetNode.isBlocker) {
            CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
            double distX = fabs((double)targetNode.columnIndex - (double)sourcePosition.x);
            double distY = fabs((double)targetNode.rowIndex - (double)sourcePosition.y);
            double damping = (distX + distY) / ((double)_bgPad.gridSize.height - 1 + (double)_bgPad.gridSize.width - 1);
            SKAction *scaleSequence = [SKAction sequence:@[[SKAction scaleTo:.1 + damping * 0.9 duration:.3], [SKAction scaleTo:1.5 - damping * 0.5 duration:.3], [SKAction scaleTo:1 duration:.3]]];
            [targetNode runAction:scaleSequence];
        }
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
            double damping = (distX + distY) / ((double)_bgPad.gridSize.height - 1 + (double)_bgPad.gridSize.width - 1);
            
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
            [_bgPad triggerNodeAtPosition:CGPointMake(targetNode.columnIndex, targetNode.rowIndex) forActionType:@"boom" withUserInfo:nil forceDisable:NO withNodeReset:NO];
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
                
                int columnIndex = [CommonTools getRandomNumberFromInt:5 toInt:_bgPad.gridSize.height - 6];
                int rowIndex = [CommonTools getRandomNumberFromInt:5 toInt:_bgPad.gridSize.width - 6];
                
                [_bgPad triggerNodeAtPosition:CGPointMake(columnIndex, rowIndex) forActionType:@"check_brickspot" withUserInfo:[NSMutableDictionary dictionary] forceDisable:NO withNodeReset:NO];
            }
        }
    };
    
    IBConnectionDescriptor *checkActionConn_brickSpot = [[IBConnectionDescriptor alloc] init];
    checkActionConn_brickSpot.connectionType = kConnectionTypeNeighbours_square;
    checkActionConn_brickSpot.isAutoFired = NO;
    checkActionConn_brickSpot.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:1], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    checkActionConn_brickSpot.autoFireDelay = 0;
    
    _gridSize = CGSizeMake(31, 21);
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _nodeCount = _gridSize.width * _gridSize.height;
    _bgPad = [[PadNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:_gridSize withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_swipe forActionType:@"swipe"];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:boomActionDesc andConnectionDescriptor:boomConn forActionType:@"boom"];
    [_bgPad loadActionDescriptor:swipeActionDesc andConnectionDescriptor:swipeConn forActionType:@"swipe"];
    [_bgPad loadActionDescriptor:brickActionDesc andConnectionDescriptor:brickConn forActionType:@"brick"];
    [_bgPad loadActionDescriptor:checkActionDesc andConnectionDescriptor:checkActionConn forActionType:@"check"];
    [_bgPad loadActionDescriptor:checkActionDesc_brickSpot andConnectionDescriptor:checkActionConn_brickSpot forActionType:@"check_brickspot"];
    [self addChild:_bgPad];
    _bgPad.disableOnFirstTrigger = NO;
    
    for (int i=0; i<3; i++) {
        for (int j=0; j<3; j++) {
            GameObject *actionSourceObject = [_bgPad getNodeAtPosition:CGPointMake(j, i)];
            if (actionSourceObject) {
                actionSourceObject.isActionSource = YES;
                actionSourceObject.color = [UIColor blueColor];
                actionSourceObject.baseColor = [UIColor blueColor];
                
                [actionSourceObject runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:1.2 duration:.2], [SKAction scaleTo:1.0 duration:.2]]]]];
                
                actionSourceObject.zPosition = 10;
            }
        }
    }
    
    for (int i=0; i<3; i++) {
        for (int j=0; j<3; j++) {
            GameObject *actionSourceObject = [_bgPad getNodeAtPosition:CGPointMake(_bgPad.gridSize.height - 1 - j, i)];
            if (actionSourceObject) {
                actionSourceObject.isActionSource = YES;
                actionSourceObject.color = [UIColor orangeColor];
                actionSourceObject.baseColor = [UIColor orangeColor];
                
                [actionSourceObject runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:1.2 duration:.2], [SKAction scaleTo:1.0 duration:.2]]]]];
                
                actionSourceObject.zPosition = 10;
            }
        }
    }
    
    for (int i=0; i<3; i++) {
        for (int j=0; j<3; j++) {
            GameObject *actionSourceObject = [_bgPad getNodeAtPosition:CGPointMake(j, _bgPad.gridSize.width - 1 - i)];
            if (actionSourceObject) {
                actionSourceObject.isActionSource = YES;
                actionSourceObject.color = [UIColor cyanColor];
                actionSourceObject.baseColor = [UIColor cyanColor];
                
                [actionSourceObject runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:1.2 duration:.2], [SKAction scaleTo:1.0 duration:.2]]]]];
                
                actionSourceObject.zPosition = 10;
            }
        }
    }
    
    for (int i=0; i<3; i++) {
        for (int j=0; j<3; j++) {
            GameObject *actionSourceObject = [_bgPad getNodeAtPosition:CGPointMake(_bgPad.gridSize.height - 1 - j, _bgPad.gridSize.width - 1 - i)];
            if (actionSourceObject) {
                actionSourceObject.isActionSource = YES;
                actionSourceObject.color = [UIColor greenColor];
                actionSourceObject.baseColor = [UIColor greenColor];
                
                [actionSourceObject runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:1.2 duration:.2], [SKAction scaleTo:1.0 duration:.2]]]]];
                
                actionSourceObject.zPosition = 10;
            }
        }
    }
    
    for (int i=5; i<_bgPad.gridSize.height - 5; i++) {
        GameObject *blocker = [_bgPad getNodeAtPosition:CGPointMake(i, (int)_bgPad.gridSize.width / 2 - 5)];
        blocker.color = [UIColor blackColor];
        blocker.alpha = .7;
        blocker.isBlocker = YES;
        
        blocker.zPosition = 20;
    }
    
    for (int i=5; i<_bgPad.gridSize.width - 15; i++) {
        GameObject *blocker = [_bgPad getNodeAtPosition:CGPointMake((int)_bgPad.gridSize.height / 2 - 5, i)];
        blocker.color = [UIColor blackColor];
        blocker.alpha = .7;
        blocker.isBlocker = YES;
        
        blocker.zPosition = 20;
    }
    
    for (int i=5; i<_bgPad.gridSize.height - 5; i++) {
        GameObject *blocker = [_bgPad getNodeAtPosition:CGPointMake(i, (int)_bgPad.gridSize.width / 2 + 5)];
        blocker.color = [UIColor blackColor];
        blocker.alpha = .7;
        blocker.isBlocker = YES;
        
        blocker.zPosition = 20;
    }
    
    for (int i=15; i<_bgPad.gridSize.width - 5; i++) {
        GameObject *blocker = [_bgPad getNodeAtPosition:CGPointMake((int)_bgPad.gridSize.height / 2 + 5, i)];
        blocker.color = [UIColor blackColor];
        blocker.alpha = .7;
        blocker.isBlocker = YES;
        
        blocker.zPosition = 20;
    }
    
    int columnIndex = [CommonTools getRandomNumberFromInt:5 toInt:_bgPad.gridSize.height - 6];
    int rowIndex = [CommonTools getRandomNumberFromInt:5 toInt:_bgPad.gridSize.width - 6];
    
    [_bgPad triggerNodeAtPosition:CGPointMake(columnIndex, rowIndex) forActionType:@"check_brickspot" withUserInfo:nil forceDisable:NO withNodeReset:NO];
}

-(void)revertGrid_2
{
    IBActionDescriptor *revertAction = [[IBActionDescriptor alloc] init];
    revertAction.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        
        
        CGPoint blockPosition = CGPointMake(targetNode.columnIndex * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, targetNode.rowIndex * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
        
        NSArray *colorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
        
        //NSArray *colorCodes = [NSArray arrayWithObjects:@"1017E8", @"060DD4", @"040AB8", @"02079C", nil];
        
        int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)colorCodes.count - 1)];
        UIColor *blockColor = [CommonTools stringToColor:[colorCodes objectAtIndex:colorIndex]];
        
        //targetNode.baseColor = blockColor;
        
        //UIColor *bgColor = [userInfo objectForKey:@"matchcolor"];
        
        //CGPoint positionInView = CGPointMake(targetNode.columnIndex * targetNode.size.width + targetNode.size.width / 2.0, (_bgPad.gridSize.width - 1 - targetNode.rowIndex) * targetNode.size.height + targetNode.size.height / 2.0);
        //UIColor *blockColor = [_sceneDelegate getColorAtPosition:positionInView];
        
        //UIColor *bgColor = [userInfo objectForKey:@"matchcolor"];
        //_bgPad.color = bgColor;
        
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction colorizeWithColor:blockColor colorBlendFactor:1 duration:2.5], [SKAction rotateByAngle:-2*M_PI duration:2.5], [SKAction moveTo:blockPosition duration:2.5], [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:2.5], [SKAction fadeAlphaTo:1 duration:1.5]]]]], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            _actionFinishedCount++;
            if (_actionFinishedCount == _nodeCount) {
                _actionFinishedCount = 0;
                [_bgPad setEnabled:YES forAction:[userInfo objectForKey:@"actiontype"]];
                [self loadGrid_2];
                _bgPad.color = [UIColor redColor];
                //[_bgPad triggerRandomNodeForActionType:[userInfo objectForKey:@"actiontype"] withUserInfo:[userInfo mutableCopy]];
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
        
        
        CGPoint blockPosition = CGPointMake(/*(_gridSize.height - 1 - targetNode.columnIndex)*/targetNode.columnIndex * targetNode.size.width - self.size.width / 2.0 + targetNode.size.width / 2.0, (_gridSize.width - 1 - targetNode.rowIndex) * targetNode.size.height - self.size.height / 2.0 + targetNode.size.height / 2.0);
        
        NSArray *colorCodes = [NSArray arrayWithObjects:@"1017E8", @"060DD4", @"040AB8", @"02079C", nil];
        
        int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)colorCodes.count - 1)];
        UIColor *blockColor = [CommonTools stringToColor:[colorCodes objectAtIndex:colorIndex]];
        //targetNode.baseColor = blockColor;
        //CGPoint positionInView = CGPointMake(targetNode.columnIndex * targetNode.size.width + targetNode.size.width / 2.0, (_bgPad.gridSize.width - 1 - targetNode.rowIndex) * targetNode.size.height + targetNode.size.height / 2.0);
        //UIColor *blockColor = [_sceneDelegate getColorAtPosition:positionInView];
        //UIColor *bgColor = [userInfo objectForKey:@"matchcolor"];
        //_bgPad.color = bgColor;
        
        [targetNode runAction:[SKAction sequence:@[[SKAction group:@[[SKAction colorizeWithColor:blockColor colorBlendFactor:1 duration:2.5], [SKAction rotateByAngle:-2*M_PI duration:2.5], [SKAction moveTo:blockPosition duration:2.5], [SKAction sequence:@[[SKAction fadeAlphaTo:0 duration:2.5], [SKAction fadeAlphaTo:1 duration:1.5]]]]], [SKAction runBlock:^{
            [targetNode.runningActionForTypes setObject:[NSNumber numberWithBool:NO] forKey:[userInfo objectForKey:@"actiontype"]];
            _actionFinishedCount++;
            if (_actionFinishedCount == _nodeCount) {
                _actionFinishedCount = 0;
                [_bgPad setEnabled:YES forAction:[userInfo objectForKey:@"actiontype"]];
                [self revertGrid_2];
                _bgPad.color = [UIColor blueColor];
                //[_bgPad triggerRandomNodeForActionType:[userInfo objectForKey:@"actiontype"] withUserInfo:[userInfo mutableCopy]];
            }
        }]]]];
        
        //[targetNode runAction:[SKAction moveTo:blockPosition duration:.5]];
        
    };
    [_bgPad loadActionDescriptor:bgActionDesc andConnectionDescriptor:nil forActionType:@"action"];
    //[_bgPad triggerRandomNode];
}

-(void)checkForAvailableBrickPositions
{
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /*UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    
    [_bgPad triggerRandomNodeForActionType:@"action" withUserInfo:[NSMutableDictionary dictionaryWithObject:[NSValue valueWithCGPoint:positionInScene] forKey:@"targetPosition"]];*/
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
    //_padNode.position = CGPointMake(_padNode.position.x + _xAccel * 15, _padNode.position.y + _yAccel * 15);
    
    _currentBgTriggerInterval += timeSinceLast;
    if (_currentBgTriggerInterval > _bgTriggerInterval) {
        
        if (!CGPointEqualToPoint(CGPointMake(-1, -1), _nextBrickSpot)) {
            _currentBgTriggerInterval = 0;
            _bgTriggerInterval = 3.5;
            
            
            UIColor *blockColor;
            int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:3];
            switch (colorIndex) {
                case 0: {
                    blockColor = [UIColor blueColor];
                } break;
                case 1: {
                    blockColor = [UIColor orangeColor];
                } break;
                case 2: {
                    blockColor = [UIColor cyanColor];
                } break;
                case 3: {
                    blockColor = [UIColor greenColor];
                } break;
                default:
                    break;
            }
            //blockColor = [UIColor greenColor];
            [_bgPad triggerNodeAtPosition:_nextBrickSpot forActionType:@"brick" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor forKey:@"targetColor"] forceDisable:NO withNodeReset:NO];
            
            int columnIndex = [CommonTools getRandomNumberFromInt:5 toInt:_bgPad.gridSize.height - 6];
            int rowIndex = [CommonTools getRandomNumberFromInt:5 toInt:_bgPad.gridSize.width - 6];
            
            _nextBrickSpot = CGPointMake(-1, -1);
            
            [_bgPad triggerNodeAtPosition:CGPointMake(columnIndex, rowIndex) forActionType:@"check_brickspot" withUserInfo:nil forceDisable:NO withNodeReset:NO];
        } else {

        }
        
        
        //_bgTriggerInterval = [CommonTools getRandomFloatFromFloat:2 toFloat:3];
        
        
        /*UIColor *blockColor_up;
        int colorIndex_up = [CommonTools getRandomNumberFromInt:0 toInt:2];
        switch (colorIndex_up) {
            case 0: {
                blockColor_up = [UIColor yellowColor];
            } break;
            case 1: {
                blockColor_up = [UIColor greenColor];
            } break;
            case 2: {
                blockColor_up = [UIColor cyanColor];
            } break; break;
        }
        
        UIColor *blockColor_down;
        int colorIndex_down = [CommonTools getRandomNumberFromInt:0 toInt:2];
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
        }*/
        
        /*UIColor *blockColor_down = [UIColor blueColor];
        
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 2, _bgPad.gridSize.width / 2) forActionType:@"fire_up" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 2, _bgPad.gridSize.width / 2) forActionType:@"fire_left" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 2, _bgPad.gridSize.width / 2) forActionType:@"fire_down" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 2, _bgPad.gridSize.width / 2) forActionType:@"fire_right" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];*/

        
        /*
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 4, _bgPad.gridSize.width / 4) forActionType:@"fire_up" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 4, _bgPad.gridSize.width / 4) forActionType:@"fire_left" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 4, _bgPad.gridSize.width / 4) forActionType:@"fire_down" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 4, _bgPad.gridSize.width / 4) forActionType:@"fire_right" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        
        
        [_bgPad triggerNodeAtPosition:CGPointMake(3 * _bgPad.gridSize.height / 4, _bgPad.gridSize.width / 4) forActionType:@"fire_up" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(3 * _bgPad.gridSize.height / 4, _bgPad.gridSize.width / 4) forActionType:@"fire_left" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(3 * _bgPad.gridSize.height / 4, _bgPad.gridSize.width / 4) forActionType:@"fire_down" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(3 * _bgPad.gridSize.height / 4, _bgPad.gridSize.width / 4) forActionType:@"fire_right" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 4, 3 * _bgPad.gridSize.width / 4) forActionType:@"fire_up" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 4, 3 * _bgPad.gridSize.width / 4) forActionType:@"fire_left" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 4, 3 * _bgPad.gridSize.width / 4) forActionType:@"fire_down" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(_bgPad.gridSize.height / 4, 3 * _bgPad.gridSize.width / 4) forActionType:@"fire_right" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        
        [_bgPad triggerNodeAtPosition:CGPointMake(3 * _bgPad.gridSize.height / 4, 3 * _bgPad.gridSize.width / 4) forActionType:@"fire_up" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(3 * _bgPad.gridSize.height / 4, 3 * _bgPad.gridSize.width / 4) forActionType:@"fire_left" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(3 * _bgPad.gridSize.height / 4, 3 * _bgPad.gridSize.width / 4) forActionType:@"fire_down" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        [_bgPad triggerNodeAtPosition:CGPointMake(3 * _bgPad.gridSize.height / 4, 3 * _bgPad.gridSize.width / 4) forActionType:@"fire_right" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];*/
        
        
        /*int columnIndex_down = [CommonTools getRandomNumberFromInt:2 toInt:_bgPad.gridSize.height - 3];
        
        for (int i=-2; i<3; i++) {
            [_bgPad triggerNodeAtPosition:CGPointMake(i + columnIndex_down, _bgPad.gridSize.width - 1) forActionType:@"fire_down" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_down forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        }
        
        int columnIndex_up = [CommonTools getRandomNumberFromInt:2 toInt:_bgPad.gridSize.height - 3];
        
        for (int i=-2; i<3; i++) {
            [_bgPad triggerNodeAtPosition:CGPointMake(i + columnIndex_up, 0) forActionType:@"fire_up" withUserInfo:[NSMutableDictionary dictionaryWithObject:blockColor_up forKey:@"targetcolor"] forceDisable:NO withNodeReset:NO];
        }*/
        
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
