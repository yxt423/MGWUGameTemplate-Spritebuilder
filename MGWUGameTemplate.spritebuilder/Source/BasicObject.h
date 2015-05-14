//
//  BasicObject.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
@class GameManager;

@interface BasicObject : CCSprite {
    GameManager *_gameManager;
}

@property (nonatomic, retain) GameManager *_gameManager;

@end
