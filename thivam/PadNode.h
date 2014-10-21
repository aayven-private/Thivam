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
@property (nonatomic) BOOL disableOnFirstTrigger;
//@property (nonatomic) BOOL isDisabled;
@property (nonatomic) NSString *userActionType;
@property (nonatomic) int nodeIndex;
@property (nonatomic) SKLabelNode *infoLabel;

-(id)initWithColor:(UIColor *)color size:(CGSize)size andGridSize:(CGSize)gridSize withPhysicsBody:(BOOL)withBody andNodeColorCodes:(NSArray *)colorCodes andInteractionMode:(NSString *)interactionMode forActionType:(NSString *)actionType isInteractive:(BOOL)isInteractive withborderColor:(UIColor *)borderColor;
-(void)loadActionDescriptor:(IBActionDescriptor *)actionDescriptor andConnectionDescriptor:(IBConnectionDescriptor *)connectionDescriptor forActionType:(NSString *)actionType;

-(void)triggerRandomNodeForActionType:(NSString *)actionType withUserInfo:(NSMutableDictionary *)userInfo;
-(void)triggerNodeAtPosition:(CGPoint)position forActionType:(NSString *)actionType withUserInfo:(NSMutableDictionary *)userInfo forceDisable:(BOOL)forceDisable withNodeReset:(BOOL)reset;

-(void)startRecording;
-(void)stopRecording;

-(void)setActionDescriptor:(IBActionDescriptor *)actionDescriptor forActionType:(NSString *)actionType;

-(void)loadConnectionsFromDescription:(NSDictionary *)description forActionType:(NSString *)actionType;
-(void)setEnabled:(BOOL)isEnabled forAction:(NSString *)actionType;

//-(void)nodeTriggeredAtRow:(int)row andColumn:(int)column forActionType:(NSString *)actionType withUserInfo:(NSMutableDictionary *)userInfo

-(GameObject *)getNodeAtPosition:(CGPoint)position;
-(void)placeToken:(IBToken *)token atPosition:(CGPoint)position;
-(void)triggerToken:(IBToken *)token forActionType:(NSString *)actionType;


@end
