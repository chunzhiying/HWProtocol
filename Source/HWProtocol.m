//
//  HWProtocol.m
//  HWProtocolDemo
//
//  Created by 陈智颖 on 2017/4/10.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWProtocol.h"
#import <pthread.h>

#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif

typedef struct {
    Protocol *__unsafe_unretained protocol;
    Class __unsafe_unretained targetClass;
    Protocol *__unsafe_unretained targetProtocols[3];
    Method *instanceMethods;
    unsigned instanceMethodCount;
    Method *classMethods;
    unsigned classMethodCount;
} PKExtendedProtocol;

static PKExtendedProtocol *allExtendedProtocols = NULL;
static pthread_mutex_t protocolsLoadingLock = PTHREAD_MUTEX_INITIALIZER;
static size_t extendedProtcolCount = 0, extendedProtcolCapacity = 0;

Method *_hw_extension_create_merged(Method *existMethods, unsigned existMethodCount, Method *appendingMethods, unsigned appendingMethodCount) {
    
    if (existMethodCount == 0) {
        return appendingMethods;
    }
    unsigned mergedMethodCount = existMethodCount + appendingMethodCount;
    Method *mergedMethods = malloc(mergedMethodCount * sizeof(Method));
    memcpy(mergedMethods, existMethods, existMethodCount * sizeof(Method));
    memcpy(mergedMethods + existMethodCount, appendingMethods, appendingMethodCount * sizeof(Method));
    return mergedMethods;
}

void _hw_extension_merge(PKExtendedProtocol *extendedProtocol, Class containerClass) {
    
    // Instance methods
    unsigned appendingInstanceMethodCount = 0;
    Method *appendingInstanceMethods = class_copyMethodList(containerClass, &appendingInstanceMethodCount);
    Method *mergedInstanceMethods = _hw_extension_create_merged(extendedProtocol->instanceMethods,
                                                                extendedProtocol->instanceMethodCount,
                                                                appendingInstanceMethods,
                                                                appendingInstanceMethodCount);
    free(extendedProtocol->instanceMethods);
    extendedProtocol->instanceMethods = mergedInstanceMethods;
    extendedProtocol->instanceMethodCount += appendingInstanceMethodCount;
    
    // Class methods
    unsigned appendingClassMethodCount = 0;
    Method *appendingClassMethods = class_copyMethodList(object_getClass(containerClass), &appendingClassMethodCount);
    Method *mergedClassMethods = _hw_extension_create_merged(extendedProtocol->classMethods,
                                                             extendedProtocol->classMethodCount,
                                                             appendingClassMethods,
                                                             appendingClassMethodCount);
    free(extendedProtocol->classMethods);
    extendedProtocol->classMethods = mergedClassMethods;
    extendedProtocol->classMethodCount += appendingClassMethodCount;
}

void _hw_extension_load_(Protocol *protocol, Class containerClass, NSArray *protocolStr) {
    
    pthread_mutex_lock(&protocolsLoadingLock);
    
    if (extendedProtcolCount >= extendedProtcolCapacity) {
        size_t newCapacity = 0;
        if (extendedProtcolCapacity == 0) {
            newCapacity = 1;
        } else {
            newCapacity = extendedProtcolCapacity << 1;
        }
        allExtendedProtocols = realloc(allExtendedProtocols, sizeof(*allExtendedProtocols) * newCapacity);
        extendedProtcolCapacity = newCapacity;
    }
    
    Protocol *__unsafe_unretained targetProtocols[3];
    targetProtocols[0] = @protocol(NSObject);
    targetProtocols[1] = @protocol(NSObject);
    targetProtocols[2] = @protocol(NSObject);
    
    for (NSInteger i = 0; i < protocolStr.count; i++) {
        targetProtocols[i] = NSProtocolFromString([protocolStr objectAtIndex:i]);
    }
    
    size_t resultIndex = SIZE_T_MAX;
    for (size_t index = 0; index < extendedProtcolCount; ++index) {
        if (allExtendedProtocols[index].protocol == protocol
            && allExtendedProtocols[index].targetClass == class_getSuperclass(containerClass)
            && allExtendedProtocols[index].targetProtocols[0] == targetProtocols[0]
            && allExtendedProtocols[index].targetProtocols[1] == targetProtocols[1]
            && allExtendedProtocols[index].targetProtocols[2] == targetProtocols[2]) {
            resultIndex = index;
            break;
        }
    }
    
    if (resultIndex == SIZE_T_MAX) {
        allExtendedProtocols[extendedProtcolCount] = (PKExtendedProtocol){
            .protocol = protocol,
            .targetClass = class_getSuperclass(containerClass),
            .instanceMethods = NULL,
            .instanceMethodCount = 0,
            .classMethods = NULL,
            .classMethodCount = 0,
        };
        allExtendedProtocols[extendedProtcolCount].targetProtocols[0] = targetProtocols[0];
        allExtendedProtocols[extendedProtcolCount].targetProtocols[1] = targetProtocols[1];
        allExtendedProtocols[extendedProtcolCount].targetProtocols[2] = targetProtocols[2];
        resultIndex = extendedProtcolCount;
        extendedProtcolCount++;
    }
    
    _hw_extension_merge(&(allExtendedProtocols[resultIndex]), containerClass);
    
    pthread_mutex_unlock(&protocolsLoadingLock);
}

