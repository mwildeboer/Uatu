//
//  NSObject+Uatu.m
//  Uatu
//
//  Created by Menno Wildeboer on 08/06/15.
//  Copyright (c) 2015 Menno Wildeboer. All rights reserved.
//

#import <KVOController/FBKVOController.h>
#import <objc/runtime.h>
#import "NSObject+Uatu.h"

static void *kNSObjectKVOBindingsKey = &kNSObjectKVOBindingsKey;

@interface NSDictionary (Uatu)

- (id)objectForKeyOrNil:(id)key;

@end

@implementation NSDictionary (Uatu)

- (id)objectForKeyOrNil:(id)key
{
    id value = [self objectForKey:key];
    if ([value isEqual:[NSNull null]]) {
        return nil;
    }
    return value;
}

@end

@implementation NSObject (Uatu)

- (void)observe:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(KVOObservationBlock)block
{
    [self.KVOController observe:self keyPath:keyPath options:options block:^(id observer, id object, NSDictionary *change)
     {
         id oldValue = [change objectForKeyOrNil:NSKeyValueChangeOldKey];
         id newValue = [change objectForKeyOrNil:NSKeyValueChangeNewKey];
         if (block) {
             block(observer, oldValue, newValue);
         }
     }];
}

- (void)map:(NSString *)observedKeyPath to:(NSString *)toKeyPath
{
    [self map:observedKeyPath to:toKeyPath transformBlock:nil];
}

- (void)map:(NSString *)observedKeyPath to:(NSString *)toKeyPath transformBlock:(KVOTransformBlock)transformBlock
{
    NSMutableDictionary *bindingsForObservedKeyPath = [[self bindings] objectForKeyOrNil:observedKeyPath];
    BOOL hasBindings = bindingsForObservedKeyPath != nil;
    if (!hasBindings) {
        bindingsForObservedKeyPath = [[NSMutableDictionary alloc] init];
    }
    
    [bindingsForObservedKeyPath setObject:transformBlock ? transformBlock : ^id(id obj){ return obj; } forKey:toKeyPath];
    [[self bindings] setObject:bindingsForObservedKeyPath forKey:observedKeyPath];
    
    if (!hasBindings)
    {
        [self.KVOController observe:self keyPath:observedKeyPath options:NSKeyValueInitialNew block:^(id self, id object, NSDictionary *change)
         {
             id newValue = [change objectForKeyOrNil:NSKeyValueChangeNewKey];
             [bindingsForObservedKeyPath enumerateKeysAndObjectsUsingBlock:^(id key, KVOTransformBlock block, BOOL *stop) {
                 [self setValue:block(newValue) forKeyPath:key];
             }];
         }];
    }
}

- (void)map:(NSString *)observedKeyPath toKeyPaths:(NSArray *)keyPaths transformBlock:(KVOCollectionTransformBlock)transformBlock
{
    NSMutableDictionary *bindingsForObservedKeyPath = [[self bindings] objectForKeyOrNil:observedKeyPath];
    BOOL hasBindings = bindingsForObservedKeyPath != nil;
    if (!hasBindings) {
        bindingsForObservedKeyPath = [[NSMutableDictionary alloc] init];
    }
    
    [keyPaths enumerateObjectsUsingBlock:^(NSString *toKeyPath, NSUInteger idx, BOOL *stop) {
        [bindingsForObservedKeyPath setObject:transformBlock ? transformBlock : ^id(id obj){ return obj; } forKey:toKeyPath];
    }];
    [[self bindings] setObject:bindingsForObservedKeyPath forKey:observedKeyPath];
    
    if (!hasBindings)
    {
        [self.KVOController observe:self keyPath:observedKeyPath options:NSKeyValueInitialNew block:^(id self, id object, NSDictionary *change)
         {
             if (transformBlock)
             {
                 NSMutableDictionary *mutableChanges = [NSMutableDictionary dictionaryWithCapacity:keyPaths.count];
                 [keyPaths enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger idx, BOOL *stop)
                 {
                     id value = [self valueForKeyPath:keyPath];
                     if (value) {
                         [mutableChanges setObject:value forKey:keyPath];
                     }
                 }];
                 
                 [bindingsForObservedKeyPath enumerateKeysAndObjectsUsingBlock:^(id key, KVOTransformBlock block, BOOL *stop) {
                     [self setValue:transformBlock([mutableChanges copy]) forKeyPath:key];
                 }];
             }
         }];
    }
}

#pragma mark - Private

- (NSMutableDictionary *)bindings
{
    NSMutableDictionary *bindings = objc_getAssociatedObject(self, kNSObjectKVOBindingsKey);
    if (!bindings) {
        bindings = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, kNSObjectKVOBindingsKey, bindings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return bindings;
}

@end
