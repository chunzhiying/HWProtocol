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

@protocol bbb <NSObject>

@end

@protocol ccc <NSObject>

@end


@protocol aaa <NSObject> @end

@interface Object : UIView <Testable> @end @implementation Object @end
@interface Object2 : UIView <Testable, aaa, bbb> @end @implementation Object2 @end
@interface Object3 : UIView <Testable, aaa, bbb, ccc> @end @implementation Object3 @end
@interface ViewController () <Testable> @end

@defs(Testable, whereProtocol(aaa, bbb, ccc))

- (void)showTestString {
    NSLog(@"ccc");
}

@end

@defs(Testable, whereClass(UIView))

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
    [[Object3 new] showTestString];
    [self showTestString];
}

@end
