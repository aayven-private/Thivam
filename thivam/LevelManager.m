//
//  LevelManager.m
//  thivam
//
//  Created by Ivan Borsa on 20/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "LevelManager.h"
#import "CommonTools.h"

@interface LevelManager()

@property (nonatomic) CGPoint simulationReferencePoint;
@property (nonatomic) IBActionPad *simulationPad;
@property (nonatomic) int simulationCount;

@end

@implementation LevelManager

-(id)init
{
    if (self = [super init]) {
        self.currentLevel = nil;
        self.simulationCount = 0;
    }
    return self;
}

-(void)generateLevelWithGridsize:(CGSize)gridSize andNumberOfClicks:(int)clickNum andNumberOfTargets:(int)targetNum withNumberOfReferenceNodes:(int)referenceCount succesBlock:(void (^)(NSDictionary *levelInfo))successBlock
{
    __block NSMutableDictionary *nodes = [NSMutableDictionary dictionary];
    __block int actualSimulationCount = 0;
    _simulationCount = clickNum * gridSize.height * gridSize.width;
    __block NSMutableSet *targetPoints = [NSMutableSet set];
    __block NSMutableSet *referencePoints = [NSMutableSet set];
    __block NSMutableArray *clicks = [NSMutableArray array];
    IBActionDescriptor *boomActionDesc = [[IBActionDescriptor alloc] init];
    boomActionDesc.action = ^(id<IBActionNodeActor>target, NSDictionary *userInfo) {
        SimulationNode *targetNode = (SimulationNode *)target;
        CGPoint sourcePosition = ((NSValue *)[userInfo objectForKey:@"position"]).CGPointValue;
        
        int distX = (int)targetNode.columnIndex - (int)sourcePosition.x;
        int distY = (int)targetNode.rowIndex - (int)sourcePosition.y;
        
        //int distX_ref = targetNode.columnIndex - _simulationReferencePoint.x;
        //int distY_ref = targetNode.rowIndex - _simulationReferencePoint.y;
        
        int distX_ref = 0;
        int distY_ref = 0;
        
        for (NSValue *refPoint_val in referencePoints) {
            distX_ref += targetNode.columnIndex - refPoint_val.CGPointValue.x;
            distY_ref += targetNode.rowIndex - refPoint_val.CGPointValue.y;
        }
        
        targetNode.nodeValue += (distX_ref + distY_ref) + (distX + distY);
        //targetNode.nodeValue += withReference ? (distX_ref + distY_ref) + (distX + distY) : (distX + distY);
        
        actualSimulationCount++;
        if (_simulationCount == actualSimulationCount) {
            actualSimulationCount = 0;
            
            NSMutableDictionary *levelInfo = [NSMutableDictionary dictionary];
            
            NSMutableDictionary *targetValues = [NSMutableDictionary dictionary];
            
            for (NSValue *targetPoint in targetPoints) {
                CGPoint tp = targetPoint.CGPointValue;
                SimulationNode *node = [nodes objectForKey:[NSString stringWithFormat:@"%d;%d", (int)tp.x, (int)tp.y]];
                [targetValues setObject:[NSNumber numberWithInt:node.nodeValue] forKey:[NSString stringWithFormat:@"%d;%d", node.columnIndex, node.rowIndex]];
            }
            
            [levelInfo setObject:targetValues forKey:@"targets"];
            
            NSMutableArray *referencePoints_str = [NSMutableArray arrayWithCapacity:referencePoints.count];
            for (NSValue *refPoint_val in referencePoints) {
                [referencePoints_str addObject:[NSString stringWithFormat:@"%d;%d", (int)refPoint_val.CGPointValue.x, (int)refPoint_val.CGPointValue.y]];
            }
            [levelInfo setObject:referencePoints_str forKey:@"reference_points"];

            NSMutableArray *clicks_str = [NSMutableArray arrayWithCapacity:referencePoints.count];
            for (NSValue *clickPoint_val in clicks) {
                [clicks_str addObject:[NSString stringWithFormat:@"%d;%d", (int)clickPoint_val.CGPointValue.x, (int)clickPoint_val.CGPointValue.y]];
            }
            [levelInfo setObject:clicks_str forKey:@"clicks"];
            
            [levelInfo setObject:[NSString stringWithFormat:@"%d;%d", (int)gridSize.width, (int)gridSize.height] forKey:@"grid_size"];
            
            successBlock(levelInfo);
            [self saveLevel:levelInfo];
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
        [nodes setObject:node forKey:[NSString stringWithFormat:@"%d;%d", column, row]];
        return node;
    } andActionHeapSize:30];
    [_simulationPad createGridWithNodesActivated:YES];
    [_simulationPad.unifiedActionDescriptors setObject:@[boomActionDesc] forKey:@"boom"];
    [_simulationPad loadConnectionMapWithDescriptor:boomConn forActionType:@"boom"];
    
    int columnIndex = [CommonTools getRandomNumberFromInt:0 toInt:gridSize.width - 1];
    int rowIndex = [CommonTools getRandomNumberFromInt:0 toInt:gridSize.height - 1];
    
    _simulationReferencePoint = CGPointMake(columnIndex, rowIndex);
    
    NSMutableArray *allPoints = [NSMutableArray array];
    for (int i=0; i<gridSize.width; i++) {
        for (int j=0; j<gridSize.height; j++) {
            [allPoints addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
        }
    }
    
    for (int i=0; i<targetNum; i++) {
        int randomIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)allPoints.count) - 1];
        NSValue *point = [allPoints objectAtIndex:randomIndex];
        [targetPoints addObject:point];
        [allPoints removeObject:point];
    }
    
    allPoints = [NSMutableArray array];
    for (int i=0; i<gridSize.width; i++) {
        for (int j=0; j<gridSize.height; j++) {
            [allPoints addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
        }
    }
    
    for (int i=0; i<referenceCount; i++) {
        int randomIndex = [CommonTools getRandomNumberFromInt:0 toInt:((int)allPoints.count) - 1];
        NSValue *point = [allPoints objectAtIndex:randomIndex];
        [referencePoints addObject:point];
        [allPoints removeObject:point];
    }
    
    for (int i=0; i<clickNum; i++) {
        int columnIndex = [CommonTools getRandomNumberFromInt:0 toInt:gridSize.width - 1];
        int rowIndex = [CommonTools getRandomNumberFromInt:0 toInt:gridSize.height - 1];
        CGPoint clickPoint = CGPointMake(columnIndex, rowIndex);
        [clicks addObject:[NSValue valueWithCGPoint:clickPoint]];
        [_simulationPad triggerNodeAtPosition:clickPoint forActionType:@"boom" withuserInfo:nil withNodeReset:NO];
    }
}

-(void)saveLevel:(NSDictionary *)levelDescription
{
    NSLog(@"%@", levelDescription);
}

@end
