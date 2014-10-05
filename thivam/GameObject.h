//
//  GameObject.h
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Constants.h"
#import "GameObjectDelegate.h"
#import "IBActionNodeActor.h"

@interface GameObject : SKSpriteNode<IBActionNodeActor>

@property (nonatomic, weak) id<GameObjectDelegate> delegate;

@property (nonatomic) NSString *objectType;
@property (nonatomic) NSMutableArray *actions;
@property (atomic) NSMutableDictionary *runningActionForTypes;

@property (nonatomic) int rowIndex;
@property (nonatomic) int columnIndex;

@property (nonatomic) NSString *userActionType;

@property (nonatomic) UIColor *baseColor;

@property (nonatomic) UIColor *color1;
@property (nonatomic) UIColor *color2;

@property (nonatomic) BOOL isActionSource;
@property (nonatomic) BOOL isBlocker;

//@property (nonatomic) SKLabelNode *infoLabel;

@end
