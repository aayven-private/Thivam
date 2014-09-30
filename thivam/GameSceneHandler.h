//
//  GameSceneHandler.h
//  thivam
//
//  Created by Ivan Borsa on 30/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol GameSceneHandler <NSObject>

-(UIColor *)getColorAtPosition:(CGPoint)position;

@end
