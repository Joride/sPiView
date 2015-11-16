//
//  ViewController.m
//  sPiView
//
//  Created by Joride on 16-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

#import "JRTVideoViewController.h"
#import "JRTH264VideoStreamController.h"

@interface JRTVideoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@end

@implementation JRTVideoViewController
{
    JRTH264VideoStreamController * _videoStreamController;
    BOOL _isPlaying;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    ((UIImageView *)self.view).image = [UIImage imageNamed: @"launchImage-640x1136"];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    _videoStreamController = [[JRTH264VideoStreamController alloc] init];
    _videoStreamController.sampleBufferDisplayLayer.backgroundColor = [UIColor clearColor].CGColor;

}
- (IBAction)toggleCamera:(id)sender
{
    if (!_isPlaying)
    {
        _isPlaying = YES;
        [self.view.layer insertSublayer: _videoStreamController.sampleBufferDisplayLayer
                                atIndex: 0];
        _videoStreamController.sampleBufferDisplayLayer.frame = self.view.bounds;
        [_videoStreamController startStream];
        
    }
    else
    {
        _isPlaying = NO;
        [_videoStreamController stopStream];
        [_videoStreamController.sampleBufferDisplayLayer removeFromSuperlayer];

    }
}
-(void)viewWillTransitionToSize:(CGSize)size
      withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        CGRect videoFrame = self->_videoStreamController.sampleBufferDisplayLayer.frame;
        videoFrame.size = size;
        self->_videoStreamController.sampleBufferDisplayLayer.frame = videoFrame;

        UIImage * image = (size.width >= size.height) ?
        [UIImage imageNamed: @"launchImage-1136x640"] :
        [UIImage imageNamed: @"launchImage-640x1136"];

        ((UIImageView *)self.view).image = image;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
}

@end
