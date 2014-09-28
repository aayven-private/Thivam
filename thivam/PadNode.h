//
//  PadNode.h
//  thivam
//
//  Created by Ivan Borsa on 25/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "GameObject.h"
#import "IBActionPad.h"
#import <QuartzCore/QuartzCore.h>

static NSString *kInteractionMode_touch = @"interaction_mode_touch";
static NSString *kInteractionMode_swipe = @"interaction_mode_swipe";
static NSString *kInteractionMode_none = @"interaction_mode_none";

@interface PadNode : GameObject<GameObjectDelegate, IBActionNodeActor>

@property (nonatomic) CGSize gridSize;
@property (nonatomic) BOOL isRecording;

-(id)initWithColor:(UIColor *)color size:(CGSize)size andGridSize:(CGSize)gridSize withPhysicsBody:(BOOL)withBody andNodeColorCodes:(NSArray *)colorCodes andInteractionMode:(NSString *)interactionMode;
-(void)loadActionDescriptor:(IBActionDescriptor *)actionDescriptor andConnectionDescriptor:(IBConnectionDescriptor *)connectionDescriptor;

-(void)triggerRandomNode;
-(void)triggerNodeAtPosition:(CGPoint)position;

-(void)startRecording;
-(void)stopRecording;

-(void)setActionDescriptor:(IBActionDescriptor *)actionDescriptor;

-(void)loadConnectionsFromDescription:(NSDictionary *)description;

@end
