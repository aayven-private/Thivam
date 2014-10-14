//
//  IBActionNodeActor.h
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBToken.h"

@protocol IBActionNodeActor <NSObject>

-(void)fireAction:(IBActionDescriptor *)actionDescriptor userInfo:(NSDictionary *)userInfo forActionType:(NSString *)actionType;

@optional

-(void)resetNode;
-(void)fireTokenAction_enterForToken:(IBToken *)token;
-(void)fireTokenAction_exitForToken:(IBToken *)token;

@end
