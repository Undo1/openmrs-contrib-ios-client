//
//  ActiveVisitsList.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 5/29/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//
#import "OpenMRSAPIManager.h"
#import "SVProgressHUD.h"
#import "ActiveVisitsList.h"
#import "MRSHelperFunctions.h"


@interface ActiveVisitsList ()

@property (nonatomic, strong) NSMutableArray *activeVisits;
@property (nonatomic) int startIndex;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL hasMore;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation ActiveVisitsList

#define MARGIN 5
#define SPINNERSIZE 50

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    self.title = @"Active visits";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close)];
    if ([MRSHelperFunctions isNull:self.activeVisits]) {
        self.activeVisits = [[NSMutableArray alloc] init];
    }
    
    //else paramters are set from restoration
    if (self.startIndex == 0) {
        self.hasMore = YES;
    }
    if (self.activeVisits.count == 0) {
        [self loadMore];
    }

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"transperantCell"];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.rowHeight = 66;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    if(![MRSHelperFunctions isNull:self.currentIndexPath]) {
        [self.tableView scrollToRowAtIndexPath:self.currentIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.hasMore) {
        return self.activeVisits.count + 1;
    } else {
        return self.activeVisits.count;
    }
}

- (void)close
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == self.activeVisits.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"transperantCell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"transperantCell"];
        }
        [[cell contentView] setBackgroundColor:[UIColor clearColor]];
        [[cell backgroundView] setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];

        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGSize size = cell.contentView.frame.size;
        [loading setFrame:CGRectMake(size.width/2 - SPINNERSIZE/2, 33 - SPINNERSIZE / 2, SPINNERSIZE, SPINNERSIZE)];
        [cell.contentView addSubview:loading];
        [loading startAnimating];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        MRSVisit *visit = self.activeVisits[indexPath.row];
        cell.textLabel.text = visit.displayName;
        cell.textLabel.numberOfLines = 2;
    }
    cell.userInteractionEnabled = NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndexPath = indexPath;
    if (indexPath.row == self.activeVisits.count- MARGIN && !self.loading && self.hasMore) {
        [self loadMore];
    }
}

- (void)loadMore {
    self.loading = YES;
    [SVProgressHUD showWithStatus:@"Loading more visits.."];
    [OpenMRSAPIManager getActiveVisits:self.activeVisits From:self.startIndex withCompletion:^(NSError *error) {
        if (!error) {
            [self.tableView reloadData];
            int current = self.startIndex;
            self.startIndex = self.activeVisits.count;
            self.loading = NO;
            [self addNewRows:current];
            [SVProgressHUD showSuccessWithStatus:@"Done"];
        } else {
            if (self.activeVisits.count == 0){
                [SVProgressHUD showErrorWithStatus:@"Can not load active visits"];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Problem loading more active visits"];
            }
        }
    }];
}
-(void)addNewRows:(int)currentIndex {
    if (self.startIndex - currentIndex < 50) {
        self.hasMore = NO;
    }

    [self.tableView reloadData];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.activeVisits forKey:@"activeVisits"];
    [coder encodeObject:[NSNumber numberWithInt:self.startIndex] forKey:@"startIndex"];
    [coder encodeObject:[NSNumber numberWithBool:self.hasMore] forKey:@"hasMore"];
    [coder encodeObject:self.currentIndexPath forKey:@"currentRow"];
    [super encodeRestorableStateWithCoder:coder];
}

#pragma mark - UIViewControllerRestortion

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    ActiveVisitsList *activeVisitsVC = [[ActiveVisitsList alloc] initWithStyle:UITableViewStyleGrouped];
    activeVisitsVC.activeVisits = [coder decodeObjectForKey:@"activeVisits"];
    activeVisitsVC.startIndex = [[coder decodeObjectForKey:@"startIndex"] intValue];
    activeVisitsVC.hasMore = [[coder decodeObjectForKey:@"hasMore"] boolValue];
    activeVisitsVC.currentIndexPath = [coder decodeObjectForKey:@"currentRow"];
    NSLog(@"Revisied");
    return activeVisitsVC;
}

@end
