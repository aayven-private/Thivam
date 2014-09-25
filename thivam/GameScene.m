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

@property (nonatomic) int effectStepper;

@property (nonatomic) IBActionPad *gamePad1;
//@property (nonatomic) IBActionPad *gamePad2;

//@property (nonatomic) SKSpriteNode *gridHolder1;
//@property (nonatomic) SKSpriteNode *gridHolder2;

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
    /*self.imageHelper = [[ImageHelper alloc] init];
    
    self.sourceImage = [UIImage imageNamed:@"IMG_0136"];
    [self.imageHelper loadDataFromImage:self.sourceImage];
    self.effectStepper = 0;*/
    [self startMotionManager];
    [self initEnvironment];
}

-(void)initEnvironment
{
    [self removeAllChildren];
    _bgTriggerInterval = [CommonTools getRandomFloatFromFloat:.4 toFloat:.5];
    _currentBgTriggerInterval = 0;
    IBActionDescriptor *colorizeDescriptor = [[IBActionDescriptor alloc] init];
    colorizeDescriptor.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        GameObject *targetNode = (GameObject *)target;
        //CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        //CGPoint targetPosition = CGPointMake(targetNode.rowIndex, targetNode.columnIndex);
        [targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:.5 duration:.3], [SKAction scaleTo:1 duration:2]]]];
    };

    IBConnectionDescriptor *bgConn = [[IBConnectionDescriptor alloc] init];
    bgConn.connectionType = kConnectionTypeLinear_bottomUp;
    bgConn.isAutoFired = YES;
    bgConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:50], [NSNumber numberWithInt:10]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion]];
    
    NSArray *bgColorCodes = [NSArray arrayWithObjects:@"F20C23", @"DE091E", @"CC081C", @"B50415", nil];
    _bgPad = [[PadNode alloc] initWithColor:[UIColor blueColor] size:CGSizeMake(self.size.width, self.size.height) andGridSize:CGSizeMake(40, 40) withPhysicsBody:NO withActionDescriptor:colorizeDescriptor andNodeColorCodes:bgColorCodes andConnectionDescriptor:bgConn];
    _bgPad.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [self addChild:_bgPad];
    [_bgPad triggerRandomNode];
    
    /*IBConnectionDescriptor *padConn = [[IBConnectionDescriptor alloc] init];
    padConn.connectionType = kConnectionTypeNeighbours_square;
    padConn.isAutoFired = YES;
    padConn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:1]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_repeatCount]];
    
    NSArray *padColorCodes = [NSArray arrayWithObjects:@"0505F2", @"0202DE", @"0404C2", @"0202A6", nil];
    _padNode = [[PadNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(50, 50) andGridSize:CGSizeMake(5, 5) withPhysicsBody:YES withActionDescriptor:colorizeDescriptor andNodeColorCodes:padColorCodes andConnectionDescriptor:padConn];
    _padNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [self addChild:_padNode];*/
    
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

