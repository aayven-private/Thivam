//
//  GameObject.m
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject

-(id)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        self.actions = [NSMutableArray array];
        self.isRunningAction = NO;
        /*self.infoLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.infoLabel.color = [UIColor whiteColor];
        self.infoLabel.fontSize = 8;
        self.infoLabel.userInteractionEnabled = NO;
        [self addChild:self.infoLabel];*/
    }
    return self;
}

-(void)fireAction:(IBActionDescriptor *)actionDescriptor userInfo:(NSDictionary *)userInfo
{
    if (!self.isRunningAction) {
        self.isRunningAction = YES;
        actionDescriptor.action(self, userInfo);
    }
}

@end
