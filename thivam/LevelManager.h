//
//  LevelManager.h
//  thivam
//
//  Created by Ivan Borsa on 20/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBActionPad.h"
#import "SimulationNode.h"
#import "LevelEntityHelper.h"

@interface LevelManager : NSObject

@property (nonatomic) NSDictionary *currentLevel;

-(void)generateLevelWithGridsize:(CGSize)gridSize andNumberOfClicks:(int)clickNum andNumberOfTargets:(int)targetNum withNumberOfReferenceNodes:(int)referenceCount succesBlock:(void (^)(NSDictionary *levelInfo))successBlock;
-(void)saveLevel:(NSDictionary *)levelDescription forIndex:(int)levelIndex;
-(LevelEntityHelper *)getLevelForIndex:(int)levelIndex;
-(NSArray *)getSavedLevels;
-(NSArray *)getLevelsFromIndex:(int)fromIndex toIndex:(int)toIndex;

@end
