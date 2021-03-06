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
#import "HistoryScene.h"
#import "LevelManager.h"
#import "LevelDescriptor.h"

@interface GameViewController()

@property (nonatomic) GameScene *gameScene;
@property (nonatomic) MenuScene *menuScene;
@property (nonatomic) HistoryScene *historyScene;

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) LevelManager *levelManager;

@property (nonatomic) NSDictionary *currentLevel;
@property (nonatomic) NSDictionary *nextLevel;

@property (nonatomic) int currentLevelIndex;
@property (nonatomic) LevelDescriptor *currentLevelDescriptor;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNumber *currentLevel = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentLevelIndexKey];
    if (!currentLevel) {
        currentLevel = [NSNumber numberWithInt:1];
        [[NSUserDefaults standardUserDefaults] setObject:currentLevel forKey:kCurrentLevelIndexKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    _currentLevelIndex = currentLevel.intValue;
    
    LevelDescriptor *levelDescriptor = [[LevelDescriptor alloc] initWithLevelIndex:_currentLevelIndex];
    _currentLevelDescriptor = levelDescriptor;
    
    _levelManager = [[LevelManager alloc] init];
    
    NSDictionary *currentLevelInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentLevelInfoKey];
    
    //!!!!!!!!
    
    //_currentLevelIndex = 101;
    //currentLevelInfo = nil;
    
    //!!!!!!!!
    
    
    if (currentLevelInfo) {
        _currentLevel = currentLevelInfo;
        //_currentLevelIndex++;
        NSLog(@"%@", _currentLevel);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            LevelDescriptor *levelDescriptor = [[LevelDescriptor alloc] initWithLevelIndex:_currentLevelIndex + 1];
            //_currentLevelDescriptor = levelDescriptor;
            [_levelManager generateLevelWithGridsize:levelDescriptor.gridSize andNumberOfClicks:levelDescriptor.clickNum andNumberOfTargets:levelDescriptor.targetNum withNumberOfReferenceNodes:levelDescriptor.referenceNum succesBlock:^(NSDictionary *levelInfo) {
                _nextLevel = levelInfo;
            }];
        });
    } else {
        [_levelManager generateLevelWithGridsize:levelDescriptor.gridSize andNumberOfClicks:levelDescriptor.clickNum andNumberOfTargets:levelDescriptor.targetNum withNumberOfReferenceNodes:levelDescriptor.referenceNum succesBlock:^(NSDictionary *levelInfo) {
            _currentLevel = levelInfo;
            //_currentLevelIndex++;
            [[NSUserDefaults standardUserDefaults] setObject:_currentLevel forKey:kCurrentLevelInfoKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                LevelDescriptor *levelDescriptor = [[LevelDescriptor alloc] initWithLevelIndex:_currentLevelIndex + 1];
                //_currentLevelDescriptor = levelDescriptor;
                [_levelManager generateLevelWithGridsize:levelDescriptor.gridSize andNumberOfClicks:levelDescriptor.clickNum andNumberOfTargets:levelDescriptor.targetNum withNumberOfReferenceNodes:levelDescriptor.referenceNum succesBlock:^(NSDictionary *levelInfo) {
                    _nextLevel = levelInfo;
                }];
            });
        }];
    }
    
    _gameScene = [GameScene sceneWithSize:self.view.bounds.size];
    _gameScene.sceneDelegate = self;
    _gameScene.scaleMode = SKSceneScaleModeAspectFill;
    
    _menuScene = [MenuScene sceneWithSize:self.view.bounds.size];
    _menuScene.sceneDelegate = self;
    _menuScene.scaleMode = SKSceneScaleModeAspectFill;
    
    _historyScene = [HistoryScene sceneWithSize:self.view.bounds.size];
    _historyScene.sceneDelegate = self;
    _historyScene.scaleMode = SKSceneScaleModeAspectFill;
    
    _historyScene.currentEndIndex = _currentLevelIndex - 1;
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
    LevelDescriptor *desc = [[LevelDescriptor alloc] initWithLevelIndex:_currentLevelIndex];
    [_gameScene loadLevel:_currentLevel isCompleted:NO andGridColorScheme:desc.gridColorScheme andBgColorScheme:desc.bgColorScheme isQuest:YES];
}

