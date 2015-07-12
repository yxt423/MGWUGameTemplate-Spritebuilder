//
//  EnergyUsedUpPopUp.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 7/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "EnergyUsedUpPopUp.h"
#import "GameManager.h"

@implementation EnergyUsedUpPopUp

- (void)ok {
    [GameManager playThenCleanUpAnimationOf:self Named:@"Disappear"];
}


- (void)shop {
    [GameManager replaceSceneWithFadeTransition:@"ShopScene"];
}

@end
