//
//  IBConnectionDescriptor.h
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IBConnectionDescriptor : NSObject

@property (nonatomic) NSString *connectionType;
@property (nonatomic) BOOL isAutoFired;
@property (nonatomic) BOOL manualCleanup;
@property (nonatomic) BOOL ignoreSource;
@property (nonatomic) NSDictionary *userInfo;
@property (nonatomic) float autoFireDelay;

@end
