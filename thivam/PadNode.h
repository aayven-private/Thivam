//
//  PadNode.h
//  thivam
//
//  Created by Ivan Borsa on 25/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "GameObject.h"
#import "IBActionPad.h"

@interface PadNode : GameObject<GameObjectDelegate>

-(id)initWithColor:(UIColor *)color size:(CGSize)size andGridSize:(CGSize)gridSize;

-(void)triggerRandomNode;

@end
