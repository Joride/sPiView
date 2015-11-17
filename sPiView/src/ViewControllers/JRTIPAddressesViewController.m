//
//  JRTIPAddressesViewController.m
//  sPiView
//
//  Created by Joride on 17-11-15.
//  Copyright © 2015 KerrelInc. All rights reserved.
//

#import "JRTIPAddressesViewController.h"
#import "JRTEditIPAddressViewController.h"
#import "JRTIPAddressesController.h"
#import "JRTIPAddressesCollectionViewDataSource.h"

@interface JRTIPAddressesViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) JRTIPAddressesCollectionViewDataSource * dataSource;
@end

@implementation JRTIPAddressesViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"IP addresses", nil);
    
    [self setupNavigationItems];

    [self setupCollectionView];
}
- (void) setupCollectionView
{
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.dataSource = [[JRTIPAddressesCollectionViewDataSource alloc] init];
    self.dataSource.mainQueueManagedObjectContext = self.IPAddressesController.mainQueueContext;
    self.dataSource.IPAddressesController = self.IPAddressesController;
    self.dataSource.collectionView = self.collectionView;
    self.collectionView.delegate = self.dataSource;
    self.collectionView.dataSource = self.dataSource;

    UICollectionViewFlowLayout * flowLayout;
    flowLayout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    NSAssert([flowLayout isKindOfClass: [UICollectionViewFlowLayout class]],
             @"Expecint a UICollectionViewFlowLayout here");
    flowLayout.sectionHeadersPinToVisibleBounds = YES;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 20, 0);
    flowLayout.minimumLineSpacing = 1.00f / [[UIScreen mainScreen] scale];
}
- (void) setupNavigationItems
{
    UIBarButtonItem * doneButton;
    doneButton = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                  target: self
                  action: @selector(doneButtonTapped:)];
    self.navigationItem.leftBarButtonItem = doneButton;

    UIBarButtonItem * newIPAddressButton;
    newIPAddressButton = [[UIBarButtonItem alloc]
                          initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                          target: self
                          action: @selector(newIPAddressButtonTapped:)];
    self.navigationItem.rightBarButtonItem = newIPAddressButton;
}

- (void) doneButtonTapped: (UIBarButtonItem *) barButtonItem
{
    id strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector: @selector(IPAddressesViewControllerDidFinish:)])
    {
        [strongDelegate IPAddressesViewControllerDidFinish: self];
    }
}

- (void) newIPAddressButtonTapped: (UIBarButtonItem *) barButtonItem
{
    [self performSegueWithIdentifier: @"pushJRTEditIPAddressViewController"
                              sender: self];
}
#pragma mark -
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"pushJRTEditIPAddressViewController"])
    {
        JRTEditIPAddressViewController * editIPAddressViewController;
        editIPAddressViewController = segue.destinationViewController;
        NSAssert([editIPAddressViewController isKindOfClass: [JRTEditIPAddressViewController class]],
                 @"Expecting a JRTEditIPAddressViewController here");

        editIPAddressViewController.title = NSLocalizedString(@"New IP address", nil);
        editIPAddressViewController.IPAddressesController = self.IPAddressesController;

        NSManagedObjectContext * newManagedObjectContext;
        newManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        newManagedObjectContext.parentContext = self.IPAddressesController.mainQueueContext;
        editIPAddressViewController.managedObjectContext = self.IPAddressesController.mainQueueContext;
    }
}
-(void)viewWillTransitionToSize:(CGSize)size
      withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context)
     {
         [self.collectionView.collectionViewLayout invalidateLayout];
     }
                                 completion:NULL];
}
@end
