-(void)randomPlayClicked
{
    SKView * skView = (SKView *)self.view;
    SKTransition *reveal = [SKTransition crossFadeWithDuration:1.3];
    reveal.pausesOutgoingScene = NO;
    reveal.pausesIncomingScene = YES;

    NSNumber *currentDifficulty = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentDifficultyKey];
    LevelDescriptor *desc = [[LevelDescriptor alloc] initWithDifficulty:currentDifficulty.intValue];
    [_levelManager generateLevelWithGridsize:desc.gridSize andNumberOfClicks:desc.clickNum andNumberOfTargets:desc.targetNum withNumberOfReferenceNodes:desc.referenceNum succesBlock:^(NSDictionary *levelInfo) {
        [skView presentScene:_gameScene transition:reveal];
        [_gameScene loadLevel:levelInfo isCompleted:NO andGridColorScheme:desc.gridColorScheme andBgColorScheme:desc.bgColorScheme isQuest:NO];
    }];
}

-(void)menuClicked
{
    SKView * skView = (SKView *)self.view;

    SKTransition *reveal = [SKTransition crossFadeWithDuration:.3];
    reveal.pausesOutgoingScene = NO;
    reveal.pausesIncomingScene = YES;
    [skView presentScene:_menuScene transition:reveal];
}

-(void)historyClicked
{
    SKView * skView = (SKView *)self.view;
    
    SKTransition *reveal = [SKTransition crossFadeWithDuration:.3];
    reveal.pausesOutgoingScene = NO;
    reveal.pausesIncomingScene = YES;
    [skView presentScene:_historyScene transition:reveal];
}

-(void)questLevelCompleted
{
    NSLog(@"%@", _nextLevel);
    LevelDescriptor *desc = [[LevelDescriptor alloc] initWithLevelIndex:_currentLevelIndex + 1];
    [_gameScene loadLevel:_nextLevel isCompleted:NO andGridColorScheme:desc.gridColorScheme andBgColorScheme:desc.bgColorScheme isQuest:YES];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        LevelManager *levelManager = [[LevelManager alloc] init];
        [levelManager saveLevel:_currentLevel forIndex:_currentLevelIndex withColorScheme:_currentLevelDescriptor.gridColorScheme];
        
        _currentLevelIndex++;
        _currentLevel = _nextLevel;
        _historyScene.currentEndIndex = _currentLevelIndex - 1;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_currentLevelIndex] forKey:kCurrentLevelIndexKey];
        [[NSUserDefaults standardUserDefaults] setObject:_currentLevel forKey:kCurrentLevelInfoKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        LevelDescriptor *levelDescriptor = [[LevelDescriptor alloc] initWithLevelIndex:_currentLevelIndex + 1];
        _currentLevelDescriptor = levelDescriptor;
        [_levelManager generateLevelWithGridsize:levelDescriptor.gridSize andNumberOfClicks:levelDescriptor.clickNum andNumberOfTargets:levelDescriptor.targetNum withNumberOfReferenceNodes:levelDescriptor.referenceNum succesBlock:^(NSDictionary *levelInfo) {
            _nextLevel = levelInfo;
        }];
    });
}

-(void)randomLevelCompleted
{
    NSNumber *currentDifficulty = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentDifficultyKey];
    LevelDescriptor *desc = [[LevelDescriptor alloc] initWithDifficulty:currentDifficulty.intValue];
    [_levelManager generateLevelWithGridsize:desc.gridSize andNumberOfClicks:desc.clickNum andNumberOfTargets:desc.targetNum withNumberOfReferenceNodes:desc.referenceNum succesBlock:^(NSDictionary *levelInfo) {
        [_gameScene loadLevel:levelInfo isCompleted:NO andGridColorScheme:desc.gridColorScheme andBgColorScheme:desc.bgColorScheme isQuest:NO];
    }];
}

-(void)historyLevelClicked:(LevelEntityHelper *)level
{
    SKView * skView = (SKView *)self.view;
    
    SKTransition *reveal = [SKTransition crossFadeWithDuration:1.3];
    reveal.pausesOutgoingScene = NO;
    reveal.pausesIncomingScene = YES;
    
    [skView presentScene:_gameScene transition:reveal];
    LevelDescriptor *desc = [[LevelDescriptor alloc] initWithLevelIndex:level.levelIndex];
    [_gameScene loadLevel:level.levelInfo isCompleted:YES andGridColorScheme:desc.gridColorScheme andBgColorScheme:desc.bgColorScheme isQuest:YES];
}

@end
