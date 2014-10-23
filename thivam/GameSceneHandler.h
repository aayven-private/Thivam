//
//  GameSceneHandler.h
//  thivam
//
//  Created by Ivan Borsa on 30/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LevelEntityHelper.h"

@protocol GameSceneHandler <NSObject>

-(void)playClicked;
-(void)randomPlayClicked;
-(void)menuClicked;
-(void)historyClicked;
-(void)questLevelCompleted;
-(void)randomLevelCompleted;
-(void)historyLevelClicked:(LevelEntityHelper *)level;

@end
