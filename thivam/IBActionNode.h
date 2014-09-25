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
@property (nonatomic) NSMutableArray *connections;
@property (nonatomic) NSArray *actions;
@property (nonatomic) BOOL autoFire;
@property (nonatomic) int maxRepeatNum;
@property (nonatomic) int repeatCount;
@property (nonatomic) CGFloat triggerDelay;
@property (nonatomic) CGPoint actionSource;
@property (nonatomic) BOOL cleanupOnManualTrigger;

//-(void)triggerConnections;
//-(void)fireActions;

-(void)triggerConnectionsWithSource:(CGPoint)source shouldPropagate:(BOOL)shouldPropagate;
-(void)cleanNode;

@end
