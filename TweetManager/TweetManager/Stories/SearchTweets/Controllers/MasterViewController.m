//
//  MasterViewController.m
//  TweetManager
//
//  Created by Awais Arshad Chatha on 2016-03-05.
//  Copyright © 2016 DevCrew. All rights reserved.
//

#import "MasterViewController.h"
#import "TwitterLoader.h"
#import "SVProgressHUD.h"
#import "TMUtility.h"
#import "TweetCell.h"
#import "FooterView.h"
#import "CoreDataManager.h"

#define CellIdentifier  @"twitterCell"
#define FooterIdentifier @"footerView"

@interface MasterViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UISearchResultsUpdating, TweetCellDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) TwitterLoader *twitterLoader;
@property (strong, nonatomic) NSMutableArray *tweets;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self viewConfigurations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)valueChanged:(UISegmentedControl *)sender {
    
    [self setCurrentViewWithSelectedSegment];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Tweet * tweet = self.tweets[indexPath.row];
    [cell configureCell:tweet withButtonType:self.segmentControl.selectedSegmentIndex];
    cell.delegate = self;
    return cell;
}
/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    FooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:FooterIdentifier];
    if (!footerView) {
        footerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([FooterView class]) owner:nil options:nil] firstObject];
    }
    footerView.footerDelegate = self;
    return footerView;
}*/

#pragma mark - Private Methods

-(void)viewConfigurations {
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.definesPresentationContext = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TweetCell class]) bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    [self setCurrentViewWithSelectedSegment];
    
    self.tableView.rowHeight = 100;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    self.twitterLoader = [TwitterLoader new];
    
}

- (void)tweetsLoadingSuccess:(NSArray *)tweets {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        self.tweets = tweets.mutableCopy;
        [self.tableView reloadData];
    });
}

- (void)tweetsLoadingFailed:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [TMUtility showAlertWithTitle:@"Error" withMessage:error.localizedDescription];
    });
}

- (void)setCurrentViewWithSelectedSegment {
    
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0: //searched
            self.tableView.tableHeaderView = self.searchController.searchBar;
            self.tweets = nil;
            break;
            
        case 1://saved
        {
            self.searchController.active = NO;
            self.tableView.tableHeaderView = nil;
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:[appDelegate managedObjectContext]];
            self.tweets = [dataManager getAllObjectsFor:entity].mutableCopy;
        }
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
    
}

#pragma mark - UISearchResultsUpdating Methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
//    NSString * searchString = searchController.searchBar.text;
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSString * searchString = searchBar.text;
    
    [SVProgressHUD show];
    
    [self.twitterLoader getTweetsWithText:searchString withSuccessBlock:^(NSArray *tweets) {
        
        [self tweetsLoadingSuccess:tweets];
        
    } failureBlock:^(NSError *error) {
        
        [self tweetsLoadingFailed:error];
        
    }];
    
}

#pragma mark - TweetCellDelegate Methods

- (void)cell:(TweetCell *)cell withTweet:(Tweet *)tweet didTapSaveButton:(UIButton *)button {
    
    NSError *error = [dataManager insertNewObject:tweet];
    
    if (error) {
        
        [TMUtility showAlertWithTitle:@"Error" withMessage:error.localizedDescription];
        return;
    }
    
    [self.tweets removeObject:tweet];
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:cell];
    [self.tableView deleteRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
- (void)cell:(TweetCell *)cell withTweet:(Tweet *)tweet didTapDeleteButton:(UIButton *)button {
    
    NSError *error = [dataManager deleteObject:tweet];
    
    if (error) {
        
        [TMUtility showAlertWithTitle:@"Error" withMessage:error.localizedDescription];
        return;
    }
    
    [self.tweets removeObject:tweet];
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:cell];
    [self.tableView deleteRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

@end
