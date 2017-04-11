//
//  ViewController.m
//  HWProtocolDemo
//
//  Created by 陈智颖 on 2017/4/10.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "ViewController.h"
#import "HWProtocol.h"

@protocol Testable <NSObject>

@optional HWProtocolExtension
- (void)showTestString;

@end

@interface Object : NSObject <Testable> @end @implementation Object @end
@interface Object2 : NSObject <Testable> @end @implementation Object2 @end
@interface ViewController () <Testable> @end

@defs(Testable)

- (void)showTestString {
    NSLog(@"ddd");
}

@end

@defs(Testable, where(ViewController))

- (void)showTestString {
    NSLog(@"ccc");
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Object new] showTestString];
    [[Object2 new] showTestString];
    [self showTestString];
}

@end
