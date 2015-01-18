//
//  UITextView+amountTextView.m
//  RePay
//
//  Created by Philip Olsson on 2015-01-16.
//  Copyright (c) 2015 Philip Olsson. All rights reserved.
//

#import "amountTextField.h"



@implementation amountTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}

@end