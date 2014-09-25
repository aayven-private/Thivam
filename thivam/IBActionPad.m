//
//  IBActionPad.m
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "IBActionPad.h"
#import "CommonTools.h"

@interface IBActionPad()

@property (nonatomic) BOOL isCoolingDown;

@end

@implementation IBActionPad



-(id)initGridWithSize:(CGSize)size andNodeInitBlock:(nodeInit)initBlock
{
    if (self = [super init]) {
        self.initRule = initBlock;
        self.objectGrid = [[IBMatrix alloc] initWithRows:size.width andColumns:size.height];
        self.isCoolingDown = NO;
        self.coolDownPeriod = 0;
        self.gridSize = size;
    }
    return self;
}

-(void)createGrid
{
    for (int i=0; i<_objectGrid.columns; i++) {
        for (int j=0; j<_objectGrid.rows; j++) {
            id<IBActionNodeActor> node = _initRule(j, i);
            
            IBActionNode *actionNode = [[IBActionNode alloc] init];
            actionNode.nodeObject = node;
            actionNode.position = CGPointMake(j, i);
            actionNode.connections = [NSMutableArray array];
            actionNode.delegate = self;
            
            [_objectGrid setElement:actionNode atRow:j andColumn:i];
        }
    }
}

-(void)loadConnectionMapWithDescriptor:(IBConnectionDescriptor *)connectionDescriptor
{
    NSString *connectionType = connectionDescriptor.connectionType;
    self.connectionType = connectionType;
    NSDictionary *userInfo = connectionDescriptor.userInfo;
    NSNumber *maxRepeatNum = [userInfo objectForKey:kConnectionParameter_repeatCount];
    if (!maxRepeatNum) {
        maxRepeatNum = [NSNumber numberWithInt:1];
    }
    if ([connectionType isEqualToString:kConnectionTypeNeighbours_square]) {
        NSNumber *connectionCounter = [userInfo objectForKey:kConnectionParameter_counter];
        for (int i=0; i<_objectGrid.columns; i++) {
            for (int j=0; j<_objectGrid.rows;j++) {
                IBActionNode *sourceNode = [_objectGrid getElementAtRow:j andColumn:i];
                sourceNode.actionSource = CGPointMake(-1, -1);
                //sourceNode.maxRepeatNum = maxRepeatNum.intValue;
                [sourceNode.connections removeAllObjects];
                sourceNode.autoFire = connectionDescriptor.isAutoFired;
                int fromRow = j > connectionCounter.intValue ? j - connectionCounter.intValue : 0;
                int toRow = j + connectionCounter.intValue < _objectGrid.rows ? j + connectionCounter.intValue : _objectGrid.rows - 1;
                
                int fromColumn = i > connectionCounter.intValue ? i - connectionCounter.intValue : 0;
                int toColumn = i + connectionCounter.intValue < _objectGrid.columns ? i + connectionCounter.intValue : _objectGrid.columns - 1;
                
                for (int c=fromColumn; c <= toColumn; c++) {
                    for (int r=fromRow; r <= toRow; r++) {
                        
                        if (j==r && i==c) {
                            continue;
                        }
                        
                        IBActionNode *targetnode = [_objectGrid getElementAtRow:r andColumn:c];
                        
                        [sourceNode.connections addObject:targetnode];
                    }
                }
            }
        }
    } else if ([connectionType isEqualToString:kConnectionTypeRandom]) {
        NSNumber *connectionCounter = [userInfo objectForKey:kConnectionParameter_counter];
        NSNumber *dispersion = [userInfo objectForKey:kConnectionParameter_dispersion];
        if (!dispersion) {
            dispersion = [NSNumber numberWithInt:0];
        }
        for (int i=0; i<_objectGrid.columns; i++) {
            for (int j=0; j<_objectGrid.rows;j++) {
                IBActionNode *sourceNode = [_objectGrid getElementAtRow:j andColumn:i];
                sourceNode.actionSource = CGPointMake(-1, -1);
                sourceNode.autoFire = connectionDescriptor.isAutoFired;
                int numberOfConnections = [CommonTools getRandomNumberFromInt:connectionCounter.intValue - dispersion.intValue toInt:connectionCounter.intValue + dispersion.intValue];
                NSMutableArray *alreadyConnected = [NSMutableArray array];
                [sourceNode.connections removeAllObjects];
                
                for (int c=0; c<numberOfConnections; c++) {
                    int connRow = [CommonTools getRandomNumberFromInt:0 toInt:_objectGrid.rows - 1];
                    int connCol = [CommonTools getRandomNumberFromInt:0 toInt:_objectGrid.columns - 1];
                    
                    NSValue *connPosition = [NSValue valueWithCGPoint:CGPointMake(connRow, connCol)];
                    if (![alreadyConnected containsObject:connPosition]) {
                        [alreadyConnected addObject:connPosition];
                        
                        IBActionNode *targetNode = [_objectGrid getElementAtRow:connRow andColumn:connCol];
                        
                        [sourceNode.connections addObject:targetNode];
                    }
                }
            }
        }
    } else if ([connectionType isEqualToString:kConnectionTypeNeighbours_close]) {
        //NSNumber *connectionCounter = [userInfo objectForKey:kConnectionParameter_counter];
        for (int i=0; i<_objectGrid.columns; i++) {
            for (int j=0; j<_objectGrid.rows;j++) {
                IBActionNode *sourceNode = [_objectGrid getElementAtRow:j andColumn:i];
                sourceNode.actionSource = CGPointMake(-1, -1);
                [sourceNode.connections removeAllObjects];
                sourceNode.autoFire = connectionDescriptor.isAutoFired;
                
                NSMutableArray *possibleNeighbours = [NSMutableArray array];
                
                if (i>0) {
                    [possibleNeighbours addObject:@"l"];
                }
                if (i<_objectGrid.columns - 1) {
                    [possibleNeighbours addObject:@"r"];
                }
                if (j>0) {
                    [possibleNeighbours addObject:@"t"];
                }
                if (j<_objectGrid.rows - 1) {
                    [possibleNeighbours addObject:@"b"];
                }
                
                for (NSString *n in possibleNeighbours) {
                    IBActionNode *targetNode;
                    if ([n isEqualToString:@"t"]) {
                        targetNode = [_objectGrid getElementAtRow:j-1 andColumn:i];
                    } else if ([n isEqualToString:@"b"]) {
                        targetNode = [_objectGrid getElementAtRow:j+1 andColumn:i];
                    } else if ([n isEqualToString:@"l"]) {
                        targetNode = [_objectGrid getElementAtRow:j andColumn:i-1];
                    } else if ([n isEqualToString:@"r"]) {
                        targetNode = [_objectGrid getElementAtRow:j andColumn:i+1];
                    }
                    if (targetNode) {
                        [sourceNode.connections addObject:targetNode];
                    }
                }
            }
        }
    } else if ([connectionType isEqualToString:kConnectionTypeLinear_bottomUp]) {
        for (int i=0; i<_objectGrid.columns; i++) {
            for (int j=0; j<_objectGrid.rows;j++) {
                IBActionNode *sourceNode = [_objectGrid getElementAtRow:j andColumn:i];
                sourceNode.actionSource = CGPointMake(-1, -1);
                //sourceNode.maxRepeatNum = maxRepeatNum.intValue;
                [sourceNode.connections removeAllObjects];
                sourceNode.autoFire = connectionDescriptor.isAutoFired;
                if (j<_objectGrid.rows - 1) {
                    IBActionNode *targetNode = [_objectGrid getElementAtRow:j+1 andColumn:i];
                    
                    [sourceNode.connections addObject:targetNode];
                }
            }
        }
    }
}

-(NSArray *)getUnifiedActionDescriptors
{
    
    return _unifiedActionDescriptors;
}

-(void)triggerNodeAtPosition:(CGPoint)position
{
    if (!_isCoolingDown) {
        IBActionNode *node = [_objectGrid getElementAtRow:position.y andColumn:position.x];
        [node triggerConnectionsWithSource:position shouldPropagate:YES];
        if (_coolDownPeriod > 0) {
            _isCoolingDown = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _coolDownPeriod * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    _isCoolingDown = NO;
                });
            });
        }
    }
}

-(void)clearActionPad
{
    self.objectGrid = nil;
    self.initRule = nil;
    self.connectionType = nil;
    self.unifiedActionDescriptors = nil;
    self.coolDownPeriod = 0;
    self.isCoolingDown = NO;
}

@end
