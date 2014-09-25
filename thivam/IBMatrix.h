//
//  IBMatrix.h
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface IBMatrix : NSObject

-(id)initWithRows:(int)rows andColumns:(int)columns;
-(id)getElementAtRow:(int)row andColumn:(int)column;
-(void)setElement:(id)element atRow:(int)row andColumn:(int)column;

@property (nonatomic) int rows;
@property (nonatomic) int columns;

@end
