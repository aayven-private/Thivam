//
//  LevelDescriptor.h
//  thivam
//
//  Created by Ivan Borsa on 20/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LevelDescriptor : NSObject

@property (nonatomic) CGSize gridSize;
@property (nonatomic) BOOL withReference;
@property (nonatomic) int clickNum;
@property (nonatomic) int targetNum;

-(id)initWithLevelIndex:(int)levelIndex;

@end
