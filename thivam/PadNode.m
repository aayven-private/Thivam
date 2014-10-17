//
//  PadNode.m
//  thivam
//
//  Created by Ivan Borsa on 25/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "PadNode.h"
#import "CommonTools.h"
#import "InteractionNode.h"
#import "Constants.h"

@interface PadNode()

@property (nonatomic) IBActionPad *actionPad;
@property (nonatomic) NSMutableDictionary *enabledStates;

@property (nonatomic) UIColor *swipeColor;
@property (nonatomic) BOOL isSwiping;

@property (nonatomic) CGSize blockSize;

@end

@implementation PadNode

-(id)initWithColor:(UIColor *)color size:(CGSize)size andGridSize:(CGSize)gridSize withPhysicsBody:(BOOL)withBody andNodeColorCodes:(NSArray *)colorCodes andInteractionMode:(NSString *)interactionMode forActionType:(NSString *)actionType isInteractive:(BOOL)isInteractive withborderColor:(UIColor *)borderColor
{
    if (self = [super initWithColor:color size:size]) {
        self.isSwiping = NO;
        self.disableOnFirstTrigger = NO;
        self.enabledStates = [NSMutableDictionary dictionary];
        self.userActionType = actionType;
        if ([interactionMode isEqualToString:kInteractionMode_swipe]) {
            self.userInteractionEnabled = YES;
        } else {
            self.userInteractionEnabled = NO;
        }
        self.gridSize = gridSize;
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.isRecording = NO;
        self.blockSize = CGSizeMake(size.width / gridSize.width, size.height / gridSize.height);
        self.baseColor = color;
        self.actionPad = [[IBActionPad alloc] initGridWithSize:gridSize andNodeInitBlock:^id<IBActionNodeActor>(int row, int column){
            UIColor *blockColor;
            if (colorCodes && colorCodes.count > 0) {
                int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)colorCodes.count - 1)];
                blockColor = [CommonTools stringToColor:[colorCodes objectAtIndex:colorIndex]];
            } else {
                blockColor = color;
            }
            
            InteractionNode *node = [[InteractionNode alloc] initWithColor:blockColor size:_blockSize andBorderColor:borderColor];
            if ([interactionMode isEqualToString:kInteractionMode_touch]) {
                node.userInteractionEnabled = YES;
            } else {
                node.userInteractionEnabled = NO;
            }
            node.anchorPoint = CGPointMake(0.5, 0.5);
            node.delegate = self;
            //CGPoint blockPosition = CGPointMake(column * node.size.width - self.size.width / 2.0 + node.size.width / 2.0, row * node.size.height - self.size.height / 2.0 + node.size.height / 2.0);
            
            CGPoint blockPosition = CGPointMake(column * node.size.width - self.size.width / 2.0 + node.size.width / 2.0, row * node.size.height - self.size.height / 2.0 + node.size.height / 2.0);
            //node.alpha = 0;
            
            node.position = blockPosition;
            
            if (!isInteractive) {
                node.infoLabel.hidden = YES;
            }
            
            //node.zPosition = 1;
            [self addChild:node];
            node.columnIndex = column;
            node.rowIndex = row;
            node.userActionType = actionType;
            node.baseColor = blockColor;
            return node;
        } andActionHeapSize:30];
        
        //self.actionPad = [[IBActionPad alloc] initGridWithSize:gridSize andNodeInitBlock:initBlock];
        
        [self.actionPad createGridWithNodesActivated:YES];
        //self.gamePad1.coolDownPeriod = 3;
        
        if (withBody) {
            self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
            self.physicsBody.dynamic = YES;
            self.physicsBody.affectedByGravity = NO;
            self.physicsBody.contactTestBitMask = kObjectCategoryFrame;
            self.physicsBody.categoryBitMask = kObjectCategoryActionPad;
            self.physicsBody.collisionBitMask = kObjectCategoryFrame;
            self.physicsBody.mass = 1;
        }
    }
    return self;
}

-(void)loadActionDescriptor:(IBActionDescriptor *)actionDescriptor andConnectionDescriptor:(IBConnectionDescriptor *)connectionDescriptor forActionType:(NSString *)actionType
{
    if (actionDescriptor) {
        [self.actionPad.unifiedActionDescriptors setObject:@[actionDescriptor] forKey:actionType];
    }
    if (connectionDescriptor) {
        [self.actionPad loadConnectionMapWithDescriptor:connectionDescriptor forActionType:actionType];
    }
}

