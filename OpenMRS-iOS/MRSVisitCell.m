//
//  MRSVisitCell.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 6/23/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "MRSVisitCell.h"
#import "MRSVisit.h"
#import "MRSDateUtilities.h"
#import "OpenMRS-iOS-Bridging-Header.h"
#import "OpenMRS_iOS-Swift.h"

@interface MRSVisitCell ()

@property (nonatomic, strong) UILabel *location;
@property (nonatomic, strong) UILabel *visitType;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *activeLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *visitTypeLabel;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic) BOOL didSetupConstrains;

@end

@implementation MRSVisitCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIFont *title = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        UIFont *value = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        UIFont *footerfont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

        self.indexLabel = [[UILabel alloc] init];
        self.indexLabel.textAlignment = NSTextAlignmentCenter;
        self.indexLabel.textColor = [UIColor whiteColor];
        self.indexLabel.backgroundColor = [UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1];
        self.indexLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.indexLabel];
        
        self.locationLabel = [[UILabel alloc] init];
        self.locationLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Location", @"Label location")];
        self.locationLabel.textAlignment = NSTextAlignmentLeft;
        self.locationLabel.textColor = [UIColor blackColor];
        self.locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.locationLabel.font = title;
        [self.contentView addSubview:self.locationLabel];
        
        self.visitTypeLabel = [[UILabel alloc] init];
        self.visitTypeLabel.text = [NSString stringWithFormat:@"%@: ", NSLocalizedString(@"Visit Type", @"Label -visit- -type-")];
        self.visitTypeLabel.textAlignment = NSTextAlignmentLeft;
        self.visitTypeLabel.textColor = [UIColor blackColor];
        self.visitTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.visitTypeLabel.font = title;
        [self.contentView addSubview:self.visitTypeLabel];
        
        self.location = [[UILabel alloc] init];
        self.location.textAlignment = NSTextAlignmentLeft;
        self.location.textColor = [UIColor grayColor];
        self.location.translatesAutoresizingMaskIntoConstraints = NO;
        self.location.font = value;
        [self.contentView addSubview:self.location];
        
        self.visitType = [[UILabel alloc] init];
        self.visitType.textAlignment = NSTextAlignmentLeft;
        self.visitType.textColor = [UIColor grayColor];
        self.visitType.translatesAutoresizingMaskIntoConstraints = NO;
        self.visitType.font = value;
        [self.contentView addSubview:self.visitType];
        
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.textColor = [UIColor grayColor];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.dateLabel.font = footerfont;
        [self.contentView addSubview:self.dateLabel];
        
        self.activeLabel = [[UILabel alloc] init];
        self.activeLabel.textAlignment = NSTextAlignmentRight;
        self.activeLabel.textColor = [UIColor grayColor];
        self.activeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.activeLabel.font = footerfont;
        [self.contentView addSubview:self.activeLabel];
        [self updateFonts];
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    return self;
}

- (void)setVisit:(MRSVisit *)visit {
    self.location.text = visit.location.display;
    
    self.visitType.text = visit.visitType.display;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    self.dateLabel.text = [formatter stringFromDate:[MRSDateUtilities  dateFromOpenMRSFormattedString:visit.startDateTime]];
    
    if (visit.active) {
        self.activeLabel.textColor = [UIColor greenColor];
        self.activeLabel.text = [NSString stringWithFormat:@"%@ -", NSLocalizedString(@"Active", @"Label active")];
    } else {
        self.activeLabel.textColor = [UIColor redColor];
        self.activeLabel.text = [NSString stringWithFormat:@"%@ -", NSLocalizedString(@"Ended", @"Label ended")];
    }
    _visit = visit;
}

- (void)setIndex:(NSNumber *)index {
    self.indexLabel.text = [index stringValue];
    _index = index;
}
- (void)setFrame:(CGRect)frame {
    frame.size.height -= 10;
    [super setFrame:frame];
}

- (void)updateConstraints {
    if (!self.didSetupConstrains) {
        NSDictionary *views = @{
                                @"locationLabel": self.locationLabel,
                                @"visitTypeLabel": self.visitTypeLabel,
                                @"location": self.location,
                                @"visitType": self.visitType,
                                @"date": self.dateLabel,
                                @"active": self.activeLabel,
                                @"index": self.indexLabel
                                };
        NSArray *horizonConstForLocation = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[index(40)]-10-[locationLabel]-5-[location]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizonConstForLocation];
        
        NSArray *verticalConstForLocation1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[locationLabel]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstForLocation1];

        NSArray *verticalConstForLocation2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[location]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstForLocation2];
        
        NSArray *horizontalConstForVisitType = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[index(40)]-10-[visitTypeLabel]-5-[visitType]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizontalConstForVisitType];
        
        NSArray *verticalConstForVisitType1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[locationLabel]-5-[visitTypeLabel]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstForVisitType1];

        NSArray *verticalConstForVisitType2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[location]-5-[visitType]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstForVisitType2];

        NSArray *horizonConstForDate = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[date]-5-|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizonConstForDate];
        
        NSArray *verticalConstForDate = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[date]-5-|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstForDate];
        
        NSArray *horizonConstForActive = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[active]-5-[date]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizonConstForActive];
        
        NSArray *vericalConstForActive = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[active]-5-|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:vericalConstForActive];
        
        NSArray *verticalConstForIndex = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[index]-0-|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstForIndex];
        
        self.didSetupConstrains = YES;
    }
    [super updateConstraints];
}

+ (void)updateTableViewForDynamicTypeSize:(UITableView *) tableview {
    static NSDictionary *cellHeightDictionary;
    
    if (!cellHeightDictionary) {
        cellHeightDictionary = @{ UIContentSizeCategoryExtraSmall : @77,
                                  UIContentSizeCategorySmall : @77,
                                  UIContentSizeCategoryMedium : @88,
                                  UIContentSizeCategoryLarge : @88,
                                  UIContentSizeCategoryExtraLarge : @100,
                                  UIContentSizeCategoryExtraExtraLarge : @112,
                                  UIContentSizeCategoryExtraExtraExtraLarge : @134
                                  };
    }
    
    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    
    NSNumber *cellHeight = cellHeightDictionary[userSize];
    [tableview setRowHeight:cellHeight.floatValue];
    [tableview reloadData];
}

- (void)updateFonts {
    UIFont *title = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    UIFont *value = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFont *footerfont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
    self.locationLabel.font = title;
    self.visitTypeLabel.font = title;
    self.indexLabel.font = title;
    
    self.location.font = value;
    self.visitType.font = value;
    
    self.dateLabel.font = footerfont;
    self.activeLabel.font = footerfont;
}

@end
