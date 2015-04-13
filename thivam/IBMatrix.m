//
//  IBMatrix.m
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "IBMatrix.h"

@interface IBMatrix()

@property (nonatomic) NSMutableArray *matrix;

@end

@implementation IBMatrix

-(id)initWithRows:(int)rows andColumns:(int)columns
{
    if (self = [super init]) {
        self.matrix = [NSMutableArray arrayWithCapacity:columns];
        for (int i=0; i<columns; i++) {
            NSMutableArray *row = [NSMutableArray arrayWithCapacity:rows];
            [self.matrix addObject:row];
        }
        self.rows = rows;
        self.columns = columns;
    }
    return self;
}

-(id)getElementAtRow:(int)row andColumn:(int)column
{
    NSMutableArray *matrixRow = [_matrix objectAtIndex:column];
    return [matrixRow objectAtIndex:row];
    
}

-(void)setElement:(id)element atRow:(int)row andColumn:(int)column
{
    NSMutableArray *matrixRow = [_matrix objectAtIndex:column];
    [matrixRow setObject:element atIndexedSubscript:row];
}

@end
