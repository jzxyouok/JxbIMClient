//
//  JxbIMImageMessage.h
//  JxbQmttKit
//
//  Created by Peter on 16/6/27.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import "JxbIMBaseMessage.h"

@interface JxbIMImageMessage : JxbIMBaseMessage

/**
 *  图片Data
 */
@property (nonatomic, strong) NSData    *imageData;
@end
