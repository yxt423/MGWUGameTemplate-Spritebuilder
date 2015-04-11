//
//  GameManager.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameManager : NSObject

@property (nonatomic, assign) int screenHeight, screenWidth;
@property (nonatomic, assign) int screenLeft, screenRight;

@property (nonatomic, assign) int gamePlayState;
@property (nonatomic, assign) bool muted;

@property (nonatomic, assign) int currentScore;
@property (nonatomic, assign) int highestScore;

@property (nonatomic, assign) int characterHighest;
@property (nonatomic, assign) CCNode *objectsGroup;

+ (id)getGameManager;

+ (NSString *)scoreWithComma: (int)s;

@end