-(void)addFullscreenActionPad
{
    CGSize screenSize = CGSizeMake(self.view.frame.size.width , self.view.frame.size.height );
    CGSize blockSize = CGSizeMake(10, 10);
    
    /*_gridHolder1 = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height / 2)];
     _gridHolder1.position = CGPointMake(0, _gridHolder1.frame.size.height);
     _gridHolder1.zPosition = 1;
     _gridHolder1.anchorPoint = CGPointMake(0, 0);
     [self addChild:_gridHolder1];
     
     _gridHolder2 = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height / 2)];
     _gridHolder2.position = CGPointMake(0, 0);
     _gridHolder2.zPosition = 1;
     _gridHolder2.anchorPoint = CGPointMake(0, 0);
     [self addChild:_gridHolder2];*/
    
    _rows = ((screenSize.height) / blockSize.height);
    _columns = ((screenSize.width) / blockSize.width);
    
    self.userInteractionEnabled = YES;
    
    //Grid 1
    
    self.gamePad1 = [[IBActionPad alloc] initGridWithSize:CGSizeMake(_rows, _columns) andNodeInitBlock:^id<IBActionNodeActor>(int row, int column){
        UIColor *blockColor;
        int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:4];
        switch (colorIndex) {
            case 0: {
                blockColor = [CommonTools stringToColor:@"3049E9"];
            } break;
            case 1: {
                blockColor = [CommonTools stringToColor:@"485087"];
            } break;
            case 2: {
                blockColor = [CommonTools stringToColor:@"A4A8BF"];
            } break;
            case 3: {
                blockColor = [CommonTools stringToColor:@"061786"];
            } break;
            case 4: {
                blockColor = [CommonTools stringToColor:@"485398"];
            } break;
            default:
                break;
        }
        //CGPoint colorPoint = CGPointMake((double)column / (double)_columns, 1 - (double)row / (double)_rows);
        //UIColor *blockColor = [self.imageHelper getPixelColorAtLocation:colorPoint];
        //UIColor *blockColor = [UIColor clearColor];
        InteractionNode *node = [[InteractionNode alloc] initWithColor:blockColor size:blockSize];
        node.anchorPoint = CGPointMake(.5, .5);
        node.delegate = self;
        CGPoint blockPosition = CGPointMake(column * node.size.width + node.size.width / 2.0 + (screenSize.width - _columns * blockSize.width) / 2, row * node.size.height + node.size.height / 2.0 + (screenSize.height - _rows * blockSize.height) / 2);
        node.position = blockPosition;
        node.zPosition = 2;
        [self addChild:node];
        
        node.columnIndex = column;
        node.rowIndex = row;
        return node;
    }];
    [self.gamePad1 createGrid];
    //self.gamePad1.coolDownPeriod = 3;
    IBActionDescriptor *colorizeDescriptor = [[IBActionDescriptor alloc] init];
    colorizeDescriptor.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        //[(GameObject *)target runAction:[SKAction colorizeWithColor:[self getPixelColorAtLocation:CGPointMake((double)((GameObject *)target).columnIndex / (double)_columns, 1 - (double)((GameObject *)target).rowIndex / (double)_rows)] colorBlendFactor:1 duration:.3]];
        //[(GameObject *)target runAction:_colorAction];
        [(GameObject *)target runAction:_pulseAction];
        //[(GameObject *)target runAction:_rotateAction];
        //[(GameObject *)target runAction:[SKAction fadeAlphaTo:0 duration:1.5]];
        //((GameObject *)target).alpha = [CommonTools getRandomFloatFromFloat:0 toFloat:1];
        //((GameObject *)target).zPosition++;
        //CGPoint colorPoint = CGPointMake((double)((GameObject *)target).columnIndex / (double)_columns, 1 - (double)((GameObject *)target).rowIndex / (double)_rows);
        //colorPoint = CGPointMake(colorPoint.x * _sourceImage.size.width, colorPoint.y * _sourceImage.size.height);
        //[(GameObject *)target runAction:[SKAction colorizeWithColor:[self.imageHelper getPixelColorAtLocation:colorPoint] colorBlendFactor:1 duration:.3]];
        
        /*CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
         
         CGPoint positionInView = CGPointMake(sourcePosition.x * blockSize.width + blockSize.width / 2.0, sourcePosition.y * blockSize.height + blockSize.height / 2.0);
         CGSize screenSize = CGSizeMake(self.view.frame.size.width , self.view.frame.size.height );
         CGSize blockSize = CGSizeMake(30, 30);
         CGPoint blockPosition = CGPointMake(sourcePosition.x * blockSize.width + blockSize.width / 2.0 + (screenSize.width - _columns * blockSize.width) / 2, sourcePosition.y * blockSize.height + blockSize.height / 2.0 + (screenSize.height - _rows * blockSize.height) / 2);
         
         //NSLog(@"Pos: %@", NSStringFromCGPoint(blockPosition));
         
         [(GameObject *)target runAction:[SKAction sequence:@[[SKAction moveTo:positionInView duration:.3], [SKAction scaleTo:.5 duration:.15], [SKAction scaleTo:1 duration:.15]]]];*/
        
        GameObject *targetNode = (GameObject *)target;
        
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        CGPoint targetPosition = CGPointMake(targetNode.rowIndex, targetNode.columnIndex);
        
        //double xDist = fabs(sourcePosition.x - targetPosition.x);
        //double yDist = fabs(sourcePosition.y - targetPosition.y);
        
        //NSLog(@"Source: %@, Target: %@", NSStringFromCGPoint(sourcePosition), NSStringFromCGPoint(targetPosition));
        
        //targetNode.infoLabel.text = NSStringFromCGPoint(sourcePosition);
        
        //[targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:1.0 / (xDist + yDist) duration:.3], [SKAction scaleTo:1 duration:.3]]]];
    };
    [self.gamePad1 setUnifiedActionDescriptors:@[colorizeDescriptor]];
    
    /*if (_effectStepper == 0) {
     IBConnectionDescriptor *conn = [[IBConnectionDescriptor alloc] init];
     conn.connectionType = kConnectionTypeRandom;
     conn.isAutoFired = NO;
     conn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:50], [NSNumber numberWithInt:10], [NSNumber numberWithInt:-1]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion, kConnectionParameter_repeatCount]];
     [self.gamePad loadConnectionMapWithDescriptor:conn];
     } else if (_effectStepper == 1) {
     IBConnectionDescriptor *conn = [[IBConnectionDescriptor alloc] init];
     conn.connectionType = kConnectionTypeNeighbours;
     conn.isAutoFired = NO;
     conn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:-1]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_repeatCount]];
     [self.gamePad loadConnectionMapWithDescriptor:conn];
     } else {
     IBConnectionDescriptor *conn = [[IBConnectionDescriptor alloc] init];
     conn.connectionType = kConnectionTypeNeighbours_square;
     conn.isAutoFired = YES;
     conn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:3], [NSNumber numberWithInt:1]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_repeatCount]];
     [self.gamePad1 loadConnectionMapWithDescriptor:conn];
     //}*/
    
    IBConnectionDescriptor *conn = [[IBConnectionDescriptor alloc] init];
    conn.connectionType = kConnectionTypeNeighbours_square;
    conn.isAutoFired = YES;
    conn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:1]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_repeatCount]];
    [self.gamePad1 loadConnectionMapWithDescriptor:conn];
    
    /*IBConnectionDescriptor *conn = [[IBConnectionDescriptor alloc] init];
     conn.connectionType = kConnectionTypeRandom;
     conn.isAutoFired = NO;
     conn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:50], [NSNumber numberWithInt:10], [NSNumber numberWithInt:-1]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_dispersion, kConnectionParameter_repeatCount]];
     [self.gamePad1 loadConnectionMapWithDescriptor:conn];*/
    
    /*IBConnectionDescriptor *conn = [[IBConnectionDescriptor alloc] init];
     conn.connectionType = kConnectionTypeNeighbours;
     conn.isAutoFired = NO;
     conn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:-1]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_repeatCount]];
     [self.gamePad loadConnectionMapWithDescriptor:conn];*/
}

