//
//  JRTIPAddressesCollectionViewDataSource.m
//  sPiView
//
//  Created by Joride on 18-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "JRTIPAddressesCollectionViewDataSource.h"
#import "JRTIPAddressCollectionViewCell.h"
#import "JRTIPAddress.h"
#import "JRTIPAddressesController.h"
#import "JRTIPAddressHeaderView.h"
#import "UIColor+sPiView.h"

@interface JRTIPAddressesCollectionViewDataSource ()
<NSFetchedResultsControllerDelegate,
JRTIPAddressCollectionViewCellDelegate>
@property (nonatomic, readonly) JRTIPAddressCollectionViewCell * layoutCell;
@property (nonatomic, readonly) JRTIPAddressHeaderView * layoutHeader;
@property (nonatomic, strong) NSLayoutConstraint * headerWidth;
@property (nonatomic, strong) NSLayoutConstraint * layoutCellWidth;
@property (nonatomic, readonly) NSFetchedResultsController * fetchedResultsController;
@end

@implementation JRTIPAddressesCollectionViewDataSource

@synthesize layoutCell = _layoutCell;
-(JRTIPAddressCollectionViewCell *)layoutCell
{
    if (nil == _layoutCell)
    {
        UINib * cellNib = [self newCellNib];
        NSArray * items = [cellNib instantiateWithOwner: nil
                                                options: nil];
        NSAssert(items.count == 1, @"A cellnib must contain exactly 1 top level object");

        JRTIPAddressCollectionViewCell * cell = items[0];
        NSAssert([cell isKindOfClass:[JRTIPAddressCollectionViewCell class]],
                 @"Execting a JRTIPAddressCollectionViewCell in the nib");
        _layoutCell = cell;
        self.layoutCellWidth = [NSLayoutConstraint constraintWithItem: _layoutCell.contentView
                                                            attribute: NSLayoutAttributeWidth
                                                            relatedBy: NSLayoutRelationEqual
                                                               toItem: nil
                                                            attribute: NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0f
                                                             constant: CGRectGetWidth(self.collectionView.bounds)];
        [_layoutCell.contentView addConstraint: self.layoutCellWidth];
    }

    return _layoutCell;
}
@synthesize layoutHeader = _layoutHeader;
-(UICollectionViewCell *)layoutHeader
{
    if (nil == _layoutHeader)
    {
        UINib * headerNib = [self newHeaderNib];
        NSArray * items = [headerNib instantiateWithOwner: nil
                                                  options: nil];
        NSAssert(items.count == 1,
                 @"A headerNib must contain exactly 1 top level object");

        JRTIPAddressHeaderView * header = items[0];
        NSAssert([header isKindOfClass:[JRTIPAddressHeaderView class]],
                 @"Execting a JRTIPAddressHeaderView in the nib");
        _layoutHeader = header;
        self.headerWidth = [NSLayoutConstraint constraintWithItem: header
                                                        attribute: NSLayoutAttributeWidth
                                                        relatedBy: NSLayoutRelationEqual
                                                           toItem: nil
                                                        attribute: NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant: CGRectGetWidth(self.collectionView.bounds)];
        [_layoutHeader addConstraint: self.headerWidth];
    }

    return _layoutCell;
}

-(void)setCollectionView:(UICollectionView *)collectionView
{
    if (_collectionView != collectionView)
    {
        _collectionView = collectionView;
        [self registerCells];
    }
}
- (void) registerCells
{
    UICollectionView * collectionView = self.collectionView;
    UINib * cellNib = [self newCellNib];
    [collectionView registerNib: cellNib
     forCellWithReuseIdentifier: @"cellID"];

    UINib * headerNib = [self newHeaderNib];
    [collectionView registerNib: headerNib
     forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
            withReuseIdentifier: @"headerID"];
}
- (UINib *) newHeaderNib
{
    UINib * headerNib = [UINib nibWithNibName: @"JRTIPAddressHeaderView"
                                       bundle: [NSBundle mainBundle]];
    return headerNib;
}
- (UINib *) newCellNib
{
    UINib * cellNib = [UINib nibWithNibName: @"JRTIPAddressCollectionViewCell"
                                     bundle: [NSBundle mainBundle]];
    return cellNib;
}
#pragma mark - UICollectionViewDataSource
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JRTIPAddressCollectionViewCell * cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"cellID"
                                                     forIndexPath: indexPath];
    cell.delegate = self;
    [self configureCell: cell
            atIndexPath: indexPath];
    return cell;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    return numberOfObjects;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView * headerView = nil;
    if ([kind isEqualToString: UICollectionElementKindSectionHeader])
    {
        JRTIPAddressHeaderView * IPAddressHeader;
        IPAddressHeader = [self.collectionView dequeueReusableSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                                                                  withReuseIdentifier: @"headerID"
                                                                         forIndexPath: indexPath];
        [self configureHeaderView: IPAddressHeader
                      atIndexPath: indexPath];
        headerView = IPAddressHeader;
    }
    else
    {
        headerView = [[UICollectionReusableView alloc] init];
        NSAssert(NO, @"PROGRAMMING ERROR: this clause shoul not be reached.");
    }
    return headerView;
}

