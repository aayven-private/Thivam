//
//  MenuScene.h
//  thivam
//
//  Created by Ivan Borsa on 17/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PadNode.h"
#import "GameSceneHandler.h"

@interface MenuScene : SKScene

@property (nonatomic, weak) id<GameSceneHandler> sceneDelegate;

-(void)initEnvironment;

@end
