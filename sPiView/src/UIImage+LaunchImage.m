//
//  UIImage+LaunchImage.m
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "UIImage+LaunchImage.h"
#import "AppDelegate.h"

@implementation UIImage (LaunchImage)
+ (UIImage *) launchImage
{
    UIImage * launchImage = nil;

    UIInterfaceOrientation orientation;
    orientation = [UIApplication sharedApplication].statusBarOrientation;

    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
        {
            launchImage = [self iPadLaunchImageLandscape];
        }
        else
        {
            launchImage = [self iPhoneLaunchImageLandscape];
        }
    }
    else
    {
        if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
        {
            launchImage = [self iPadLaunchImagePortrait];
        }
        else
        {
            launchImage = [self iPhoneLaunchImagePortrait];
        }
    }

    NSAssert(nil != launchImage, @"No launchimage");

    
    return launchImage;
}

#pragma mark - iPad
+ (UIImage *) iPadLaunchImagePortrait
{
    UIImage * launchImage = [UIImage imageNamed: @"launchImage-ipad-portrait"];
    return launchImage;
}
+ (UIImage *) iPadLaunchImageLandscape
{
    UIImage * launchImage = [UIImage imageNamed: @"launchImage-ipad-landscape"];
    return launchImage;
}

#pragma mark - iPhone
+ (UIImage *) iPhoneLaunchImagePortrait
{
    UIImage * launchImage = nil;

    CGSize screensize = [UIScreen mainScreen].bounds.size;
    if (screensize.height <= (640 + 1))
    {
        // iPhone 3.5 inch (original iPhone, iPhone 4, 4S)
        launchImage = [UIImage imageNamed: @"launchImage"];
    }
    else if (screensize.height <= (568 + 1))
    {
        // iPhone 4 inch (iPhone 5, 5C, 5S)
        launchImage = [UIImage imageNamed: @"launchImage-retina4"];
        
    }
    else if (screensize.height <= (667 + 1))
    {
        // iPhone HD 4.7 (iPhone 6, 6S)
        launchImage = [UIImage imageNamed: @"launchImage-667h"];
        
    }
    else if (screensize.height <= (736 + 1))
    {
        // iPhone HD 5.5 (iPhone 6 Plus, 6S Plus)
        launchImage = [UIImage imageNamed: @"launchImage-736h"];
    }

    return launchImage;
}
+ (UIImage *) iPhoneLaunchImageLandscape
{
    UIImage * launchImage = nil;

    CGSize screensize = [UIScreen mainScreen].bounds.size;
    if (screensize.width <= (640 + 1))
    {
        // iPhone 3.5 inch (original iPhone, iPhone 4, 4S)
        launchImage = [UIImage imageNamed: @"launchImage-landscape"];
    }
    else if (screensize.width <= (568 + 1))
    {
        // iPhone 4 inch (iPhone 5, 5C, 5S)
        launchImage = [UIImage imageNamed: @"launchImage-retina4-landscape"];

    }
    else if (screensize.width <= (667 + 1))
    {
        // iPhone HD 4.7 (iPhone 6, 6S)
        launchImage = [UIImage imageNamed: @"launchImage-667h-landscape"];

    }
    else if (screensize.width <= (736 + 1))
    {
        // iPhone HD 5.5 (iPhone 6 Plus, 6S Plus)
        launchImage = [UIImage imageNamed: @"launchImage-736h-landscape"];
    }

    return launchImage;
}
@end
