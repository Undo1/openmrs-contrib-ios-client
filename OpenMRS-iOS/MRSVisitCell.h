//
//  MRSVisitCell.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 6/23/15.
//

#import <UIKit/UIKit.h>

@class MRSVisit;
@interface MRSVisitCell : UITableViewCell

@property (nonatomic, strong) MRSVisit *visit;
@property (nonatomic, strong) NSNumber *index;

- (void)setVisit:(MRSVisit *)visit;
+ (void)updateTableViewForDynamicTypeSize:(UITableView *) tableview;

@end
