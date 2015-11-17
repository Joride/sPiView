//
//  JRTIPAddressesCollectionViewDataSource.h
//  sPiView
//
//  Created by Joride on 18-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

@import UIKit;
@import CoreData;
@class JRTIPAddressesController;

@interface JRTIPAddressesCollectionViewDataSource : NSObject
<UICollectionViewDataSource,
UICollectionViewDelegate>
@property (nonatomic, weak) UICollectionView * collectionView;
@property (nonatomic, strong) NSManagedObjectContext * mainQueueManagedObjectContext;
@property (nonatomic, strong) JRTIPAddressesController * IPAddressesController;
@end
