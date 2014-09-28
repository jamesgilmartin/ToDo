//
//  UIImageView+PercentageIndicator.h
//  ListTest
//
//  Created by James Gilmartin on 28/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (PercentageIndicator)

- (UIImageView *)drawCircleWithPercentage:(int)percent andTintColour:(UIColor *)colour;

@end

static inline double radians (double degrees) { return degrees * M_PI / 180; }