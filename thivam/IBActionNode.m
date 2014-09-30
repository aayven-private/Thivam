//
//  IBActionNode.m
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "IBActionNode.h"
#import "IBConnectionDescriptor.h"

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
        self.actionSource = CGPointMake(-1, -1);
        self.isActive = YES;
        self.connectionDescriptors = [NSMutableDictionary dictionary];
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
    if (actionType) {
        IBConnectionDescriptor *desc = [_connectionDescriptors objectForKey:actionType];
        if (desc.manualCleanup) {
            if (!CGPointEqualToPoint(_actionSource, CGPointMake(-1, -1))) {
                _actionSource = CGPointMake(-1, -1);
                NSMutableArray *connectionsForType = [_connections objectForKey:actionType];
                if (connectionsForType) {
                    for (IBActionNode *connectedNode in connectionsForType) {
                        [connectedNode cleanNodeForActionType:actionType];
                    }
                }
            }
        }
    }
}

-(void)triggerConnectionsWithSource:(CGPoint)source shouldPropagate:(BOOL)shouldPropagate forActionType:(NSString *)actionType withUserInfo:(NSMutableDictionary *)userInfo withNodeReset:(BOOL)reset
{
    IBConnectionDescriptor *desc = [_connectionDescriptors objectForKey:actionType];
    if (desc.isAutoFired) {
        if (!CGPointEqualToPoint(source, _actionSource) || desc.ignoreSource) {
            _actionSource = source;
            [self fireOwnActionsForActionType:actionType witUserInfo:userInfo withNodeReset:reset];
            if (shouldPropagate) {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, desc.autoFireDelay * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    for (IBActionNode *connectedNode in [_connections objectForKey:actionType]) {
                        connectedNode.isActive = YES;
                        [connectedNode triggerConnectionsWithSource:_actionSource shouldPropagate:desc.isAutoFired forActionType:actionType withUserInfo:userInfo withNodeReset:reset];
                    }
                });
            }
        }
        if (desc.manualCleanup) {
            if (_connections.count == 0) {
                [self cleanNodeForActionType:actionType];
            }
        }
    } else {
        _actionSource = source;
        [self fireOwnActionsForActionType:actionType witUserInfo:userInfo withNodeReset:reset];
        if (shouldPropagate) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, desc.autoFireDelay * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                for (IBActionNode *connectedNode in _connections) {
                    connectedNode.isActive = YES;
                    [connectedNode triggerConnectionsWithSource:_actionSource shouldPropagate:desc.isAutoFired forActionType:actionType withUserInfo:userInfo withNodeReset:reset];
                }
            });
        }
    }
    
}

-(void)fireOwnActionsForActionType:(NSString *)actionType witUserInfo:(NSMutableDictionary *)userInfo withNodeReset:(BOOL)reset
{
    for (IBActionDescriptor *actionDescriptor in [self actionsForActionType:actionType]) {
        if (userInfo) {
            [userInfo setObject:[NSValue valueWithCGPoint:_actionSource] forKey:@"position"];
            [userInfo setObject:actionType forKey:@"actiontype"];
        } else {
            userInfo = [NSMutableDictionary dictionaryWithObjects:@[[NSValue valueWithCGPoint:_actionSource], actionType] forKeys:@[@"position", @"actiontype"]];
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

@end
