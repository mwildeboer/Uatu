//
//  ViewModel.h
//  Uatu
//
//  Created by Menno Wildeboer on 08/06/15.
//  Copyright (c) 2015 Menno Wildeboer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewModel : NSObject

@property (nonatomic, readonly) NSString *title;

- (void)update;

@end
