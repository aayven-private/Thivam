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

@end

@implementation GameScene

//static int kRows =  10;
//static int kColumns =  10;

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    //self.imageHelper = [[ImageHelper alloc] init];
    
    //self.sourceImage = [UIImage imageNamed:@"IMG_0136"];
    //[self.imageHelper loadDataFromImage:self.sourceImage];
    [self startMotionManager];
    [self initEnvironment];
}

-(void)initEnvironment
{
    [self removeAllChildren];
    _bgTriggerInterval = [CommonTools getRandomFloatFromFloat:.4 toFloat:.5];
    _currentBgTriggerInterval = 0;
    IBActionDescriptor *bgActionDesc = [[IBActionDescriptor alloc] init];
    bgActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        //CGPoint targetPosition = CGPointMake(targetNode.rowIndex, targetNode.columnIndex);
        [targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:.5 duration:.3], [SKAction scaleTo:1 duration:2], [SKAction runBlock:^{
            targetNode.isRunningAction = NO;
        }]]]];
        //targetNode.color = [UIColor colorWithRed:[CommonTools getRandomFloatFromFloat:0 toFloat:1] green:[CommonTools getRandomFloatFromFloat:0 toFloat:1] blue:[CommonTools getRandomFloatFromFloat:0 toFloat:1] alpha:1];
        //targetNode.isRunningAction = NO;
    };

    IBConnectionDescriptor *bgConn = [[IBConnectionDescriptor alloc] init];
    bgConn.connectionType = kConnectionTypeLinear_bottomUp;
    bgConn.isAutoFired = YES;
    bgConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:50], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _bgPad = [[PadNode alloc] initWithColor:[UIColor blueColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:CGSizeMake(60, 40) withPhysicsBody:NO andNodeColorCodes:bgColorCodes andInteractionMode:kInteractionMode_swipe];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [_bgPad loadActionDescriptor:bgActionDesc andConnectionDescriptor:bgConn];
    [self addChild:_bgPad];
    //[_bgPad triggerRandomNode];
    
    IBActionDescriptor *padActionDesc = [[IBActionDescriptor alloc] init];
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
    [self addChild:_padNode];
    
    //[self readImageData];
    
    /*self.bgImage = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"IMG_0136"]];
    self.bgImage.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    self.bgImage.size = CGSizeMake(self.size.width, self.size.height);
    //self.bgImage.alpha = 0.5;
    self.bgImage.zPosition = 1;
    [self addChild:self.bgImage];*/
    
    self.anchorPoint = CGPointMake(0, 0);
    
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
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
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
        _bgTriggerInterval = [CommonTools getRandomFloatFromFloat:.3 toFloat:.5];
        //[_bgPad triggerRandomNode];
    }
}

-(void)wipeScreen
{
    [self removeAllActions];
    [self initEnvironment];
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
            [_padNode triggerRandomNode];
        }
    } else if (contact.bodyB.categoryBitMask == kObjectCategoryFrame) {
        if (contact.bodyA.categoryBitMask == kObjectCategoryActionPad) {
            [_padNode triggerRandomNode];
        }
    }
}

@end
