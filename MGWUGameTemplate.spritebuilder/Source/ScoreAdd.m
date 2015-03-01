//
//  ScoreAdd.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ScoreAdd.h"

@implementation ScoreAdd {
    CCLabelTTF * _scoreNum;
}

- (void)setScore: (int)score {
    _scoreNum.string = [NSString stringWithFormat:@"%ld", (long)score];
}

@end
