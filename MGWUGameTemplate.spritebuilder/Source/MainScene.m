//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "GamePlay.h"
#import "GameManager.h"
#import "InfoScene.h"
#import "Mixpanel.h"
#import "Bubble.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation MainScene {
    CCButton *_buttonSetting;
    CCButton *_buttonFB;
    GameManager *_gameManager;
    Mixpanel *_mixpanel;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    _mixpanel = [Mixpanel sharedInstance];
}

- (void)onEnter {
    [super onEnter];
    // init devide parameters.
    [_gameManager initDeviceParam:self];
    
    // get 10 bubbles everyday.
    NSDate *newTime = [NSDate date];
    NSDate *oldTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastGiftTime"];
    CCLOG(@"newTime %@", newTime);
    CCLOG(@"oldTime %@", oldTime);
    
    if (oldTime) {
        if ([[oldTime dateByAddingTimeInterval:60*60*24*1] compare: newTime] == NSOrderedAscending) {
            CCLOG(@"new 10 bubbles!");
            CCNode *_newBubblePopUp = [CCBReader load:@"PopUp/NewBubblePopUp"];
            _newBubblePopUp.position = ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight / 2);
            [self addChild:_newBubblePopUp];
            [_gameManager addBubble:10];
            [[NSUserDefaults standardUserDefaults] setObject:newTime forKey:@"lastGiftTime"];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:newTime forKey:@"lastGiftTime"];
    }
}

- (void)play {
    [GameManager replaceSceneWithFadeTransition:@"GamePlay"];
}

- (void)setting {
    CCLOG(@"Main - setting");
    CCNode *_popUp = [CCBReader load:@"PopUp/SettingPopUp"];
    _popUp.position = _buttonSetting.position;
    _popUp.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomRight);

    [self addChild:_popUp];
}

- (void)facebook {
    // TODO: change the sharing content!!!!
    // Bug: game freeze after FB finish !!!
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];
    [FBSDKShareDialog showFromViewController:[CCDirector sharedDirector]
                                  withContent:content
                                     delegate:nil];
    
    //    FBSDKLikeControl *button = [[FBSDKLikeControl alloc] init];
    //    button.objectID = @"https://www.facebook.com/FacebookDevelopers";
    //    button.center = ccp(160, 240);
    //    [[CCDirector sharedDirector].view addSubview:button];
    
    
    // facebook lonin works.
    //    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    //    loginButton.center = ccp(160, 240);
    //    [[CCDirector sharedDirector].view addSubview:loginButton];
    
    // facebook sharing works.
    //    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    //    content.contentURL = [NSURL URLWithString:@"https://developers.facebook.com"];
    //
    //    FBSDKShareButton *button = [[FBSDKShareButton alloc] init];
    //    button.shareContent = content;
    //    button.center = ccp(160, 240);
    //    [[CCDirector sharedDirector].view addSubview:button];
    
    //    FBSDKLikeControl *button = [[FBSDKLikeControl alloc] init];
    //    button.objectID = @"https://www.facebook.com/FacebookDevelopers";
    //    button.center = ccp(160, 240);
    //    [[CCDirector sharedDirector].view addSubview:button];
}

- (void)buttonAddBubble {
    CCLOG(@".....just add more bubbles.");
    [_gameManager addBubble:5];
}

- (void)resetHighestScore {
    CCLOG(@".....just reset highest score.");
//    [_gameManager setHighestScore:0];
    _gameManager.highestScore = 0;
    _gameManager.bubbleNum = 0;
}

@end
