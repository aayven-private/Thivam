//
//  GameScene.h
//  thivam
//

//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "InteractionNode.h"

@interface GameScene : SKScene <GameObjectDelegate, SKPhysicsContactDelegate>

-(void)initEnvironment;
-(void)wipeScreen;

@end
