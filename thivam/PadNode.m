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

@end

@implementation PadNode

-(id)initWithColor:(UIColor *)color size:(CGSize)size andGridSize:(CGSize)gridSize withPhysicsBody:(BOOL)withBody andNodeColorCodes:(NSArray *)colorCodes andInteractionMode:(NSString *)interactionMode forActionType:(NSString *)actionType
{
    if (self = [super initWithColor:color size:size]) {
        self.disableOnFirstTrigger = NO;
        self.isDisabled = NO;
        self.userActionType = actionType;
        if ([interactionMode isEqualToString:kInteractionMode_swipe]) {
            self.userInteractionEnabled = YES;
        } else {
            self.userInteractionEnabled = NO;
        }
        self.gridSize = gridSize;
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.isRecording = NO;
        
        self.actionPad = [[IBActionPad alloc] initGridWithSize:gridSize andNodeInitBlock:^id<IBActionNodeActor>(int row, int column){
            UIColor *blockColor;
            if (colorCodes && colorCodes.count > 0) {
                int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)colorCodes.count - 1)];
                blockColor = [CommonTools stringToColor:[colorCodes objectAtIndex:colorIndex]];
            } else {
                blockColor = color;
            }
            
            CGSize blockSize = CGSizeMake(size.width / gridSize.height, size.height / gridSize.width);
            InteractionNode *node = [[InteractionNode alloc] initWithColor:blockColor size:blockSize];
            if ([interactionMode isEqualToString:kInteractionMode_touch]) {
                node.userInteractionEnabled = YES;
            } else {
                node.userInteractionEnabled = NO;
            }
            node.anchorPoint = CGPointMake(0.5, 0.5);
            node.delegate = self;
            CGPoint blockPosition = CGPointMake(column * node.size.width - self.size.width / 2.0 + node.size.width / 2.0, row * node.size.height - self.size.height / 2.0 + node.size.height / 2.0);
            
            //CGPoint blockPosition = CGPointMake((gridSize.height - 1 - column) * node.size.width - self.size.width / 2.0 + node.size.width / 2.0, (gridSize.width - 1 - row) * node.size.height - self.size.height / 2.0 + node.size.height / 2.0);
            //node.alpha = 0;
            
            node.position = blockPosition;
            //node.zPosition = 1;
            [self addChild:node];
            node.columnIndex = column;
            node.rowIndex = row;
            node.userActionType = actionType;
            return node;
        }];
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
    [self.actionPad.unifiedActionDescriptors setObject:@[actionDescriptor] forKey:actionType];
    if (connectionDescriptor) {
        [self.actionPad loadConnectionMapWithDescriptor:connectionDescriptor forActionType:actionType];
    }
}

-(void)nodeTriggeredAtRow:(int)row andColumn:(int)column forActionType:(NSString *)actionType
{
    if (!_isDisabled) {
        if (_disableOnFirstTrigger) {
            _isDisabled = YES;
        }
        [_actionPad triggerNodeAtPosition:CGPointMake(column, row) forActionType:actionType];
    }
}

-(void)triggerRandomNodeForActionType:(NSString *)actionType
{
    
    if (!_isDisabled) {
        if (_disableOnFirstTrigger) {
            _isDisabled = YES;
        }
        [_actionPad triggerNodeAtPosition:CGPointMake([CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.height - 1], [CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.width - 1]) forActionType:actionType];
    }
}

-(void)triggerNodeAtPosition:(CGPoint)position forActionType:(NSString *)actionType
{
    if (!_isDisabled) {
        if (_disableOnFirstTrigger) {
            _isDisabled = YES;
        }
        [_actionPad triggerNodeAtPosition:position forActionType:actionType];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    //CGPoint previousPosition = [touch previousLocationInNode:self];
    
    SKNode *touchedObject = [self nodeAtPoint:positionInScene];
     //for (SKNode *node in touchedObjects) {
     if ([touchedObject isKindOfClass:[GameObject class]]) {
         if ([touchedObject isKindOfClass:[PadNode class]]) {
             return;
         }
         [self.actionPad triggerNodeAtPosition:CGPointMake(((GameObject *)touchedObject).columnIndex, ((GameObject *)touchedObject).rowIndex) forActionType:self.userActionType];
         //NSLog(@"%@", NSStringFromCGPoint(CGPointMake(((GameObject *)touchedObject).columnIndex, ((GameObject *)touchedObject).rowIndex)));
         //NSLog(@"Node: %@", [touchedObject class]);
     }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isRecording) {
        [_actionPad startRecordingGrid];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isRecording) {
        [_actionPad stopRecordingGrid];
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

-(void)loadConnectionsFromDescription:(NSDictionary *)description forActionType:(NSString *)actionType andIgnoreSource:(BOOL)ignoreSource
{
    [_actionPad loadConnectionsFromDescription:description withAutoFire:YES andManualCleanup:YES forActionType:actionType andIgnoreSource:ignoreSource];
}

/*-(void)fireAction:(IBActionDescriptor *)actionDescriptor userInfo:(NSDictionary *)userInfo
{
    actionDescriptor.action(self, userInfo);
}*/

@end
