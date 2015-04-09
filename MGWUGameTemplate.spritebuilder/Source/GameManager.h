//
//  GameManager.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameManager : NSObject {
    int gamePlayState;
}

@property (nonatomic, assign) int gamePlayState;

+ (id)getGameManager;

@end
