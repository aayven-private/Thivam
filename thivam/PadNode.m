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

-(id)initWithColor:(UIColor *)color size:(CGSize)size andGridSize:(CGSize)gridSize
{
    if (self = [super initWithColor:color size:size]) {
        self.userInteractionEnabled = YES;
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.actionPad = [[IBActionPad alloc] initGridWithSize:gridSize andNodeInitBlock:^id<IBActionNodeActor>(int row, int column){
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
            CGSize blockSize = CGSizeMake(size.width / gridSize.width, size.height / gridSize.height);
            InteractionNode *node = [[InteractionNode alloc] initWithColor:blockColor size:blockSize];
            node.anchorPoint = CGPointMake(0.5, 0.5);
            node.delegate = self;
            CGPoint blockPosition = CGPointMake(column * node.size.width+ node.size.width / 2.0 - self.size.width / 2.0, row * node.size.height + node.size.height / 2.0 - self.size.height / 2.0);
            node.position = blockPosition;
            node.zPosition = 2;
            [self addChild:node];
            
            node.columnIndex = column;
            node.rowIndex = row;
            return node;
        }];
        [self.actionPad createGrid];
        //self.gamePad1.coolDownPeriod = 3;
        IBActionDescriptor *colorizeDescriptor = [[IBActionDescriptor alloc] init];
        colorizeDescriptor.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
            GameObject *targetNode = (GameObject *)target;
            //CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
            //CGPoint targetPosition = CGPointMake(targetNode.rowIndex, targetNode.columnIndex);
            [targetNode runAction:[SKAction sequence:@[[SKAction scaleTo:.5 duration:.3], [SKAction scaleTo:1 duration:.3]]]];
        };
        [self.actionPad setUnifiedActionDescriptors:@[colorizeDescriptor]];
        
        IBConnectionDescriptor *conn = [[IBConnectionDescriptor alloc] init];
        conn.connectionType = kConnectionTypeNeighbours_square;
        conn.isAutoFired = YES;
        conn.userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:2], [NSNumber numberWithInt:1]] forKeys:@[kConnectionParameter_counter, kConnectionParameter_repeatCount]];
        [self.actionPad loadConnectionMapWithDescriptor:conn];
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.contactTestBitMask = kObjectCategoryFrame;
        self.physicsBody.categoryBitMask = kObjectCategoryActionPad;
        self.physicsBody.collisionBitMask = kObjectCategoryFrame;
        self.physicsBody.mass = 1;
    }
    return self;
}

-(void)nodeTriggeredAtRow:(int)row andColumn:(int)column
{
    [_actionPad triggerNodeAtPosition:CGPointMake(column, row)];
}

-(void)triggerRandomNode
{
    [_actionPad triggerNodeAtPosition:CGPointMake([CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.width - 1], [CommonTools getRandomNumberFromInt:0 toInt:_actionPad.gridSize.height - 1])];
}

@end
