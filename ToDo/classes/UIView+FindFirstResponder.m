//
//  UIView+FindFirstResponder.m
//  ToDo
//
//  Created by James Gilmartin on 28/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import "UIView+FindFirstResponder.h"

@implementation UIView (FindFirstResponder)

- (id)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        if ([subView isFirstResponder]) {
            return subView;
        }
    }
    return nil;
}

@end
