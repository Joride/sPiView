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

@interface JRTVideoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (readonly) UIImageView * imageView;
@property (nonatomic, getter=isPlaying) BOOL playing;
@property (readonly) JRTH264VideoStreamController * videoStreamController;
@end

@implementation JRTVideoViewController

-(UIImageView *)imageView
{
    NSAssert([self.view isKindOfClass: [UIImageView class]],
             @"Expecint self.view to be of type UIImaView");
    return (UIImageView *)self.view;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = [UIImage launchImage];
}

@synthesize videoStreamController = _videoStreamController;
-(JRTH264VideoStreamController *)videoStreamController
{
    if (nil == _videoStreamController)
    {
        _videoStreamController = [[JRTH264VideoStreamController alloc] init];
        _videoStreamController.sampleBufferDisplayLayer.backgroundColor = [UIColor clearColor].CGColor;
    }
    return _videoStreamController;
}
- (IBAction)toggleCamera:(id)sender
{
    if (!self.isPlaying)
    {
        self.playing = YES;
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

@end
