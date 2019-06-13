//
//  NSObject+Notification.m
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import "NSObject+Notification.h"
#import "NSObject+Dealloc.h"
#import <objc/runtime.h>

static const void *kJDNotificationInfosKey = &kJDNotificationInfosKey;

#pragma mark - _JDNotificationInfo

@interface __JBFNotificationInfo : NSObject

@property (nonatomic, unsafe_unretained) id sender;
@property (nonatomic, copy) NSString *notificationName;
@property (nonatomic, copy) JBFNotificationBlock block;

@end

@implementation __JBFNotificationInfo

- (NSUInteger)hash {
    NSString *target = [NSString stringWithFormat:@"%@_%@", [_sender description], _notificationName];
    return target.hash;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![self isKindOfClass:[object class]]) {
        return NO;
    }
    
    __JBFNotificationInfo *tmpInfo = (__JBFNotificationInfo *)object;
    
    NSString *myTarget = [NSString stringWithFormat:@"%@_%@", [_sender description], _notificationName];
    NSString *tmpTarget = [NSString stringWithFormat:@"%@_%@", [tmpInfo.sender description], tmpInfo.notificationName];
    
    return [myTarget isEqualToString:tmpTarget];
}

@end

@implementation NSObject (Notification)

- (void)removeNotification:(NSString *)notificationName {
    NSMutableSet *infos = [self jd_notificationInfos];
    
    __block __JBFNotificationInfo *needDeleteInfo = nil;
    [infos enumerateObjectsUsingBlock:^(__JBFNotificationInfo *info, BOOL *stop) {
        if ([info.notificationName isEqualToString:notificationName]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:info.notificationName object:nil];
            needDeleteInfo = info;
            *stop = YES;
        }
    }];
    
    if (needDeleteInfo) {
        [infos removeObject:needDeleteInfo];
    }
}

- (void)observeNotification:(NSString *)notificationName
                     sender:(id)sender
                      block:(JBFNotificationBlock)block {
    if (!notificationName || !block) {
        return;
    }
    
    __JBFNotificationInfo *info = [self jd_createNotificationInfoWithNotification:notificationName
                                                                           sender:sender
                                                                            block:block];
    NSMutableSet *infos = [self jd_notificationInfos];
    if ([infos containsObject:info]) {
        return;
    }
    
    [infos addObject:info];
    
    __unsafe_unretained id unretainedSelf = self;
    [self registerDeallocHandleWithKey:@"jd_notificationHandle" handle:^{
        [[NSNotificationCenter defaultCenter] removeObserver:unretainedSelf];
    }];
    
    if (sender != self) {
        __unsafe_unretained id unretainedSender = sender;
        [sender registerDeallocHandleWithKey:@"jd_notificationHandle" handle:^{
            [[unretainedSelf jd_notificationInfos] enumerateObjectsUsingBlock:^(__JBFNotificationInfo *info, BOOL *stop) {
                if (info.sender == unretainedSender) {
                    [[NSNotificationCenter defaultCenter] removeObserver:unretainedSelf name:nil object:unretainedSender];
                    *stop = YES;
                }
            }];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jd_handleNotification:) name:notificationName object:sender];
}

#pragma mark - Private
- (void)jd_handleNotification:(NSNotification *)notification {
    
    NSSet *infos = [self jd_notificationInfos];
    [infos enumerateObjectsUsingBlock:^(__JBFNotificationInfo *info, BOOL *stop) {
        if ([info.notificationName isEqualToString:notification.name]) {
            if (!info.sender || info.sender == notification.object) {
                info.block(notification);
                *stop = YES;
            }
        }
    }];
}

- (NSMutableSet *)jd_notificationInfos {
    NSMutableSet *infos = objc_getAssociatedObject(self, kJDNotificationInfosKey);
    if (!infos) {
        infos = [[NSMutableSet alloc] init];
        [self jd_setNotificationInfos:infos];
    }
    return infos;
}

- (void)jd_setNotificationInfos:(NSMutableSet *)infos {
    objc_setAssociatedObject(self, kJDNotificationInfosKey, infos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (__JBFNotificationInfo *)jd_createNotificationInfoWithNotification:(NSString *)notification
                                                            sender:(id)sender
                                                             block:(JBFNotificationBlock)block {
    __JBFNotificationInfo *info = [[__JBFNotificationInfo alloc] init];
    info.sender = sender;
    info.notificationName = notification;
    info.block = block;
    return info;
}

@end
