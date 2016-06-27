//
//  JxbIMBaseMessage.h
//  JxbQmttKit
//
//  Created by Peter on 16/6/27.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JxbIMParser.h"

@class JxbIMUser;

/**
 *  消息类型
 */
typedef NS_ENUM(NSInteger,JxbIMMsgType) {
    /**
     *  未知
     */
    JxbIM_Unknown = -1,
    /**
     *  文本信息
     */
    JxbIM_Text = 1,
    /**
     *  图片信息
     */
    JxbIM_Image = 2,
    /**
     *  位置消息
     */
    JxbIM_Location = 3,
    /**
     *  语音
     */
    JxbIM_Voice = 4,
    /**
     *  视频
     */
    JxbIM_Video = 5,
    /**
     *  震屏
     */
    JxbIM_Shake = 11,
    /**
     *  正在输入
     */
    JxbIM_Inputing = 21,
    /**
     *  红包
     */
    JxbIM_Money = 91
};

@interface JxbIMBaseMessage : JxbIMParser

//聊天唯一标识
@property (nonatomic, strong) NSString  *topicId;

//目标用户
@property (nonatomic, strong) JxbIMUser *toUser;

//发送用户
@property (nonatomic, strong) JxbIMUser *fromUser;

//消息类型
@property (nonatomic, assign, readonly) JxbIMMsgType    msgType;

//扩展字段
@property (nonatomic, copy  ) NSString  *extra;

//发送时间
@property (nonatomic, copy  ) NSNumber  *sentTime;

@end
