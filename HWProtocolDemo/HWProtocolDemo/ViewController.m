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

@end

@defs(Testable)

- (void)showTestString {
    NSLog(@"testString: %@", self.testString);
}

@end


@interface Object : NSObject <Testable>

@end


@implementation Object

- (NSString *)testString {
    return @"test Object";
}

@end


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Object new] showTestString];
}

@end
