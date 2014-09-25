//
//  IBActionNode.m
//  thivam
//
//  Created by Ivan Borsa on 23/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "IBActionNode.h"

@implementation IBActionNode

-(id)init
{
    if (self = [super init]) {
        self.autoFire = NO;
        self.maxRepeatNum = -1;
        self.repeatCount = 0;
        self.connections = [NSMutableArray array];
        //self.actions = [NSMutableArray array];
        self.triggerDelay = .15;
        self.actionSource = CGPointMake(-1, -1);
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

-(void)cleanNode
{
    if (!CGPointEqualToPoint(_actionSource, CGPointMake(-1, -1))) {
        _actionSource = CGPointMake(-1, -1);
        for (IBActionNode *connectedNode in _connections) {
            [connectedNode cleanNode];
        }
    }
}

-(void)triggerConnectionsWithSource:(CGPoint)source shouldPropagate:(BOOL)shouldPropagate
{
    if (_autoFire) {
        if (!CGPointEqualToPoint(source, _actionSource)) {
            _actionSource = source;
            [self fireOwnActions];
            if (shouldPropagate) {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _triggerDelay * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    for (IBActionNode *connectedNode in _connections) {
                        [connectedNode triggerConnectionsWithSource:_actionSource shouldPropagate:_autoFire];
                    }
                });
            }
        }
        if (_cleanupOnManualTrigger) {
            if (_connections.count == 0) {
                [self cleanNode];
            }
        }
    } else {
        _actionSource = source;
        [self fireOwnActions];
        if (shouldPropagate) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _triggerDelay * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                for (IBActionNode *connectedNode in _connections) {
                    [connectedNode triggerConnectionsWithSource:_actionSource shouldPropagate:_autoFire];
                }
            });
            /*for (IBActionNode *connectedNode in _connections) {
                [connectedNode triggerConnectionsWithSource:_actionSource shouldPropagate:NO];
            }*/
        }
    }
    
}

-(void)fireOwnActions
{
    for (IBActionDescriptor *actionDescriptor in [self actions]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSValue valueWithCGPoint:_actionSource] forKey:@"position"];
        [_nodeObject fireAction:actionDescriptor userInfo:userInfo];
    }
}

-(NSArray *)actions
{
    if (!_actions) {
        return [_delegate getUnifiedActionDescriptors];
    }
    return _actions;
}

@end
