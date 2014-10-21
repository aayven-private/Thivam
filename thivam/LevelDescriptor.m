//
//  LevelDescriptor.m
//  thivam
//
//  Created by Ivan Borsa on 20/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "LevelDescriptor.h"

@implementation LevelDescriptor

-(id)initWithLevelIndex:(int)levelIndex
{
    if (self = [super init]) {
        if (levelIndex == 1) {
            self.gridSize = CGSizeMake(2, 2);
            self.referenceNum = 0;
            self.clickNum = 1;
            self.targetNum = 1;
        } else if (levelIndex < 3) {
            self.gridSize = CGSizeMake(3, 3);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 2;
        } else if (levelIndex < 6) {
            self.gridSize = CGSizeMake(4, 4);
            self.referenceNum = 2;
            self.clickNum = 2;
            self.targetNum = 2;
        } else if (levelIndex < 9) {
            self.gridSize = CGSizeMake(5, 5);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 2;
        } else if (levelIndex < 12) {
            self.gridSize = CGSizeMake(5, 5);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 3;
        } else if (levelIndex < 15) {
            self.gridSize = CGSizeMake(5, 5);
            self.referenceNum = 1;
            self.clickNum = 3;
            self.targetNum = 3;
        } else if (levelIndex < 18) {
            self.gridSize = CGSizeMake(6, 6);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 3;
        } else if (levelIndex < 21) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 3;
        } else {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 1;
            self.clickNum = 3;
            self.targetNum = 3;
        }
    }
    return self;
}

@end
