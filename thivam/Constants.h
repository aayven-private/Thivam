//
//  Constants.h
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

//static NSString *kObjectTypeInteractionNode = @"interaction_node";

static NSString *kActionTypeRotate = @"rotate";
static NSString *kActionTypePulse = @"pulse";
static NSString *kActionTypeSlide = @"slide";
static NSString *kActionTypeColorBlend = @"colorblend";
static NSString *kActionTypeRecolor = @"recolor";

static NSString *kObjectTypeActionPad = @"actionpad";
static NSString *kObjectTypeFrame = @"frame";

static uint32_t kObjectCategoryFrame = 0x1 << 0;
static uint32_t kObjectCategoryActionPad = 0x1 << 1;

