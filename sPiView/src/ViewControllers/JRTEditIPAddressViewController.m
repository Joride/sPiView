//
//  JRTEditIPAddressViewController.m
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "JRTEditIPAddressViewController.h"
#import "NSManagedObjectContext+Persisting.h"
#import "JRTIPAddress.h"
#import "JRTIPAddressesController.h"
#import "UIColor+sPiView.h"

@interface JRTEditIPAddressViewController ()
<UITextFieldDelegate>
@property (nonatomic, strong) JRTIPAddress * selectedIPAddress;
@property (weak, nonatomic) IBOutlet UILabel *IPAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *IPAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (nonatomic) BOOL needsUpdateUI;
@end

@implementation JRTEditIPAddressViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor raspberryPiGreen];
    self.IPAddressLabel.textColor = [UIColor raspberryPiRed];
    [self setupNavigationItems];
    if (self.needsUpdateUI)
    {
        [self updateUI];
    }
}
-(void)setIPAddress:(JRTIPAddress *)IPAddress
{
    if (_IPAddress != IPAddress)
    {
        _managedObjectContext = nil;
        _IPAddress = IPAddress;
        _selectedIPAddress = _IPAddress;
        self.needsUpdateUI = YES;
        [self updateUI];
    }
}
-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSAssert(nil != managedObjectContext,
             @"Error: you cannot set a nil managedObject on this viewController");
    if (_managedObjectContext != managedObjectContext)
    {
        _IPAddress = nil;
        _managedObjectContext = managedObjectContext;
        _selectedIPAddress = [JRTIPAddress newIPAddressInManagedObjectContext: managedObjectContext];
        self.needsUpdateUI = YES;
        [self updateUI];

    }
}
- (void) updateUI
{
    self.descriptionTextField.text = self.selectedIPAddress.title;
    self.IPAddressTextField.text = self.selectedIPAddress.ipAddress;
}
- (void) setupNavigationItems
{
    UIBarButtonItem * doneButton;
    doneButton = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                  target: self
                  action: @selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;

    UIBarButtonItem * cancel;
    cancel = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
              target: self
              action: @selector(cancelButtonTapped:)];
    self.navigationItem.leftBarButtonItem = cancel;
}

#pragma mark -
- (void) doneButtonTapped: (UIBarButtonItem *) barButtonItem
{
    if (0 == self.selectedIPAddress.ipAddress.length &&
        0 == self.selectedIPAddress.title.length)
    {
        [self.selectedIPAddress.managedObjectContext deleteObject: self.selectedIPAddress];
    }
    else
    {
        // set this IP address as the selected one
        [self.IPAddressesController setIPAddressSelected: self.selectedIPAddress];
    }


    // save
    if (self.selectedIPAddress.managedObjectContext.hasChanges)
    {
        NSError * error = nil;
        if (![self.selectedIPAddress.managedObjectContext persistError: &error])
        {
            DebugLog(@"ERROR saving MOC in %@: %@",
                     NSStringFromClass([self class]),
                     error);
        }
    }

    [self.navigationController popViewControllerAnimated: YES];
}

- (void) cancelButtonTapped: (UIBarButtonItem *) barButtonItem
{
    _managedObjectContext = nil;
    _IPAddress = nil;
    self.selectedIPAddress = nil;
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.IPAddressTextField)
    {
        [self.descriptionTextField becomeFirstResponder];
    }
    return YES;
}
-(BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSString * newText;
    newText = [textField.text stringByReplacingCharactersInRange: range
                                                      withString: string];

    if (textField == self.IPAddressTextField)
    {
        self.selectedIPAddress.ipAddress = newText;
    }
    else if (textField == self.descriptionTextField)
    {
        self.selectedIPAddress.title = newText;
    }
    return YES;
}
@end
