//
//  Shop.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Shop : CCNode {
    int bubbleToBeAdded;
    NSString * productName;
    
    CCLabelTTF *youHaveBubbleNumLabel;
}

@property (nonatomic, assign) int bubbleToBeAdded;
@property (nonatomic, retain) NSString * productName;

@property (nonatomic, retain) CCLabelTTF *youHaveBubbleNumLabel;

@end
