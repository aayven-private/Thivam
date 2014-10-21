//
//  HistoryScene.h
//  thivam
//
//  Created by Ivan Borsa on 21/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameSceneHandler.h"

@interface HistoryScene : SKScene

@property (nonatomic, weak) id<GameSceneHandler> sceneDelegate;

-(void)initEnvironment;

@end
