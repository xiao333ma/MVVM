//
//  NSObject+Notification.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JBFNotificationBlock)(NSNotification *notification);

@interface NSObject (Notification)

/**
 *  Subject a notification for the current object
 *
 *  @param notificationName notification name
 *  @param sender           notification sender
 *  @param block            block for handle notification
 *
 *  @note Recommand to use this method to observe a notification,
 *        because when the observer or the sender is released,
 *        the notification in the center will also be removed safely.
 */
- (void)observeNotification:(NSString *)notificationName
                     sender:(id)sender
                      block:(JBFNotificationBlock)block;

/**
 *  Remove notification manually
 *
 *  @param notificationName notification name
 */
- (void)removeNotification:(NSString *)notificationName;

@end
