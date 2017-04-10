//
//  HWProtocol.m
//  HWProtocolDemo
//
//  Created by 陈智颖 on 2017/4/10.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define HWProtocolExtension

// For a magic reserved keyword color, use @defs(your_protocol_name)
#define defs _pk_extension

// Interface
#define _pk_extension($protocol) _pk_extension_imp($protocol, _pk_get_container_class($protocol))

// Implementation
#define _pk_extension_imp($protocol, $container_class) \
protocol $protocol; \
@interface $container_class : NSObject <$protocol> @end \
@implementation $container_class \
+ (void)load { \
_pk_extension_load(@protocol($protocol), $container_class.class); \
} \

// Get container class name by counter
#define _pk_get_container_class($protocol) _pk_get_container_class_imp($protocol, __COUNTER__)
#define _pk_get_container_class_imp($protocol, $counter) _pk_get_container_class_imp_concat(__PKContainer_, $protocol, $counter)
#define _pk_get_container_class_imp_concat($a, $b, $c) $a ## $b ## _ ## $c

void _pk_extension_load(Protocol *protocol, Class containerClass);
