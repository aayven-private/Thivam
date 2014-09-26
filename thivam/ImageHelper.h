//
//  ImageHelper.h
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ImageHelper : NSObject

+(UIColor *)getRandomColor;

-(void)loadDataFromImage:(UIImage *)image;
- (UIColor*)getPixelColorAtLocation:(CGPoint)point;

@end
