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
    bool muted;
}

@property (nonatomic, assign) int gamePlayState;
@property (nonatomic, assign) bool muted;

+ (id)getGameManager;

@end
