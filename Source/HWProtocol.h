//
//  HWProtocol.m
//  HWProtocolDemo
//
//  Created by 陈智颖 on 2017/4/10.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define defs _hw_extension // use @defs(your_protocol_name) or @defs(your_protocol_name, where(special_class_name))

#define HWProtocolExtension
#define whereClass($class) $class
#define whereProtocol(...) NSObject, __VA_ARGS__  // Max: 3


// Utils
#define HW_MACROCAT_(x, y)  x##y
#define HW_MACROCAT(x, y)   HW_MACROCAT_(x, y)

#define HW_META_head(...)             HW_META_head_(__VA_ARGS__, 0)
#define HW_META_head_(FIRST, ...)     FIRST

#define HW_META_at5(_0, _1, _2, _3, _4, ...)        HW_META_head(__VA_ARGS__)

#define HW_META_at(N, ...)            HW_MACROCAT(HW_META_at, 5)(__VA_ARGS__)
#define HW_META_argCount(...)         HW_META_at(5, __VA_ARGS__, 5, 4, 3, 2, 1)


// Interface
#define _hw_extension(...)            HW_MACROCAT(_hw_extension_, HW_META_argCount(__VA_ARGS__))(__VA_ARGS__)

#define _hw_extension_1($protocol) \
_hw_extension_imp($protocol, _hw_get_container_class($protocol), NSObject, NSObject)

#define _hw_extension_2($protocol, $super) \
_hw_extension_imp($protocol, _hw_get_container_class($protocol), $super, NSObject)

#define _hw_extension_3($protocol, $super, ...) \
_hw_extension_imp($protocol, _hw_get_container_class($protocol), $super, __VA_ARGS__)

#define _hw_extension_4($protocol, $super, ...) \
_hw_extension_imp($protocol, _hw_get_container_class($protocol), $super, __VA_ARGS__)

#define _hw_extension_5($protocol, $super, ...) \
_hw_extension_imp($protocol, _hw_get_container_class($protocol), $super, __VA_ARGS__)


// Implementation
#define _hw_extension_imp($protocol, $container_class, $super, ...) \
protocol $protocol; \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wprotocol\"") \
_Pragma("clang diagnostic ignored \"-Wobjc-protocol-property-synthesis\"") \
_hw_extension_imp_($protocol, $container_class, $super, __VA_ARGS__) \
_Pragma("clang diagnostic pop") \

#define _hw_extension_imp_($protocol, $container_class, $super, ...) \
@interface $container_class : $super <$protocol, __VA_ARGS__> @end \
@implementation $container_class \
+ (void)load { \
_hw_extension_load($protocol, $container_class.class, __VA_ARGS__); \
} \


#define _hw_extension_load(...)        HW_MACROCAT(_hw_extension_load_, HW_META_argCount(__VA_ARGS__))(__VA_ARGS__)

#define _hw_extension_load_3($protocol, $container_class, $targetProtocol1) \
_hw_extension_load_(@protocol($protocol), $container_class.class, @[@#$targetProtocol1])

#define _hw_extension_load_4($protocol, $container_class, $targetProtocol1, $targetProtocol2) \
_hw_extension_load_(@protocol($protocol), $container_class.class, @[@#$targetProtocol1, @#$targetProtocol2])

#define _hw_extension_load_5($protocol, $container_class, $targetProtocol1, $targetProtocol2, $targetProtocol3) \
_hw_extension_load_(@protocol($protocol), $container_class.class, @[@#$targetProtocol1, @#$targetProtocol2, @#$targetProtocol3])


// Get container class name by counter
#define _hw_get_container_class($protocol) _hw_get_container_class_imp($protocol, __COUNTER__)
#define _hw_get_container_class_imp($protocol, $counter) _hw_get_container_class_imp_concat(__HWContainer_, $protocol, $counter)
#define _hw_get_container_class_imp_concat($a, $b, $c) $a ## $b ## _ ## $c


void _hw_extension_load_(Protocol *protocol, Class containerClass, NSArray *protocolStr);


