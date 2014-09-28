//
//  UIImageView+PercentageIndicator.m
//  ListTest
//
//  Created by James Gilmartin on 28/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import "UIImageView+PercentageIndicator.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@implementation UIImageView (PercentageIndicator)

- (UIImageView *)drawCircleWithPercentage:(int)percent andTintColour:(UIColor *)colour
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat arcPadding = 4;
    CGFloat arcRadius = (self.frame.size.width / 2) - arcPadding;
    CGPoint arcCenter = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    CGFloat startAngle = radians(0);
    CGFloat endAngle = radians(360);
    CGContextAddArc(context, arcCenter.x, arcCenter.y, arcRadius, startAngle, endAngle, 1);
    CGContextSetLineWidth(context, 6.0f);
    CGFloat red, green, blue, alpha;
    [colour getRed:&red green:&green blue:&blue alpha:&alpha];
    [[UIColor whiteColor] setStroke];
    CGContextStrokePath(context);
    
    startAngle = radians(270);
    endAngle = radians(270 + (360 * percent) / 100);
    CGContextAddArc(context, arcCenter.x, arcCenter.y, arcRadius, startAngle, endAngle, 0);
    CGContextSetLineWidth(context, 4.5f);
    CGContextSetLineCap(context, kCGLineCapRound);
    [colour setStroke];
    CGContextStrokePath(context);
    
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setImage:retImage];
    return self;
}

@end
