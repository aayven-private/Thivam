//
//  InteractionNode.h
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "GameObject.h"

@interface InteractionNode : GameObject

@property (nonatomic) SKLabelNode *infoLabel;
@property (nonatomic) int nodeValue;
@property (nonatomic) SKSpriteNode *innerNode;

-(id)initWithColor:(UIColor *)color size:(CGSize)size andBorderColor:(UIColor *)borderColor;

@end
