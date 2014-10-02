//
//  IBActionNode.h
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "IBActionNodeActor.h"
#import "IBActionNodeControllerDelegate.h"

@interface IBActionNode : NSObject

@property (nonatomic, weak) id<IBActionNodeControllerDelegate> delegate;
@property (nonatomic) CGPoint position;
@property (nonatomic) id<IBActionNodeActor> nodeObject;
@property (nonatomic) NSMutableDictionary *connections;
@property (nonatomic) NSMutableDictionary *actions;
@property (nonatomic) int actionHeapSize;
//@property (nonatomic) BOOL autoFire;
//@property (nonatomic) int maxRepeatNum;
//@property (nonatomic) int repeatCount;
//@property (nonatomic) CGFloat triggerDelay;
//@property (nonatomic) CGPoint actionSource;

@property (nonatomic) NSMutableArray *actionIds;

@property (nonatomic) NSMutableDictionary *actionSources;

//@property (nonatomic) BOOL cleanupOnManualTrigger;
@property (nonatomic) BOOL isActive;
//@property (nonatomic) BOOL ignoreSource;
@property (nonatomic) NSMutableDictionary *connectionDescriptors;

//-(void)triggerConnections;
//-(void)fireActions;

-(void)triggerConnectionsWithSource:(CGPoint)source shouldPropagate:(BOOL)shouldPropagate forActionType:(NSString *)actionType withUserInfo:(NSMutableDictionary *)userInfo withNodeReset:(BOOL)reset withActionId:(NSString *)actionId;
-(void)cleanNodeForActionType:(NSString *)actionType;

@end
