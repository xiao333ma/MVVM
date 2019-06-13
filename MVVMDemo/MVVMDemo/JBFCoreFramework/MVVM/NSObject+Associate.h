//
//  NSObject+Associate.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Associate)

- (void)jbf_setAssociateObject:(id)object forKey:(NSString *)key;
- (id)jbf_associateObjectForKey:(NSString *)key;

@end
