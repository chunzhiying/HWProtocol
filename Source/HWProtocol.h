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
#define defs _hw_extension

// Interface
#define _hw_extension($protocol) _hw_extension_imp($protocol, _hw_get_container_class($protocol))

// Implementation

#define _hw_extension_imp($protocol, $container_class) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wprotocol\"") \
_Pragma("clang diagnostic ignored \"-Wobjc-protocol-property-synthesis\"") \
    _hw_extension_imp_($protocol, $container_class) \
_Pragma("clang diagnostic pop") \

#define _hw_extension_imp_($protocol, $container_class) \
protocol $protocol; \
@interface $container_class : NSObject <$protocol> @end \
@implementation $container_class \
    + (void)load { \
        _hw_extension_load(@protocol($protocol), $container_class.class); \
    } \

// Get container class name by counter
#define _hw_get_container_class($protocol) _hw_get_container_class_imp($protocol, __COUNTER__)
#define _hw_get_container_class_imp($protocol, $counter) _hw_get_container_class_imp_concat(__HWContainer_, $protocol, $counter)
#define _hw_get_container_class_imp_concat($a, $b, $c) $a ## $b ## _ ## $c

void _hw_extension_load(Protocol *protocol, Class containerClass);
