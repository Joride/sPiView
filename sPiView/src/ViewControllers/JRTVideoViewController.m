//
//  ViewController.m
//  sPiView
//
//  Created by Joride on 16-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

#import "JRTVideoViewController.h"
#import "JRTH264VideoStreamController.h"
#import "UIImage+LaunchImage.h"
#import "JRTIPAddressesViewController.h"
#import "JRTIPAddressesController.h"
#import "JRTIPAddress.h"

@interface JRTVideoViewController ()
<JRTIPAddressesViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (readonly) UIImageView * imageView;
@property (nonatomic, getter=isPlaying) BOOL playing;
@property (readonly) JRTH264VideoStreamController * videoStreamController;

@property (nonatomic, readonly) JRTIPAddressesController * IPAddressesController;
@property (nonatomic, strong) JRTIPAddress * currentIPAddress;
@property (nonatomic, getter=isVideoStreamControllerStale) BOOL videoStreamControllerStale;
@end

@implementation JRTVideoViewController
@synthesize IPAddressesController = _IPAddressesController;
-(JRTIPAddressesController *)IPAddressesController
{
    if (nil == _IPAddressesController)
    {
        _IPAddressesController = [[JRTIPAddressesController alloc] init];
    }
    return _IPAddressesController;
}
-(UIImageView *)imageView
{
    NSAssert([self.view isKindOfClass: [UIImageView class]],
             @"Expecting self.view to be of type UIImaView");
    return (UIImageView *)self.view;
}
-(void)viewDidLoad
{
    [super viewDidLoad];

    [self updateTitle];
    self.imageView.image = [UIImage launchImage];

    [self setupNavigationItems];
}
- (void) updateTitle
{
    NSString * title;
    if (nil != self.currentIPAddress.ipAddress)
    {
        title = [NSString localizedStringWithFormat: @"%@ (%@)",
                 NSLocalizedString(@"Video ", nil),
                 self.currentIPAddress.ipAddress];
    }
    else
    {
        title = NSLocalizedString(@"Video ", nil);

    }

    self.title = title;
}
- (void) setupNavigationItems
{
    UIBarButtonItem * toggleVideo;
    toggleVideo = [[UIBarButtonItem alloc] initWithTitle: @"Toggle Video"
                                                   style: UIBarButtonItemStylePlain
                                                  target: self
                                                  action: @selector(toggleCamera:)];
    self.navigationItem.leftBarButtonItem = toggleVideo;

    UIBarButtonItem * showIPAddressesViewController;
    showIPAddressesViewController = [[UIBarButtonItem alloc]
                                     initWithTitle: @"IP address"
                                     style: UIBarButtonItemStylePlain
                                     target: self
                                     action: @selector(showIPAddressesViewController:)];
    self.navigationItem.rightBarButtonItem = showIPAddressesViewController;
}
- (void) showIPAddressesViewController: (UIBarButtonItem *) barButtonItem
{
    [self performSegueWithIdentifier: @"presentIPAddressesViewController"
                              sender: self];
}

@synthesize videoStreamController = _videoStreamController;
-(JRTH264VideoStreamController *)videoStreamController
{
    if (nil == _videoStreamController)
    {
        self.currentIPAddress = [self.IPAddressesController selectedIPAddressMainQueueContext];
        NSAssert(nil != self.currentIPAddress,
                 @"There should be a selected IP address before starting a stream");
        NSString * IPAddress = self.currentIPAddress.ipAddress;

        _videoStreamController = [[JRTH264VideoStreamController alloc]
                                  initWithIPAddress: IPAddress];
        _videoStreamController.sampleBufferDisplayLayer.backgroundColor = [UIColor clearColor].CGColor;
    }
    return _videoStreamController;
}
-(void)setCurrentIPAddress:(JRTIPAddress *)currentIPAddress
{
    if (currentIPAddress != _currentIPAddress)
    {
        [_currentIPAddress removeObserver: self
                               forKeyPath: @"isSelected"];
        _currentIPAddress = currentIPAddress;
        [_currentIPAddress addObserver: self
                            forKeyPath: @"isSelected"
                               options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                               context: NULL];
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSString *,id> *)change
                      context:(void *)context
{
    if (object == self.currentIPAddress)
    {
        if (!self.currentIPAddress.isSelected.boolValue)
        {
            self.videoStreamControllerStale = YES;
        }
    }
}

-(void)dealloc
{
    // clear out self as observer
    self.currentIPAddress = nil;
}
- (void)toggleCamera: (UIBarButtonItem *) barButtonItem
{
    self.currentIPAddress = nil;
    if (!self.isPlaying)
    {
        self.playing = YES;
        if (self.isVideoStreamControllerStale)
        {
            _videoStreamController = nil;
        }
        [self.view.layer insertSublayer: self.videoStreamController.sampleBufferDisplayLayer
                                atIndex: 0];
        self.videoStreamController.sampleBufferDisplayLayer.frame = self.view.bounds;
        [self.videoStreamController startStream];
    }
    else
    {
        self.playing = NO;
        [self.videoStreamController stopStream];
        [self.videoStreamController.sampleBufferDisplayLayer removeFromSuperlayer];
    }
    [self updateTitle];
}
-(void)viewWillTransitionToSize:(CGSize)size
      withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        CGRect videoFrame = self.videoStreamController.sampleBufferDisplayLayer.frame;
        videoFrame.size = size;
        self.videoStreamController.sampleBufferDisplayLayer.frame = videoFrame;

        UIImage * image = [UIImage launchImage];
        self.imageView.image = image;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
}

#pragma mark -
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"presentIPAddressesViewController"])
    {
        UINavigationController * navigationController = segue.destinationViewController;
        NSAssert([navigationController isKindOfClass: [UINavigationController class]],
                 @"Expecting a UINavigationController here");
        NSAssert(navigationController.viewControllers.count > 0,
                 @"Expecinting at least one viewController in the navigationController, as we are going to acces viewController at index zro now");
        JRTIPAddressesViewController * IPAddressesViewController;
        IPAddressesViewController = navigationController.viewControllers[0];
        NSAssert([IPAddressesViewController isKindOfClass: [JRTIPAddressesViewController class]],
                 @"Expecting a JRTIPAddressesViewController here");

        IPAddressesViewController.delegate = self;
        IPAddressesViewController.IPAddressesController = self.IPAddressesController;
    }
}
#pragma mark - JRTIPAddressesViewControllerDelegate
- (void) IPAddressesViewControllerDidFinish: (JRTIPAddressesViewController *) viewController
{
    [self dismissViewControllerAnimated: YES
                             completion: NULL];
}
@end
