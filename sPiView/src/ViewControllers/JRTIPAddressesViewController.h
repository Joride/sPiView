//
//  JRTIPAddressesViewController.h
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import UIKit;
@class JRTIPAddressesController;



@class JRTIPAddressesViewController;
@protocol JRTIPAddressesViewControllerDelegate <NSObject>
@optional
- (void) IPAddressesViewControllerDidFinish: (JRTIPAddressesViewController *) viewController;
@end


@interface JRTIPAddressesViewController : UIViewController
@property (nonatomic, weak) id <JRTIPAddressesViewControllerDelegate> delegate;

@property (nonatomic, strong) JRTIPAddressesController * IPAddressesController;
@end
