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
            self.gridColorScheme = @"00FF00";
            self.bgColorScheme = @"0000FF";
        } else if (levelIndex < 5) {
            self.gridSize = CGSizeMake(3, 3);
            self.referenceNum = 0;
            self.clickNum = 2;
            self.targetNum = 1;
            self.gridColorScheme = @"33CC33";
            self.bgColorScheme = @"3333FF";
        } else if (levelIndex < 9) {
            self.gridSize = CGSizeMake(3, 3);
            self.referenceNum = 0;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"CCFF33";
            self.bgColorScheme = @"3366FF";
        } else if (levelIndex < 13) {
            self.gridSize = CGSizeMake(4, 4);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"FFFF00";
            self.bgColorScheme = @"3333CC";
        } else if (levelIndex < 17) {
            self.gridSize = CGSizeMake(5, 5);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"FFCC00";
            self.bgColorScheme = @"6600FF";
        } else if (levelIndex < 21) {
            self.gridSize = CGSizeMake(5, 5);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 3;
            self.gridColorScheme = @"FF9900";
            self.bgColorScheme = @"6600CC";
        } else if (levelIndex < 25) {
            self.gridSize = CGSizeMake(6, 6);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"0099FF";
            self.bgColorScheme = @"FF6600";
        } else if (levelIndex < 29) {
            self.gridSize = CGSizeMake(6, 6);
            self.referenceNum = 2;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"33CCFF";
            self.bgColorScheme = @"FF0000";
        } else if (levelIndex < 33) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 3;
            self.gridColorScheme = @"00CC00";
            self.bgColorScheme = @"FF0000";
        } else if (levelIndex < 37) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"009900";
            self.bgColorScheme = @"FFCC00";
        } else if (levelIndex < 41) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 2;
            self.targetNum = 3;
            self.gridColorScheme = @"FFFF00";
            self.bgColorScheme = @"3333CC";
        } else if (levelIndex < 45) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 1;
            self.clickNum = 3;
            self.targetNum = 2;
            self.gridColorScheme = @"FF0066";
            self.bgColorScheme = @"00CC00";
        } else if (levelIndex < 49) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 1;
            self.clickNum = 3;
            self.targetNum = 3;
            self.gridColorScheme = @"666699";
            self.bgColorScheme = @"000066";
        } else if (levelIndex < 53) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 3;
            self.targetNum = 3;
            self.gridColorScheme = @"99CCFF";
            self.bgColorScheme = @"009933";
        } else if (levelIndex < 57) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 3;
            self.targetNum = 4;
            self.gridColorScheme = @"33CC33";
            self.bgColorScheme = @"0000FF";
        } else if (levelIndex < 61) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 1;
            self.clickNum = 3;
            self.targetNum = 4;
            self.gridColorScheme = @"009900";
            self.bgColorScheme = @"FF0000";
        } else if (levelIndex < 65) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 2;
            self.targetNum = 4;
            self.gridColorScheme = @"FF3300";
            self.bgColorScheme = @"FFFF00";
        } else if (levelIndex < 69) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 3;
            self.targetNum = 3;
            self.gridColorScheme = @"FF0000";
            self.bgColorScheme = @"009933";
        } else if (levelIndex < 73) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"009933";
            self.bgColorScheme = @"0000CC";
        } else if (levelIndex < 77) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 2;
            self.targetNum = 3;
            self.gridColorScheme = @"FF9966";
            self.bgColorScheme = @"006600";
        } else if (levelIndex < 81) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 3;
            self.gridColorScheme = @"6699FF";
            self.bgColorScheme = @"990000";
        } else if (levelIndex < 85) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 4;
            self.gridColorScheme = @"33CCCC";
            self.bgColorScheme = @"333300";
        } else if (levelIndex < 89) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 5;
            self.gridColorScheme = @"E04C44";
            self.bgColorScheme = @"006600";
        } else if (levelIndex < 93) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 6;
            self.gridColorScheme = @"3366CC";
            self.bgColorScheme = @"FF0000";
        } else if (levelIndex < 97) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 4;
            self.gridColorScheme = @"009999";
            self.bgColorScheme = @"99FF99";
        } else {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 6;
            self.gridColorScheme = @"CC00CC";
            self.bgColorScheme = @"000066";
        }
    }
    return self;
}

@end
