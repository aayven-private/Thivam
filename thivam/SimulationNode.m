//
//  SimulationNode.m
//  thivam
//
//  Created by Ivan Borsa on 16/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "SimulationNode.h"

@implementation SimulationNode

-(void)fireAction:(IBActionDescriptor *)actionDescriptor userInfo:(NSDictionary *)userInfo forActionType:(NSString *)actionType
{
    actionDescriptor.action(self, userInfo);
}

@end
