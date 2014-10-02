//
//  Constants.h
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

//static NSString *kObjectTypeInteractionNode = @"interaction_node";

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    if (length == 0.0) {
        length = FLT_MIN;
    }
    return CGPointMake(a.x / length, a.y / length);
}

static NSString *kActionTypeRotate = @"rotate";
static NSString *kActionTypePulse = @"pulse";
static NSString *kActionTypeSlide = @"slide";
static NSString *kActionTypeColorBlend = @"colorblend";
static NSString *kActionTypeRecolor = @"recolor";

static NSString *kObjectTypeActionPad = @"actionpad";
static NSString *kObjectTypeFrame = @"frame";

static uint32_t kObjectCategoryFrame = 0x1 << 0;
static uint32_t kObjectCategoryActionPad = 0x1 << 1;