static void _hw_extension_inject_class(Class targetClass, PKExtendedProtocol extendedProtocol) {
    
    for (unsigned methodIndex = 0; methodIndex < extendedProtocol.instanceMethodCount; ++methodIndex) {
        Method method = extendedProtocol.instanceMethods[methodIndex];
        SEL selector = method_getName(method);
        
        Method hadAddMethod = class_getInstanceMethod(targetClass, selector);
        if (hadAddMethod) {
            continue;
        }
        
        IMP imp = method_getImplementation(method);
        const char *types = method_getTypeEncoding(method);
        class_addMethod(targetClass, selector, imp, types);
    }
    
    Class targetMetaClass = object_getClass(targetClass);
    for (unsigned methodIndex = 0; methodIndex < extendedProtocol.classMethodCount; ++methodIndex) {
        Method method = extendedProtocol.classMethods[methodIndex];
        SEL selector = method_getName(method);
        
        if (selector == @selector(load) || selector == @selector(initialize)) {
            continue;
        }
        
        Method hadAddMethod = class_getInstanceMethod(targetMetaClass, selector);
        if (hadAddMethod) {
            continue;
        }
        
        IMP imp = method_getImplementation(method);
        const char *types = method_getTypeEncoding(method);
        class_addMethod(targetMetaClass, selector, imp, types);
    }
}

__attribute__((constructor)) static void _hw_extension_inject_entry(void) {
    
    pthread_mutex_lock(&protocolsLoadingLock);
    
    unsigned classCount = 0;
    Class *allClasses = objc_copyClassList(&classCount);
    
    NSLog(@"HWProtocol begin");
    @autoreleasepool {
        for (unsigned protocolIndex = 0; protocolIndex < extendedProtcolCount; ++protocolIndex) {
            PKExtendedProtocol extendedProtcol = allExtendedProtocols[protocolIndex];
            for (unsigned classIndex = 0; classIndex < classCount; ++classIndex) {
                Class class = allClasses[classIndex];
                if ([NSStringFromClass(class) hasPrefix:@"__HWContainer_"]
                    || !class_conformsToProtocol(class, extendedProtcol.protocol)) {
                    continue;
                }
                
                if (!class_conformsToProtocol(class, extendedProtcol.targetProtocols[0])
                    || !class_conformsToProtocol(class, extendedProtcol.targetProtocols[1])
                    || !class_conformsToProtocol(class, extendedProtcol.targetProtocols[2])) {
                    
                    continue;
                }
                
                if (extendedProtcol.targetClass == [NSObject class]) {
                    _hw_extension_inject_class(class, extendedProtcol);
                    continue;
                }
                if (extendedProtcol.targetClass != [NSObject class]
                    && [[class new] isKindOfClass:extendedProtcol.targetClass]) {
                    _hw_extension_inject_class(class, extendedProtcol);
                    continue;
                }
            }
        }
    }
    NSLog(@"HWProtocol end");
    
    pthread_mutex_unlock(&protocolsLoadingLock);
    
    free(allClasses);
    free(allExtendedProtocols);
    extendedProtcolCount = 0, extendedProtcolCapacity = 0;
}

