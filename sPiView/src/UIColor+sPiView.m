//
//  UIColor+sPiView.m
//  sPiView
//
//  Created by Jorrit van Asselt on 20-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "UIColor+sPiView.h"

@implementation UIColor (sPiView)
+ (UIColor *) raspberryPiGreen
{
    UIColor * color = [UIColor colorWithRed: 97.0f / 255.0f
                                      green: 180.0f / 255.0f
                                       blue: 47.0f / 255.0f
                                      alpha: 1.0f];
    return color;
}
+ (UIColor *) raspberryPiRed
{
    UIColor * color = [UIColor colorWithRed: 216.0f / 255.0f
                                      green: 65.0f / 255.0f
                                       blue: 80.0f / 255.0f
                                      alpha: 1.0f];
    return color;
}
@end
