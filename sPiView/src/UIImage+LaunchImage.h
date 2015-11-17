//
//  UIImage+LaunchImage.h
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import UIKit;

@interface UIImage (LaunchImage)

/*!
 @method + (UIImage *) launchImage
 Returns an image that is identical to the launchImage considering the current
 device and orientation.
 @return UIImage
 A UIImage that is identical to what the launchImage would be for the current
 device in the current orientation.
 */
+ (UIImage *) launchImage;
@end
