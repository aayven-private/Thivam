//
//  GameViewController.m
//  thivam
//
//  Created by Ivan Borsa on 22/09/14.
//  Copyright (c) 2014 ivanborsa. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "MenuScene.h"

@interface GameViewController()

@property (nonatomic) GameScene *gameScene;
@property (nonatomic) MenuScene *menuScene;
@property (nonatomic) UIImageView *imageView;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        SKView * skView = (SKView *)self.view;
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        //skView.showsPhysics = YES;
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = NO;
        
        // Create and configure the scene.
        _menuScene = [MenuScene sceneWithSize:skView.bounds.size];
        _menuScene.sceneDelegate = self;
        _menuScene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:_menuScene];
        //[_gameScene initEnvironment];
    }
}

-(void)playClicked
{
    SKView * skView = (SKView *)self.view;
    
    //if (!skView.scene) {
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    //skView.showsPhysics = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        _gameScene = [GameScene sceneWithSize:skView.bounds.size];
        _gameScene.sceneDelegate = self;
        _gameScene.scaleMode = SKSceneScaleModeAspectFill;
        
        SKTransition *reveal = [SKTransition crossFadeWithDuration:3];
        reveal.pausesOutgoingScene = NO;
        reveal.pausesIncomingScene = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [skView presentScene:_gameScene transition:reveal];
        });
    });
    // Create and configure the scene.
    
}

@end
