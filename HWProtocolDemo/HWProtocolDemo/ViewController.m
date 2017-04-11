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

@required
@property (nonatomic, strong, readonly) NSString *testString;

@optional HWProtocolExtension
- (void)showTestString;
+ (void)show;

@end


@interface Object : NSObject <Testable>

- (NSString *)aaa;

@end


@implementation Object

- (NSString *)aaa {
    return @"aaa";
}

- (NSString *)testString {
    return @"test Object";
}

@end

@defs(Testable)

- (void)showTestString {
    NSLog(@"ccc");
}

@end

@defs(Testable, Where(Object))

- (void)showTestString {
    NSLog(@"testString: %@", [self aaa]);
}

@end

@interface ViewController () <Testable>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Object new] showTestString];
    [self showTestString];
}


@end

@defs(Testable, Where(ViewController))

- (void)showTestString {
    NSLog(@"testString: %@", @"bbb");
}

@end
