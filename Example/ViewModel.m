//
//  ViewModel.m
//  Uatu
//
//  Created by Menno Wildeboer on 08/06/15.
//  Copyright (c) 2015 Menno Wildeboer. All rights reserved.
//

#import "ViewModel.h"

@interface ViewModel ()

@property (nonatomic, strong) NSString *title;

@end

@implementation ViewModel

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Hello world";
    }
    return self;
}

@end
