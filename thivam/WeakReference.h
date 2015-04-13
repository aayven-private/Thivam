//
//  WeakReference.h
//  thivam
//
//  Created by Ivan Borsa on 13/04/15.
//  Copyright (c) 2015 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeakReference : NSObject {
    __weak id nonretainedObjectValue;
    __unsafe_unretained id originalObjectValue;
}

+ (WeakReference *) weakReferenceWithObject:(id) object;

- (id) nonretainedObjectValue;
- (void *) originalObjectValue;

@end