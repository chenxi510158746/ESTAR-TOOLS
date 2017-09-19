//
//  SCLAlertViewResponder.m
//  SCLAlertView
//
//  Created by Diogo Autilio on 9/26/14.
//  Copyright (c) 2014-2016 AnyKey Entertainment. All rights reserved.
//

#import "SCLAlertViewResponder.h"

@interface SCLAlertViewResponder ()

@property SCLAlertView *alertview;

@end

@implementation SCLAlertViewResponder

// Initialisation and Title/Subtitle/Close functions
- (instancetype)init:(SCLAlertView *)alertview
{
    self.alertview = alertview;
    return self;
}

- (void)setTitletitle:(NSString *)title
{
    self.alertview.labelTitle.text = title;
}

- (void)setSubTitle:(NSString *)subTitle
{
    self.alertview.viewText.text = subTitle;
}

- (void)close
{
    [self.alertview hideView];
}

@end
