//
//  JRTIPAddressCollectionViewCell.h
//  sPiView
//
//  Created by Joride on 18-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import UIKit;

@class JRTIPAddressCollectionViewCell;
@protocol JRTIPAddressCollectionViewCellDelegate <NSObject>
@optional
- (void) IPAddressCollectionViewCellDidTapInfoButton: (JRTIPAddressCollectionViewCell *) cell;

@end

@interface JRTIPAddressCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) id <JRTIPAddressCollectionViewCellDelegate> delegate;
@property (nonatomic, readonly) UILabel * IPAddressLabel;
@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UILabel * isSelectedLabel;
@end