-(void)nodeTriggeredAtRow:(int)row andColumn:(int)column forActionType:(NSString *)actionType withUserInfo:(NSMutableDictionary *)userInfo
{
    /*if (!_isDisabled) {
        if (_disableOnFirstTrigger) {
            _isDisabled = YES;
        }
        [_actionPad triggerNodeAtPosition:CGPointMake(column, row) forActionType:actionType withuserInfo:userInfo forExclusiveAction:NO];
    }*/
    
    [self triggerNodeAtPosition:CGPointMake(column, row) forActionType:actionType withUserInfo:userInfo forceDisable:NO withNodeReset:NO];
}

-(void)triggerRandomNodeForActionType:(NSString *)actionType withUserInfo:(NSMutableDictionary *)userInfo
{
    
    /*if (!_isDisabled) {
        if (_disableOnFirstTrigger) {
            _isDisabled = YES;
        }
        [_actionPad triggerNodeAtPosition:CGPointMake([CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.height - 1], [CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.width - 1]) forActionType:actionType withuserInfo:userInfo forExclusiveAction:NO];
    }*/
    
    [self triggerNodeAtPosition:CGPointMake([CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.width - 1], [CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.height - 1]) forActionType:actionType withUserInfo:userInfo forceDisable:NO withNodeReset:NO];
}

