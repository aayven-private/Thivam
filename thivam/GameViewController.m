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
#import "LevelManager.h"

@interface GameViewController()

@property (nonatomic) GameScene *gameScene;
@property (nonatomic) MenuScene *menuScene;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) LevelManager *levelManager;

@property (nonatomic) NSDictionary *nextLevel;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _levelManager = [[LevelManager alloc] init];
    [_levelManager generateLevelWithGridsize:CGSizeMake(5, 5) andNumberOfClicks:2 andNumberOfTargets:3 withReferenceNode:YES succesBlock:^(NSDictionary *levelInfo) {
        _nextLevel = levelInfo;
    }];
    
    _gameScene = [GameScene sceneWithSize:self.view.bounds.size];
    _gameScene.sceneDelegate = self;
    _gameScene.scaleMode = SKSceneScaleModeAspectFill;
    
    _menuScene = [MenuScene sceneWithSize:self.view.bounds.size];
    _menuScene.sceneDelegate = self;
    _menuScene.scaleMode = SKSceneScaleModeAspectFill;
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
    
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    //skView.showsPhysics = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = NO;
    
    if (!skView.scene) {
        
        // Create and configure the scene.
        /*_menuScene = [MenuScene sceneWithSize:skView.bounds.size];
        _menuScene.sceneDelegate = self;
        _menuScene.scaleMode = SKSceneScaleModeAspectFill;*/
        
        // Present the scene.
        [skView presentScene:_menuScene];
        //[_gameScene initEnvironment];
    }
}

-(void)playClicked
{
    SKView * skView = (SKView *)self.view;
        
    SKTransition *reveal = [SKTransition crossFadeWithDuration:1.3];
    reveal.pausesOutgoingScene = NO;
    reveal.pausesIncomingScene = YES;
    
    [skView presentScene:_gameScene transition:reveal];
    [_gameScene loadLevel:_nextLevel];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_levelManager generateLevelWithGridsize:CGSizeMake(5, 5) andNumberOfClicks:2 andNumberOfTargets:3 withReferenceNode:YES succesBlock:^(NSDictionary *levelInfo) {
            _nextLevel = levelInfo;
        }];
    });
}

-(void)menuClicked
{
    SKView * skView = (SKView *)self.view;

    SKTransition *reveal = [SKTransition crossFadeWithDuration:.3];
    reveal.pausesOutgoingScene = NO;
    reveal.pausesIncomingScene = YES;
    [skView presentScene:_menuScene transition:reveal];

}

-(void)levelCompleted
{
    [_gameScene loadLevel:_nextLevel];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_levelManager generateLevelWithGridsize:CGSizeMake(5, 5) andNumberOfClicks:2 andNumberOfTargets:3 withReferenceNode:YES succesBlock:^(NSDictionary *levelInfo) {
            _nextLevel = levelInfo;
        }];
    });
}

@end
