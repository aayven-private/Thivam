//
//  GameScene.h
//  thivam
//

//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "InteractionNode.h"
#import "GameSceneHandler.h"

@interface GameScene : SKScene <GameObjectDelegate, SKPhysicsContactDelegate>

@property (nonatomic, weak) id<GameSceneHandler> sceneDelegate;

-(void)initEnvironment;
-(void)wipeScreen;

@end
