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
            self.gridColorScheme = @"A5FAB5";
        } else if (levelIndex < 5) {
            self.gridSize = CGSizeMake(3, 3);
            self.referenceNum = 0;
            self.clickNum = 2;
            self.targetNum = 1;
            self.gridColorScheme = @"A5FAB5";
        } else if (levelIndex < 9) {
            self.gridSize = CGSizeMake(3, 3);
            self.referenceNum = 0;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"79F790";
        } else if (levelIndex < 13) {
            self.gridSize = CGSizeMake(4, 4);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"3EDE5B";
        } else if (levelIndex < 17) {
            self.gridSize = CGSizeMake(5, 5);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"1ED941";
        } else if (levelIndex < 21) {
            self.gridSize = CGSizeMake(5, 5);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 3;
            self.gridColorScheme = @"F5FA9B";
        } else if (levelIndex < 25) {
            self.gridSize = CGSizeMake(6, 6);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"F3FA70";
        } else if (levelIndex < 29) {
            self.gridSize = CGSizeMake(6, 6);
            self.referenceNum = 2;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"F3FA70";
        } else if (levelIndex < 33) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 1;
            self.clickNum = 2;
            self.targetNum = 3;
            self.gridColorScheme = @"DCE622";
        } else if (levelIndex < 37) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"F7C36F";
        } else if (levelIndex < 41) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 2;
            self.targetNum = 3;
            self.gridColorScheme = @"FFBB4D";
        } else if (levelIndex < 45) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 1;
            self.clickNum = 3;
            self.targetNum = 2;
            self.gridColorScheme = @"F5A018";
        } else if (levelIndex < 49) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 1;
            self.clickNum = 3;
            self.targetNum = 3;
            self.gridColorScheme = @"F2B0A7";
        } else if (levelIndex < 53) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 3;
            self.targetNum = 3;
            self.gridColorScheme = @"ED8D80";
        } else if (levelIndex < 57) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 3;
            self.targetNum = 4;
            self.gridColorScheme = @"EB6654";
        } else if (levelIndex < 61) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 1;
            self.clickNum = 3;
            self.targetNum = 4;
            self.gridColorScheme = @"ED462F";
        } else if (levelIndex < 65) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 2;
            self.targetNum = 4;
            self.gridColorScheme = @"E82E15";
        } else if (levelIndex < 69) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 2;
            self.clickNum = 3;
            self.targetNum = 3;
            self.gridColorScheme = @"FA0A0A";
        } else if (levelIndex < 73) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 2;
            self.targetNum = 2;
            self.gridColorScheme = @"D58FF7";
        } else if (levelIndex < 77) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 2;
            self.targetNum = 3;
            self.gridColorScheme = @"C567F5";
        } else if (levelIndex < 81) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 3;
            self.gridColorScheme = @"B83DF5";
        } else if (levelIndex < 85) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 4;
            self.gridColorScheme = @"A511F0";
        } else if (levelIndex < 89) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 5;
            self.gridColorScheme = @"76E0F5";
        } else if (levelIndex < 93) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 6;
            self.gridColorScheme = @"4FDBF7";
        } else if (levelIndex < 97) {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 4;
            self.gridColorScheme = @"27D3F5";
        } else {
            self.gridSize = CGSizeMake(7, 7);
            self.referenceNum = 3;
            self.clickNum = 3;
            self.targetNum = 6;
            self.gridColorScheme = @"E82700";
        }
    }
    return self;
}

@end
