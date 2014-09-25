//
//  GameObjectDelegate.h
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameObjectDelegate <NSObject>

-(void)nodeTriggeredAtRow:(int)row andColumn:(int)column;

@end
