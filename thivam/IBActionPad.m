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
@property (nonatomic) CGPoint lastGridPosition;

@property (nonatomic) IBMatrix *recordMatrix;

@end

@implementation IBActionPad



-(id)initGridWithSize:(CGSize)size andNodeInitBlock:(nodeInit)initBlock
{
    if (self = [super init]) {
        self.initRule = initBlock;
        self.objectGrid = [[IBMatrix alloc] initWithRows:size.width andColumns:size.height];
        self.recordMatrix = [[IBMatrix alloc] initWithRows:size.width andColumns:size.height];
        self.isCoolingDown = NO;
        self.coolDownPeriod = 0;
        self.gridSize = size;
        self.isRecording = NO;
        self.lastGridPosition = CGPointMake(-1, -1);
    }
    return self;
}

-(void)createGridWithNodesActivated:(BOOL)isActivated
{
    for (int i=0; i<_objectGrid.columns; i++) {
        for (int j=0; j<_objectGrid.rows; j++) {
            id<IBActionNodeActor> node = _initRule(j, i);
            
            IBActionNode *actionNode = [[IBActionNode alloc] init];
            actionNode.nodeObject = node;
            actionNode.position = CGPointMake(j, i);
            actionNode.connections = [NSMutableArray array];
            actionNode.delegate = self;
            actionNode.isActive = isActivated;
            //actionNode.cleanupOnManualTrigger = YES;
            [_objectGrid setElement:actionNode atRow:j andColumn:i];
        }
    }
}