#pragma mark - UICollectionViewDelegate(-FlowLayout)
-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    JRTIPAddress * IPAddress;
    IPAddress = [self.fetchedResultsController objectAtIndexPath: indexPath];
    NSAssert(nil != IPAddress,
             @"IPAddress can not be nil here");
    [self.IPAddressesController setIPAddressSelected: IPAddress];
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // set the width to match the collectionview width
    self.layoutCellWidth.constant = CGRectGetWidth(self.collectionView.bounds);

    CGSize layoutSize = CGSizeZero;
    layoutSize = [self.layoutCell.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
    return layoutSize;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    // set the width to match the collectionview width
    self.headerWidth.constant = CGRectGetWidth(self.collectionView.bounds);

    CGSize layoutSize = CGSizeZero;
    layoutSize = [self.layoutHeader systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
    
    return layoutSize;
}

#pragma mark -
- (void) configureHeaderView: (JRTIPAddressHeaderView *) headerView
                 atIndexPath: (NSIndexPath *) indexPath
{
    NSString * title = nil;
    if (indexPath.section == 0)
    {
        // the section that shows the selected IP address
        title = NSLocalizedString(@"Current IP address", nil);
    }
    else if (indexPath.section == 1)
    {
        title = NSLocalizedString(@"Choose a different IP address", nil);
    }
    else
    {
        // currently not expected, as we only have 2 sections
        NSAssert(NO, @"There is an unexpected third section");
    }
    headerView.titleLabel.text = title;

    headerView.titleLabel.textColor = [UIColor whiteColor];
    headerView.backgroundColor = [UIColor raspberryPiGreen];
}

- (void) configureCell: (JRTIPAddressCollectionViewCell *) cell
           atIndexPath: (NSIndexPath *) indexPath
{
    JRTIPAddress * IPAddress;
    IPAddress = [self.fetchedResultsController objectAtIndexPath: indexPath];
    cell.IPAddressLabel.text = IPAddress.ipAddress;
    cell.titleLabel.text = IPAddress.title;
    cell.isSelectedLabel.hidden = !IPAddress.isSelected.boolValue;

    cell.titleLabel.textColor = [UIColor raspberryPiGreen];
    cell.IPAddressLabel.textColor = [UIColor raspberryPiRed];

    UIColor * cellColor = [UIColor whiteColor];
    cell.backgroundColor = cellColor;
}

#pragma mark - FetchedRestultController
@synthesize fetchedResultsController = _fetchedResultsController;
-(NSFetchedResultsController *)fetchedResultsController
{
    if (nil == _fetchedResultsController)
    {
        NSFetchRequest * fetchForIPAddresses;
        fetchForIPAddresses = [NSFetchRequest fetchRequestWithEntityName: NSStringFromClass([JRTIPAddress class])];
        NSSortDescriptor * sortBySelectionStatus;
        sortBySelectionStatus = [NSSortDescriptor sortDescriptorWithKey: @"isSelected"
                                                              ascending: NO];
        NSSortDescriptor * sortByDate;
        sortByDate = [NSSortDescriptor sortDescriptorWithKey: @"modificationDate"
                                                   ascending: NO];
        fetchForIPAddresses.sortDescriptors = @[sortBySelectionStatus,
                                                sortByDate];
        _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest: fetchForIPAddresses
                                                                       managedObjectContext: self.mainQueueManagedObjectContext
                                                                         sectionNameKeyPath: @"isSelected"
                                                                                  cacheName: nil];
        _fetchedResultsController.delegate = self;
        NSError * fetchError = nil;
        if (![_fetchedResultsController performFetch: &fetchError])
        {
            DebugLog(@"ERROR: could not perform fetch in %@: %@",
                     NSStringFromClass([self class]),
                     fetchError);
        }
    }
    return _fetchedResultsController;
}


#pragma mark - FetchedResultsControllerDelegate
- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    DebugLog(@"controllerWillChangeContent:");
}
-(void)controller:(NSFetchedResultsController *)controller
  didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath
    forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath
{
    DebugLog(@"didChangeObject:");
}
-(void)controller:(NSFetchedResultsController *)controller
 didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
          atIndex:(NSUInteger)sectionIndex
    forChangeType:(NSFetchedResultsChangeType)type
{
    DebugLog(@"didChangeSection:");
}
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    DebugLog(@"controllerDidChangeContent:");
    [self.collectionView reloadData];
}
#pragma mark - JRTIPAddressCollectionViewCellDelegate
-(void)IPAddressCollectionViewCellDidTapInfoButton:(JRTIPAddressCollectionViewCell *)cell
{
    NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint: cell.center];
    if (nil != indexPath)
    {
        id <JRTIPAddressesCollectionViewDataSourceDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(IPAddressesCollectionViewDataSource:didSelectIPAddress:)])
        {
            JRTIPAddress * IPAddress;
            IPAddress = [self.fetchedResultsController objectAtIndexPath: indexPath];
            [delegate IPAddressesCollectionViewDataSource:self
                                       didSelectIPAddress: IPAddress];
        }
    }
    else
    {
        DebugLog(@"ERROR: no indexPath found for cell in %@ (%@). Cell: %@",
                 NSStringFromClass([self class]),
                 NSStringFromSelector(_cmd),
                 cell);
    }
}
@end
