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

@interface LevelManager : NSObject

@property (nonatomic) NSDictionary *currentLevel;

-(void)generateLevelWithGridsize:(CGSize)gridSize andNumberOfClicks:(int)clickNum andNumberOfTargets:(int)targetNum withReferenceNode:(BOOL)withReference succesBlock:(void (^)(NSDictionary *levelInfo))successBlock;

@end