-(void)triggerNodeAtPosition:(CGPoint)position forActionType:(NSString *)actionType withUserInfo:(NSMutableDictionary *)userInfo forceDisable:(BOOL)forceDisable withNodeReset:(BOOL)reset
{
    NSNumber * isEnabledForAction = [_enabledStates objectForKey:actionType];
    if (!isEnabledForAction) {
        isEnabledForAction = [NSNumber numberWithBool:YES];
        [_enabledStates setObject:isEnabledForAction forKey:actionType];
    }
    if (isEnabledForAction.boolValue) {
        if (_disableOnFirstTrigger || forceDisable) {
            [_enabledStates setObject:[NSNumber numberWithBool:NO] forKey:actionType];
        }
        [_actionPad triggerNodeAtPosition:position forActionType:actionType withuserInfo:userInfo withNodeReset:reset];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isSwiping) {
        UITouch *touch = [touches anyObject];
        CGPoint positionInScene = [touch locationInNode:self];
        //CGPoint previousPosition = [touch previousLocationInNode:self];
        
        SKNode *touchedObject = [self nodeAtPoint:positionInScene];
        
        //for (SKNode *node in touchedObjects) {
        if ([touchedObject isKindOfClass:[GameObject class]]) {
            if ([touchedObject isKindOfClass:[PadNode class]]) {
                return;
            }
            if (((GameObject *)touchedObject).isBlocker) {
                _isSwiping = NO;
                _swipeColor = nil;
                return;
            }
            [self.actionPad triggerNodeAtPosition:CGPointMake(((GameObject *)touchedObject).columnIndex, ((GameObject *)touchedObject).rowIndex) forActionType:self.userActionType withuserInfo:[NSMutableDictionary dictionaryWithObject:_swipeColor forKey:@"targetColor"] withNodeReset:NO];
            
            //NSLog(@"%@", NSStringFromCGPoint(CGPointMake(((GameObject *)touchedObject).columnIndex, ((GameObject *)touchedObject).rowIndex)));
            //NSLog(@"Node: %@", [touchedObject class]);
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*if (_isRecording) {
        [_actionPad startRecordingGrid];
    }*/
    
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    
    NSArray *objects = [self nodesAtPoint:positionInScene];
    //NSLog(@"Objects: %d", objects.count);
    for (SKNode *touchedNode in objects) {
        if ([touchedNode isKindOfClass:[InteractionNode class]]) {
            if (((InteractionNode *)touchedNode).isActionSource) {
                _swipeColor = ((InteractionNode *)touchedNode).baseColor;
                _isSwiping = YES;
                //[self runAction:[SKAction colorizeWithColor:_swipeColor colorBlendFactor:.3 duration:.5]];
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*if (_isRecording) {
        [_actionPad stopRecordingGrid];
    }*/
    
    //[self runAction:[SKAction colorizeWithColor:self.baseColor colorBlendFactor:1.0 duration:.2]];
    //self.color = self.baseColor;
    
    
    
    if (_isSwiping) {
        _isSwiping = NO;
        
        UITouch *touch = [touches anyObject];
        
        CGPoint positionInScene = [touch locationInNode:self];
        
        NSString *actionId = [[NSUUID UUID] UUIDString];
        
        [_actionPad triggerNodeAtPosition:[self gridPositionForScreenPosition:positionInScene] forActionType:@"check" withuserInfo:[NSMutableDictionary dictionaryWithObjects:@[_swipeColor, actionId] forKeys:@[@"checkColor", @"checkId"]] withNodeReset:NO withActionId:nil];
        
        /*NSArray *objects = [self nodesAtPoint:positionInScene];
        //NSLog(@"Objects: %d", objects.count);
        //NSLog(@"Position: %@", NSStringFromCGPoint(positionInScene));
        for (SKNode *touchedNode in objects) {
        //id touchedNode = [objects objectAtIndex:0];
            if ([touchedNode isKindOfClass:[InteractionNode class]]) {
                InteractionNode *gameNode = (InteractionNode *)touchedNode;
                //gameNode.color2 = _swipeColor;
                //if ([gameNode.color1 isEqual:_swipeColor]) {
                    //self.color = gameNode.color1;
                [_actionPad triggerNodeAtPosition:CGPointMake(gameNode.columnIndex, gameNode.rowIndex) forActionType:@"check" withuserInfo:[NSMutableDictionary dictionaryWithObjects:@[_swipeColor, actionId] forKeys:@[@"checkColor", @"checkId"]] withNodeReset:NO withActionId:nil];

                //}
            } else {
                NSLog(@"%@", [touchedNode class]);
            }
        }*/
        
        _swipeColor = nil;
    }
}

-(void)startRecording
{
    [_actionPad createRecordGrid];
    _isRecording = YES;
}

-(void)stopRecording
{
    _isRecording = NO;
    [_actionPad stopRecordingGrid];
    //[_actionPad setUpWithRecordedConnectionsGridIsAutoFired:YES andManualNodeCleanup:YES];
}

-(void)setActionDescriptor:(IBActionDescriptor *)actionDescriptor forActionType:(NSString *)actionType
{
    [_actionPad.unifiedActionDescriptors setObject:@[actionDescriptor] forKey:actionType];
}

-(void)loadConnectionsFromDescription:(NSDictionary *)description forActionType:(NSString *)actionType
{
    [_actionPad loadConnectionsFromDescription:description withAutoFire:YES andManualCleanup:YES forActionType:actionType];
}

/*-(void)fireAction:(IBActionDescriptor *)actionDescriptor userInfo:(NSDictionary *)userInfo
{
    actionDescriptor.action(self, userInfo);
}*/

-(void)nodeActionTaken:(NSString *)action withUserInfo:(NSDictionary *)userInfo
{
    if ([action isEqualToString:@"match"]) {
        NSValue *posVal = [userInfo objectForKey:@"position"];
        [self triggerNodeAtPosition:posVal.CGPointValue forActionType:@"action" withUserInfo:[userInfo mutableCopy] forceDisable:NO withNodeReset:NO];
    }
}

-(CGPoint)gridPositionForScreenPosition:(CGPoint) position
{
    CGPoint location = CGPointMake(position.x + self.size.width / 2, position.y + self.size.height / 2);
    
    int row = (location.y / _blockSize.height);
    int column = (location.x / _blockSize.width);
    
    if (row > _gridSize.height - 1) {
        row = _gridSize.height - 1;
    }
    
    if (column > _gridSize.width - 1) {
        column = _gridSize.width - 1;
    }
    
    return CGPointMake(column, row);
}

-(void)setEnabled:(BOOL)isEnabled forAction:(NSString *)actionType
{
    [_enabledStates setObject:[NSNumber numberWithBool:isEnabled] forKey:actionType];
}

-(void)placeToken:(IBToken *)token atPosition:(CGPoint)position
{
    [_actionPad placeToken:token atPosition:position];
}

-(void)triggerToken:(IBToken *)token forActionType:(NSString *)actionType
{
    [_actionPad triggerToken:token forActionType:actionType];
}

-(GameObject *)getNodeAtPosition:(CGPoint)position
{
    CGPoint positionInView = CGPointMake(position.x * _blockSize.width + _blockSize.width / 2.0 - self.size.width / 2.0, position.y * _blockSize.height + _blockSize.height / 2.0 - self.size.height / 2.0);
    
    NSArray *objectsInPos = [self nodesAtPoint:positionInView];
    
    for(id gameObject in objectsInPos) {
        if ([gameObject isKindOfClass:[GameObject class]]) {
            return gameObject;
        }
    }
    
    return nil;
}

@end
