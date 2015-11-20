//
//  JRTIPAddressCollectionViewCell.m
//  sPiView
//
//  Created by Joride on 18-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "JRTIPAddressCollectionViewCell.h"

@interface JRTIPAddressCollectionViewCell ()
@property (nonatomic, strong, readwrite) IBOutlet UILabel * IPAddressLabel;
@property (nonatomic, strong, readwrite) IBOutlet UILabel * titleLabel;
@property (nonatomic, strong, readwrite) IBOutlet UILabel * isSelectedLabel;
@end

@implementation JRTIPAddressCollectionViewCell
- (IBAction)infoButtonTapped:(UIButton *)sender
{
    id <JRTIPAddressCollectionViewCellDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(IPAddressCollectionViewCellDidTapInfoButton:)])
    {
        [delegate IPAddressCollectionViewCellDidTapInfoButton: self];
    }
}

@end
