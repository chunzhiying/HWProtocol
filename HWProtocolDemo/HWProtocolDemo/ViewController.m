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

@protocol aaa <NSObject> @end

@interface Object : NSObject <Testable> @end @implementation Object @end
@interface Object2 : NSObject <Testable, aaa> @end @implementation Object2 @end
@interface ViewController () <Testable> @end

@defs(Testable, whereProtocol(aaa))

- (void)showTestString {
    NSLog(@"ccc");
}

@end

@defs(Testable, whereClass(Object))

- (void)showTestString {
    NSLog(@"ddd");
}

@end

@defs(Testable)

- (void)showTestString {
    NSLog(@"bbb");
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [[Object new] showTestString];
    [[Object2 new] showTestString];
    [self showTestString];
}

@end
