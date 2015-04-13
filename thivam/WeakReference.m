//
//  WeakReference.m
//  thivam
//
//  Created by Ivan Borsa on 13/04/15.
//  Copyright (c) 2015 ivanborsa. All rights reserved.
//

#import "WeakReference.h"

@implementation WeakReference

- (id) initWithObject:(id) object {
    if (self = [super init]) {
        nonretainedObjectValue = originalObjectValue = object;
    }
    return self;
}

+ (WeakReference *) weakReferenceWithObject:(id) object {
    return [[self alloc] initWithObject:object];
}

- (id) nonretainedObjectValue { return nonretainedObjectValue; }
- (void *) originalObjectValue { return (__bridge void *) originalObjectValue; }

// To work appropriately with NSSet
- (BOOL) isEqual:(WeakReference *) object {
    if (![object isKindOfClass:[WeakReference class]]) return NO;
    return object.originalObjectValue == self.originalObjectValue;
}

@end
