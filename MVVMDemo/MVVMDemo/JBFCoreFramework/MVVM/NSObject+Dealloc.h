//
//  NSObject+Dealloc.h
//  JBFMobile
//
//  Created by JD Financial on 16/9/2.
//  Copyright © 2016年 JD Financial Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JBFDeallocBlock)(void);       //!< new dealloc block

/**
 *  Dealloc Category for NSObject
 *
 *  This category provides method for instance of NSObject to swizzle dealloc method.
 *  If you want to define your own dealloc method for a specified class, you could use
 *  the swizzleDeallocWithBlock: method and provide a block which implements the new 
 *  dealloc operation.
 */
@interface NSObject (Dealloc)

/**
 swizzle dealloc method

 @param handleKey handleKey description
 @param willDeallocHandle willDeallocHandle description
 */
- (void)registerDeallocHandleWithKey:(NSString *)handleKey handle:(JBFDeallocBlock)willDeallocHandle;

@end
