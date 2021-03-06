//
//  IBActionNode.m
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "IBActionNode.h"
#import "IBConnectionDescriptor.h"
#import "WeakReference.h"

@implementation IBActionNode

-(id)init
{
    if (self = [super init]) {
        //self.autoFire = NO;
        //self.maxRepeatNum = -1;
        //self.repeatCount = 0;
        self.connections = [NSMutableDictionary dictionary];
        self.actions = [NSMutableDictionary dictionary];
        //self.triggerDelay = .15;
        //self.actionSource = CGPointMake(-1, -1);
        self.isActive = YES;
        self.connectionDescriptors = [NSMutableDictionary dictionary];
        self.actionSources = [NSMutableDictionary dictionary];
        self.tokens = [NSMutableArray array];
        self.actionIds = [NSMutableArray array];
    }
    return self;
}

/*-(void)fireActions
{
    if (_repeatCount < _maxRepeatNum || _maxRepeatNum < 0) {
        _repeatCount++;
        for (IBActionDescriptor *actionDescriptor in _actions) {
            [_nodeObject fireAction:actionDescriptor userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithCGPoint:_actionSource] forKey:@"position"]];
        }
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _autoFireDelay * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (_autoFire) {
                [self triggerConnections];
            }
        });
    }
}

-(void)triggerConnections
{
    
}*/

-(void)cleanNodeForActionType:(NSString *)actionType
{
    /*if (actionType) {
        IBConnectionDescriptor *desc = [_connectionDescriptors objectForKey:actionType];
        if (desc.manualCleanup) {
            NSValue *actionSource_val = [_actionSources objectForKey:actionType];
            if (actionSource_val) {
                [_actionSources removeObjectForKey:actionType];
                NSMutableArray *connectionsForType = [_connections objectForKey:actionType];
                if (connectionsForType) {
                    for (IBActionNode *connectedNode in connectionsForType) {
                        [connectedNode cleanNodeForActionType:actionType];
                    }
                }
            }
        }
    }*/
}

-(void)triggerConnectionsWithSource:(CGPoint)source shouldPropagate:(BOOL)shouldPropagate forActionType:(NSString *)actionType withUserInfo:(NSMutableDictionary *)userInfo withNodeReset:(BOOL)reset withActionId:(NSString *)actionId
{
    IBConnectionDescriptor *desc = [_connectionDescriptors objectForKey:actionType];
    
    if (desc.isAutoFired) {
        CGPoint actionSource;
        NSValue *actionSource_val = [_actionSources objectForKey:actionType];
        if (actionSource_val) {
            actionSource = actionSource_val.CGPointValue;
        } else {
            actionSource = CGPointMake(-1, -1);
        }
        if (![_actionIds containsObject:actionId]) {
            
            if (_actionIds.count > _actionHeapSize) {
                [_actionIds removeObjectAtIndex:0];
            }
            
            [_actionIds addObject:actionId];
            
            [_actionSources setObject:[NSValue valueWithCGPoint:source] forKey:actionType];;
            [self fireOwnActionsForActionType:actionType witUserInfo:userInfo withNodeReset:reset];
            if (shouldPropagate) {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, desc.autoFireDelay * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    for (WeakReference *connectedNode in [_connections objectForKey:actionType]) {
                        ((IBActionNode *)connectedNode.nonretainedObjectValue).isActive = YES;
                        [((IBActionNode *)connectedNode.nonretainedObjectValue) triggerConnectionsWithSource:source shouldPropagate:desc.isAutoFired forActionType:actionType withUserInfo:userInfo withNodeReset:reset withActionId:actionId];
                    }
                });
            }
        }
    } else {
        [_actionSources setObject:[NSValue valueWithCGPoint:source] forKey:actionType];
        [self fireOwnActionsForActionType:actionType witUserInfo:userInfo withNodeReset:reset];
        if (shouldPropagate) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, desc.autoFireDelay * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                for (WeakReference *connectedNode in [_connections objectForKey:actionType]) {
                    ((IBActionNode *)connectedNode.nonretainedObjectValue).isActive = YES;
                    [((IBActionNode *)connectedNode.nonretainedObjectValue) triggerConnectionsWithSource:source shouldPropagate:desc.isAutoFired forActionType:actionType withUserInfo:userInfo withNodeReset:reset withActionId:actionId];
                }
            });
        }
    }
}

-(void)fireOwnActionsForActionType:(NSString *)actionType witUserInfo:(NSMutableDictionary *)userInfo withNodeReset:(BOOL)reset
{
    CGPoint actionSource;
    NSValue *actionSource_val = [_actionSources objectForKey:actionType];
    if (actionSource_val) {
        actionSource = actionSource_val.CGPointValue;
    } else {
        actionSource = CGPointMake(-1, -1);
    }
    NSArray *actionsForType = [self actionsForActionType:actionType];
    for (IBActionDescriptor *actionDescriptor in actionsForType) {
        if (userInfo) {
            [userInfo setObject:[NSValue valueWithCGPoint:actionSource] forKey:@"position"];
            [userInfo setObject:actionType forKey:@"actiontype"];
        } else {
            userInfo = [NSMutableDictionary dictionaryWithObjects:@[[NSValue valueWithCGPoint:actionSource], actionType] forKeys:@[@"position", @"actiontype"]];
        }

        if (reset) {
            [_nodeObject resetNode];
        }
        
        [_nodeObject fireAction:actionDescriptor userInfo:userInfo forActionType:actionType];
    }
}

-(NSArray *)actionsForActionType:(NSString *)actionType
{
    NSArray *actionsForType = [_actions objectForKey:actionType];
    if (!actionsForType) {
        return [_delegate getUnifiedActionDescriptorsForActionType:actionType];
    }
    return actionsForType;
}

-(BOOL)hasToken
{
    return (_tokens && _tokens.count > 0);
}

-(void)getToken:(IBToken *)token
{
    if (token.isAlive) {
        [_tokens addObject:token];
        token.currentPosition = _position;
        [_nodeObject fireTokenAction_enterForToken:token];
    }
}

-(void)passToken:(IBToken *)token forActionType:(NSString *)actionType
{
    NSArray *connectedNodes = [_connections objectForKey:actionType];
    if (connectedNodes && connectedNodes.count > 0) {
        [_tokens removeObject:token];
        [_nodeObject fireTokenAction_exitForToken:token];
        for (int i=0; i<connectedNodes.count; i++) {
            WeakReference *connectedNode = [connectedNodes objectAtIndex:i];
            if (i==0) {
                [((IBActionNode *)connectedNode.nonretainedObjectValue) getToken:token];
            } else if (token.shouldCopyToken) {
                [((IBActionNode *)connectedNode.nonretainedObjectValue) getToken:[token mutableCopy]];
            }
        }
    }
}

@end
