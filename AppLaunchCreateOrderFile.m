
//
//  AppLaunchCreateOrderFile.m
//  TestApp
//
//  Created by 泽泽 on 2020/11/23.
//  Copyright © 2020 泽泽. All rights reserved.
//

#import "AppLaunchCreateOrderFile.h"

#include <stdint.h>
#include <stdio.h>
#include <sanitizer/coverage_interface.h>
#include <dlfcn.h>
#include <libkern/OSAtomic.h>

@implementation AppLaunchCreateOrderFile

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,uint32_t *stop){
    // Counter for the guards.
    static uint64_t N;
    // Initialize only once.
    if (start == stop || *start) return;
    printf("INIT: %p %p\n", start, stop);
    for (uint32_t *x = start; x < stop; x++)
    // Guards should start from 1.
    *x = ++N;
}

//符号结构体
typedef struct{
    void *pc;
    void *next;
}SymbolNode;
//原子队列
static OSQueueHead symbolList = OS_ATOMIC_QUEUE_INIT;

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
//    if (!*guard) return; //该判断会屏蔽掉load方法
    void *PC = __builtin_return_address(0);
    //创建结构体
    SymbolNode *node = malloc(sizeof(SymbolNode));
    *node = (SymbolNode){PC,NULL};
    //加入AtomicQueue
    OSAtomicEnqueue(&symbolList, node, offsetof(SymbolNode, next));
}
//-fsanitize-coverage=trace-pc-guard
//-fsanitize-coverage=func,trace-pc-guard
+ (void)toCreateOrderFile
{
    NSMutableArray *nodes = [NSMutableArray array];
    while (YES) {
        SymbolNode *node = OSAtomicDequeue(&symbolList, offsetof(SymbolNode, next));
        if(node == NULL) break;
        Dl_info info = {0};
        dladdr(node->pc, &info);
        NSString *sName = @(info.dli_sname);
        BOOL isOC = ([sName hasPrefix:@"+["] || [sName hasPrefix:@"-["]) ? YES : NO;
        if(isOC){
            if(![nodes containsObject:sName]){
                [nodes addObject:sName];
            }
            continue;
        }
        sName = [@"_" stringByAppendingString:sName];
        if(![nodes containsObject:sName]){
            [nodes addObject:sName];
        }
    }
    NSMutableArray *newNodes = (NSMutableArray *)[[nodes reverseObjectEnumerator]allObjects];
    if([newNodes containsObject:@"+[AppLaunchCreateOrderFile toCreateOrderFile]"]){
        [newNodes removeObject:@"+[AppLaunchCreateOrderFile toCreateOrderFile]"];
    }
    NSString *nodesStr =  [newNodes componentsJoinedByString:@"\n"];
    NSLog(@"nodesStr == \n%@",nodesStr);
    NSData *strData = [nodesStr dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager]createFileAtPath:[NSString stringWithFormat:@"%@app.order",NSTemporaryDirectory()] contents:strData attributes:nil];
}

@end
