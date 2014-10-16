//
//  SimulationNode.h
//  thivam
//
//  Created by Ivan Borsa on 16/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBActionNodeActor.h"

@interface SimulationNode : NSObject <IBActionNodeActor>

@property (nonatomic) int columnIndex;
@property (nonatomic) int rowIndex;
@property (nonatomic) int nodeValue;

@end
