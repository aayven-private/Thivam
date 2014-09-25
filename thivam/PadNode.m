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

-(id)initWithColor:(UIColor *)color size:(CGSize)size andGridSize:(CGSize)gridSize withPhysicsBody:(BOOL)withBody andNodeColorCodes:(NSArray *)colorCodes andInteractionMode:(NSString *)interactionMode
{
    if (self = [super initWithColor:color size:size]) {
        
        if ([interactionMode isEqualToString:kInteractionMode_swipe]) {
            self.userInteractionEnabled = YES;
        } else {
            self.userInteractionEnabled = NO;
        }
        self.gridSize = gridSize;
        self.anchorPoint = CGPointMake(0.5, 0.5);
        
        self.actionPad = [[IBActionPad alloc] initGridWithSize:gridSize andNodeInitBlock:^id<IBActionNodeActor>(int row, int column){
            int colorIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)colorCodes.count - 1)];
            UIColor *blockColor = [CommonTools stringToColor:[colorCodes objectAtIndex:colorIndex]];
            CGSize blockSize = CGSizeMake(size.width / gridSize.width, size.height / gridSize.height);
            InteractionNode *node = [[InteractionNode alloc] initWithColor:blockColor size:blockSize];
            if ([interactionMode isEqualToString:kInteractionMode_touch]) {
                node.userInteractionEnabled = YES;
            } else {
                node.userInteractionEnabled = NO;
            }
            node.anchorPoint = CGPointMake(0.5, 0.5);
            node.delegate = self;
            CGPoint blockPosition = CGPointMake(column * node.size.width+ node.size.width / 2.0 - self.size.width / 2.0, row * node.size.height + node.size.height / 2.0 - self.size.height / 2.0);
            node.position = blockPosition;
            //node.zPosition = 2;
            [self addChild:node];
            node.columnIndex = column;
            node.rowIndex = row;
            return node;
        }];
        [self.actionPad createGrid];
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

-(void)loadActionDescriptor:(IBActionDescriptor *)actionDescriptor andConnectionDescriptor:(IBConnectionDescriptor *)connectionDescriptor
{
    self.actionPad.unifiedActionDescriptors = @[actionDescriptor];
    [self.actionPad loadConnectionMapWithDescriptor:connectionDescriptor];
}

-(void)nodeTriggeredAtRow:(int)row andColumn:(int)column
{
    [_actionPad triggerNodeAtPosition:CGPointMake(column, row)];
}

-(void)triggerRandomNode
{
    [_actionPad triggerNodeAtPosition:CGPointMake([CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.width - 1], [CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.height - 1])];
}

-(void)triggerNodeAtPosition:(CGPoint)position
{
    [_actionPad triggerNodeAtPosition:position];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    CGPoint previousPosition = [touch previousLocationInNode:self];
    
    SKNode *touchedObject = [self nodeAtPoint:positionInScene];
     //for (SKNode *node in touchedObjects) {
     if ([touchedObject isKindOfClass:[GameObject class]]) {
         if ([touchedObject isKindOfClass:[PadNode class]]) {
             return;
         }
         [self.actionPad triggerNodeAtPosition:CGPointMake(((GameObject *)touchedObject).columnIndex, ((GameObject *)touchedObject).rowIndex)];
         //NSLog(@"%@", NSStringFromCGPoint(CGPointMake(((GameObject *)touchedObject).columnIndex, ((GameObject *)touchedObject).rowIndex)));
         //NSLog(@"Node: %@", [touchedObject class]);
         
     }

}

@end
