//
//  IBToken.m
//  thivam
//
//  Created by Ivan Borsa on 13/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "IBToken.h"

@implementation IBToken

@synthesize tokenId = _tokenId;
@synthesize tokenType = _tokenType;
@synthesize currentPosition = _currentPosition;
@synthesize userInfo = _userInfo;
@synthesize enterAction = _enterAction;
@synthesize exitAction = _exitAction;

-(id)mutableCopyWithZone:(NSZone *)zone
{
    IBToken *copy = [[IBToken alloc] init];
    
    copy.tokenId = [[NSUUID UUID] UUIDString];
    copy.tokenType = [_tokenType mutableCopyWithZone:zone];
    copy.currentPosition = _currentPosition;
    copy.userInfo = [_userInfo mutableCopyWithZone:zone];
    copy.enterAction = _enterAction;
    copy.exitAction = _exitAction;
    
    return copy;
}

@end