-(void)createRecordGrid
{
    for (int i=0; i<_recordMatrix.columns; i++) {
        for (int j=0; j<_recordMatrix.rows; j++) {
            NSMutableArray *recordNode = [NSMutableArray array];
            
            [_recordMatrix setElement:recordNode atRow:j andColumn:i];
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
                sourceNode.cleanupOnManualTrigger = NO;
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
                sourceNode.cleanupOnManualTrigger = NO;
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
                sourceNode.cleanupOnManualTrigger = NO;
                
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
                sourceNode.cleanupOnManualTrigger = YES;
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
    if (_isRecording) {
        IBActionNode *node = [_objectGrid getElementAtRow:position.y andColumn:position.x];
        if (!CGPointEqualToPoint(CGPointMake(-1, -1), _lastGridPosition) && !CGPointEqualToPoint(position, _lastGridPosition)) {
            IBActionNode *sourceNode = [_objectGrid getElementAtRow:_lastGridPosition.y andColumn:_lastGridPosition.x];
            [sourceNode.connections addObject:node];
            NSMutableArray *recordArray = [_recordMatrix getElementAtRow:_lastGridPosition.y andColumn:_lastGridPosition.x];
            [recordArray addObject:[NSString stringWithFormat:@"(%d,%d)", (int)(position.y), (int)(position.x)]];
        }
        _lastGridPosition = position;
        [node triggerConnectionsWithSource:position shouldPropagate:NO];
    } else {
        if (!_isCoolingDown) {
            IBActionNode *node = [_objectGrid getElementAtRow:position.y andColumn:position.x];
            if (node.isActive) {
                if (node.cleanupOnManualTrigger) {
                    [node cleanNode];
                }
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
    }
}

-(void)startRecordingGrid
{
    _isRecording = YES;
}

-(void)stopRecordingGrid
{
    _lastGridPosition = CGPointMake(-1, -1);
    _isRecording = NO;
}

-(NSString *)saveRecordedConnections
{
    NSMutableDictionary *connectionDescriptionDictionary = [NSMutableDictionary dictionary];
    [connectionDescriptionDictionary setObject:[NSNumber numberWithInt:_recordMatrix.columns] forKey:@"columns"];
    [connectionDescriptionDictionary setObject:[NSNumber numberWithInt:_recordMatrix.rows] forKey:@"rows"];
    NSMutableDictionary *connectionDictionary = [NSMutableDictionary dictionary];
    [connectionDescriptionDictionary setObject:connectionDictionary forKey:@"connections"];
    for (int i=0; i<_recordMatrix.columns; i++) {
        for (int j=0; j<_recordMatrix.rows; j++) {
            NSMutableArray *connectionArray = [_recordMatrix getElementAtRow:j andColumn:i];
            if (connectionArray.count > 0) {
                [connectionDictionary setObject:connectionArray forKey:[NSString stringWithFormat:@"(%d,%d)", j, i]];
            }
        }
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:connectionDescriptionDictionary options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return jsonStr;
}

-(void)setUpWithRecordedConnectionsGridIsAutoFired:(BOOL)isAutoFired andManualNodeCleanup:(BOOL)hasManualCleanup
{
    NSMutableDictionary *connectionDescriptionDictionary = [NSMutableDictionary dictionary];
    [connectionDescriptionDictionary setObject:[NSNumber numberWithInt:_recordMatrix.columns] forKey:@"columns"];
    [connectionDescriptionDictionary setObject:[NSNumber numberWithInt:_recordMatrix.rows] forKey:@"rows"];
    NSMutableDictionary *connectionDictionary = [NSMutableDictionary dictionary];
    [connectionDescriptionDictionary setObject:connectionDictionary forKey:@"connections"];
    for (int i=0; i<_recordMatrix.columns; i++) {
        for (int j=0; j<_recordMatrix.rows; j++) {
            NSMutableArray *connectionArray = [_recordMatrix getElementAtRow:j andColumn:i];
            [connectionDictionary setObject:connectionArray forKey:[NSString stringWithFormat:@"(%d,%d)", j, i]];
        }
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:connectionDescriptionDictionary options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [[NSUserDefaults standardUserDefaults] setObject:jsonStr forKey:@"saved_connections"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    for (int i=0; i<_objectGrid.columns; i++) {
        for (int j=0; j<_objectGrid.rows;j++) {
            IBActionNode *sourceNode = [_objectGrid getElementAtRow:j andColumn:i];
            sourceNode.actionSource = CGPointMake(-1, -1);
            sourceNode.cleanupOnManualTrigger = hasManualCleanup;
            sourceNode.autoFire = isAutoFired;
        }
    }
}

-(void)loadConnectionsFromDescription:(NSDictionary *)description
{
    NSNumber *rows = [description objectForKey:@"rows"];
    NSNumber *columns = [description objectForKey:@"columns"];
    NSDictionary *connections = [description objectForKey:@"connections"];
    if (rows.intValue != _recordMatrix.rows || columns.intValue != _recordMatrix.columns) {
        NSLog(@"Connection matrix does not fit grid... Returning...");
    } else {
        for (int i=0 ; i<columns.intValue; i++) {
            for (int j=0; j<rows.intValue; j++) {
                NSArray *connectionsForElement = [connections objectForKey:[NSString stringWithFormat:@"(%d,%d)", j, i]];
                IBActionNode *node = [_objectGrid getElementAtRow:j andColumn:i];
                [node.connections removeAllObjects];
                node.actionSource = CGPointMake(-1, -1);
                node.cleanupOnManualTrigger = YES;
                node.autoFire = YES;
                if (!connectionsForElement || connectionsForElement.count == 0) {
                    node.isActive = NO;
                } else {
                    node.isActive = YES;
                    for (NSString *conn in connectionsForElement) {
                        //NSLog(@" %@ ", conn);
                        NSString *parsed = [conn stringByReplacingOccurrencesOfString:@"(" withString:@""];
                        parsed = [parsed stringByReplacingOccurrencesOfString:@")" withString:@""];
                        NSArray* members = [parsed componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString: @","]];
                        int row = (int)[[members objectAtIndex:0] integerValue];
                        int column = (int)[[members objectAtIndex:1] integerValue];
                        
                        IBActionNode *targetNode = [_objectGrid getElementAtRow:row andColumn:column];
                        [node.connections addObject:targetNode];
                    }
                }
            }
        }
    }
}

-(void)setActions:(NSArray *)actions forNodeAtPosition:(CGPoint)position
{
    IBActionNode *node = [_objectGrid getElementAtRow:position.y andColumn:position.x];
    node.actions = actions;
}

-(void)setnodeActivated:(BOOL)isActive atPosition:(CGPoint)position
{
    IBActionNode *node = [_objectGrid getElementAtRow:position.y andColumn:position.x];
    node.isActive = isActive;
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
