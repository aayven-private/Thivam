//
//  IBActionNodeControllerDelegate.h
//  thivam
//
//  Created by Ivan Borsa on 24/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBActionDescriptor.h"

@protocol IBActionNodeControllerDelegate <NSObject>

-(NSArray *)getUnifiedActionDescriptors;

@end
