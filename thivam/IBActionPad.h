//
//  IBActionPad.h
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "IBMatrix.h"
#import "IBActionNodeActor.h"
#import "IBActionNode.h"
#import "IBActionDescriptor.h"
#import "IBConnectionDescriptor.h"

typedef id<IBActionNodeActor>(^nodeInit)(int row, int column);

static NSString *kConnectionTypeKey = @"connection_type";
static NSString *kConnectionParameter_counter = @"connection_parameter_counter";
static NSString *kConnectionParameter_dispersion = @"connection_parameter_dispersion";
static NSString *kConnectionParameter_autoFire = @"connection_parameter_autofire";
static NSString *kConnectionParameter_repeatCount = @"connection_parameter_repeatCount";

static NSString *kConnectionTypeNeighbours_square = @"grid_connection_neighbours_square";
static NSString *kConnectionTypeNeighbours_close = @"grid_connection_neighbours_close";
static NSString *kConnectionTypeRandom = @"grid_connection_random";
static NSString *kConnectionTypeLinear_bottomUp = @"grid_connection_linear_bottomup";
static NSString *kConnectionTypeLinear_topBottom = @"grid_connection_linear_topbottom";
static NSString *kConnectionTypeLinear_leftRight = @"grid_connection_linear_leftright";
static NSString *kConnectionTypeLinear_rightLeft = @"grid_connection_linear_rightleft";

@interface IBActionPad : NSObject<IBActionNodeControllerDelegate>

@property (nonatomic) IBMatrix *objectGrid;
@property (copy) nodeInit initRule;
@property (nonatomic) NSString *connectionType;
@property (nonatomic) NSMutableDictionary *unifiedActionDescriptors;
@property (nonatomic) CGFloat coolDownPeriod;
@property (nonatomic) CGSize gridSize;
@property (nonatomic) BOOL isRecording;
@property (nonatomic) int actionHeapSize;

-(id)initGridWithSize:(CGSize)size andNodeInitBlock:(nodeInit)initBlock andActionHeapSize:(int)actionHeapSize;
-(void)createGridWithNodesActivated:(BOOL)isActivated;
-(void)createRecordGrid;
-(void)loadConnectionMapWithDescriptor:(IBConnectionDescriptor *)connectionDescriptor forActionType:(NSString *)actionType;
-(void)triggerNodeAtPosition:(CGPoint)position forActionType:(NSString *)actionType withuserInfo:(NSMutableDictionary *)userInfo withNodeReset:(BOOL)reset;
-(void)triggerNodeAtPosition:(CGPoint)position forActionType:(NSString *)actionType withuserInfo:(NSMutableDictionary *)userInfo withNodeReset:(BOOL)reset withActionId:(NSString *)actionId;
-(void)clearActionPad;
-(void)startRecordingGrid;
-(void)stopRecordingGrid;
-(void)loadConnectionsFromDescription:(NSDictionary *)description withAutoFire:(BOOL)isautoFired andManualCleanup:(BOOL)cleanup forActionType:(NSString *)actionType;
-(void)setActions:(NSArray *)actions forNodeAtPosition:(CGPoint)position forActionType:(NSString *)actionType;
-(void)setnodeActivated:(BOOL)isActive atPosition:(CGPoint)position;
-(NSArray *)getUnifiedActionDescriptorsForActionType:(NSString *)actionType;

//-(void)setUpWithRecordedConnectionsGridIsAutoFired:(BOOL)isAutoFired andManualNodeCleanup:(BOOL)hasManualCleanup;

@end
