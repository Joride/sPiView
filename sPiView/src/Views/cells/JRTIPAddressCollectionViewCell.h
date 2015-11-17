//
//  JRTIPAddressCollectionViewCell.h
//  sPiView
//
//  Created by Jorrit van Asselt on 18-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import UIKit;

@interface JRTIPAddressCollectionViewCell : UICollectionViewCell
@property (nonatomic, readonly) UILabel * IPAddressLabel;
@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UILabel * isSelectedLabel;
@end
