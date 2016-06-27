//
//  JxbQmttClient.m
//  JxbQmttKit
//
//  Created by Peter on 16/6/25.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import "JxbQmttClient.h"
#import "JxbQmttCode.h"
#import "MQTTKit.h"
#import "JxbIMParser.h"
#import "JxbIMBaseMessage.h"
#import "JxbIMTextMessage.h"
#import "JxbIMImageMessage.h"
#import "JxbIMLocationMessage.h"
#import "JxbIMInputingMessage.h"
#import "JxbIMNotifyMessage.h"
#import "JxbIMSystemMessage.h"
#import "JxbIMCustomMessage.h"
#import "NSDictionary+Json.h"

@interface JxbQmttClient()
/**
 *  MQTT
 */
@property (nonatomic, strong) MQTTClient    *client;
/**
 *  客户端唯一标识
 */
@property (nonatomic, strong) NSString      *clientId;

@end

@implementation JxbQmttClient

#pragma mark - 初始化
+ (instancetype)sharedInstance {
    static dispatch_once_t  once;
    static JxbQmttClient    *client;
    dispatch_once(&once, ^{
        client = [[JxbQmttClient alloc] init];
    });
    return client;
}

- (instancetype)init {
    self = [super init];
    if (self) {
 
    }
    return self;
}

- (MQTTClient*)client {
    if (!_client) {
        _client = [[MQTTClient alloc] initWithClientId:self.clientId];
    }
    return _client;
}

#pragma mark - 连接
- (void)connect:(NSString *)host clentId:(NSString*)clentId successBlock:(void(^)(void))successBlock failureBlock:(void(^)(JxbConnectionCode statusCode))failureBlock {
    __weak typeof (self) wSelf = self;
    self.clientId = clentId;
    [self.client connectToHost:host completionHandler:^(NSUInteger code) {
        if (code == ConnectionAccepted) {
            NSLog(@"JxbQmtt login success[%@]",wSelf.clientId);
            if (successBlock != NULL) {
                successBlock();
            }
        }
        else {
            NSLog(@"JxbQmtt login failed[%@](%ld)",wSelf.clientId,(unsigned long)code);
            if (failureBlock != NULL) {
                failureBlock((JxbConnectionCode)code);
            }
        }
    }];
    
    [self.client setMessageHandler:^(MQTTMessage* message) {
        [wSelf receiveMessage:message];
    }];
}

#pragma mark - 断开
- (void)disconnect {
    __weak typeof (self) wSelf = self;
    [self.client disconnectWithCompletionHandler:^(NSUInteger code) {
        // The client is disconnected when this completion handler is called
        NSLog(@"MQTT client is disconnected[%@]",wSelf.clientId);
    }];
}

#pragma mark - 订阅
- (void)subscribe:(NSArray *)topics {
    for (NSString* topic in topics) {
        [self.client subscribe:topic withQos:ExactlyOnce completionHandler:nil];
    }
}

#pragma mark - 发送消息
- (void)sendMessage:(NSString*)topic conetnt:(NSString*)content {
    __weak typeof (self) wSelf = self;
    [self.client publishString:content toTopic:topic withQos:ExactlyOnce retain:NO completionHandler:^(int mid) {
        NSLog(@"message has been delivered[%@]",wSelf.clientId);
    }];
}

- (void)sendTextMessage:(JxbIMTextMessage*)message {
    NSString* conetnt = [[message toDictionary] toString];
    [self sendMessage:message.topicId conetnt:conetnt];
}

- (void)sendImageMessage:(JxbIMImageMessage*)message {
    NSString* conetnt = [[message toDictionary] toString];
    [self sendMessage:message.topicId conetnt:conetnt];
}

- (void)sendLocationMessage:(JxbIMLocationMessage*)message {
    NSString* conetnt = [[message toDictionary] toString];
    [self sendMessage:message.topicId conetnt:conetnt];
}

- (void)sendInputingMessage:(JxbIMInputingMessage *)message {
    NSString* conetnt = [[message toDictionary] toString];
    [self sendMessage:message.topicId conetnt:conetnt];
}

- (void)sendNotifyMessage:(JxbIMNotifyMessage*)message {
    NSString* conetnt = [[message toDictionary] toString];
    [self sendMessage:message.topicId conetnt:conetnt];
}

- (void)sendSystemMessage:(JxbIMSystemMessage*)message {
    NSString* conetnt = [[message toDictionary] toString];
    [self sendMessage:message.topicId conetnt:conetnt];
}

- (void)sendCustomMessage:(JxbIMCustomMessage*)message {
    NSString* conetnt = [[message toDictionary] toString];
    [self sendMessage:message.topicId conetnt:conetnt];
}

#pragma mark - 接收消息
- (void)receiveMessage:(MQTTMessage*)message {
    NSString* msg = [[NSString alloc] initWithData:message.payload encoding:NSUTF8StringEncoding];
    if (msg && msg.length > 0) {
        NSError *error = nil;
        NSDictionary* dicMessage = [NSDictionary dictionaryWithJSONString:msg error:&error];
        if (error) {
            NSLog(@"receiveMessage error:%@",error);
            return;
        }
        JxbIMBaseMessage* baseMessage = [[JxbIMBaseMessage alloc] initWithDictionary:dicMessage];
        switch (baseMessage.msgType) {
            case JxbIM_Unknown: {
                break;
            }
            case JxbIM_Text: {
                baseMessage = [[JxbIMTextMessage alloc] initWithDictionary:dicMessage];
                break;
            }
            case JxbIM_Image: {
                baseMessage = [[JxbIMImageMessage alloc] initWithDictionary:dicMessage];
                break;
            }
            case JxbIM_Location: {
                baseMessage = [[JxbIMLocationMessage alloc] initWithDictionary:dicMessage];
                break;
            }
            case JxbIM_Voice: {
                break;
            }
            case JxbIM_Video: {
                break;
            }
            case JxbIM_Shake: {
                break;
            }
            case JxbIM_Inputing: {
                baseMessage = [[JxbIMInputingMessage alloc] initWithDictionary:dicMessage];
                break;
            }
            case JxbIM_Money: {
                break;
            }
            default: {
                break;
            }
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(receiveMessage:)]) {
            [self.delegate receiveMessage:baseMessage];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JxbIMNewMessageNotification object:baseMessage];
    }

}
@end
