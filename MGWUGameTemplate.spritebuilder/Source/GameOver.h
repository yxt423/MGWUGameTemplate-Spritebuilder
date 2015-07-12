//
//  GameOver.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BasicScene.h"

@interface GameOver : BasicScene 

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int highScore;

- (void)updateEnergyLabel;

@end
