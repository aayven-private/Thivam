//
//  IBActionNodeActor.h
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBActionDescriptor.h"

@protocol IBActionNodeActor <NSObject>

-(void)fireAction:(IBActionDescriptor *)actionDescriptor userInfo:(NSDictionary *)userInfo forActionType:(NSString *)actionType;

@end
