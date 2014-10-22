//
//  LevelEntity.h
//  thivam
//
//  Created by Ivan Borsa on 21/10/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LevelEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * levelIndex;
@property (nonatomic, retain) NSData * levelInfo;
@property (nonatomic, retain) NSString * gridColorScheme;

@end