- (CIFilter *)blurFilter
{
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:20] forKey:@"inputRadius"];
    return filter;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    //NSLog(@"Touch");
    /*for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *nodeAtLocation = [self nodeAtPoint:location];
        NSLog(@"Node: %@", [nodeAtLocation class]);
        if ([nodeAtLocation isKindOfClass:[GameObject class]]) {
            [self.gamePad1 triggerNodeAtPosition:CGPointMake(((GameObject *)nodeAtLocation).columnIndex, ((GameObject *)nodeAtLocation).rowIndex)];
        }
    }*/
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    /*UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    CGPoint previousPosition = [touch previousLocationInNode:self];*/
    
    /*NSArray *nodes = [self nodesAtPoint:positionInScene];
    if ([nodes containsObject:_gridHolder1]) {
        SKNode *touchedObject = [self nodeAtPoint:positionInScene];
        //for (SKNode *node in touchedObjects) {
        if ([touchedObject isKindOfClass:[GameObject class]]) {
            [self.gamePad1 triggerNodeAtPosition:CGPointMake(((GameObject *)touchedObject).rowIndex, ((GameObject *)touchedObject).columnIndex)];
        }
        //}
    } else if ([nodes containsObject:_gridHolder2]) {
        
        SKNode *touchedObject = [self nodeAtPoint:positionInScene];
        //for (SKNode *node in touchedObjects) {
        if ([touchedObject isKindOfClass:[GameObject class]]) {
            [self.gamePad2 triggerNodeAtPosition:CGPointMake(((GameObject *)touchedObject).rowIndex, ((GameObject *)touchedObject).columnIndex)];
        }
        //}
    }*/
    
    /*SKNode *touchedObject = [self nodeAtPoint:positionInScene];
    //for (SKNode *node in touchedObjects) {
        if ([touchedObject isKindOfClass:[GameObject class]]) {
            [self.gamePad1 triggerNodeAtPosition:CGPointMake(((GameObject *)touchedObject).columnIndex, ((GameObject *)touchedObject).rowIndex)];
        }
    //}*/
    
    //CGPoint translation = CGPointMake(positionInScene.x - previousPosition.x, positionInScene.y - previousPosition.y);
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
        _bgTriggerInterval = [CommonTools getRandomFloatFromFloat:.4 toFloat:.5];
        [_bgPad triggerRandomNode];
        /*for (int i=0; i<_bgPad.gridSize.height; i++) {
            [_bgPad triggerNodeAtPosition:CGPointMake(i, 0)];
        }*/
    }
}

-(void)wipeScreen
{
    [self removeAllActions];
    [_gamePad1 clearActionPad];
    [self initEnvironment];
}

-(void)nodeTriggeredAtRow:(int)row andColumn:(int)column
{
    [_gamePad1 triggerNodeAtPosition:CGPointMake(column, row)];
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
