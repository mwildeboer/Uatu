//
//  NSObject+Uatu.h
//  Uatu
//
//  Created by Menno Wildeboer on 08/06/15.
//  Copyright (c) 2015 Menno Wildeboer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KVOObservationBlock)(id observer, id old, id new);
typedef id   (^KVOTransformBlock)(id value);
typedef id   (^KVOCollectionTransformBlock)(NSDictionary *values);

#define NSKeyValueOldNew        NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
#define NSKeyValueInitialNew    NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
#define NSKeyValueInitialOldNew NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew

@interface NSObject (Uatu)

- (void)observe:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KVOObservationBlock)block;

- (void)map:(NSString *)observedKeyPath to:(NSString *)toKeyPath;
- (void)map:(NSString *)observedKeyPath to:(NSString *)toKeyPath transformBlock:(KVOTransformBlock)transformBlock;
- (void)map:(NSString *)observedKeyPath toKeyPaths:(NSArray *)keypaths transformBlock:(KVOCollectionTransformBlock)transformBlock;

@end
