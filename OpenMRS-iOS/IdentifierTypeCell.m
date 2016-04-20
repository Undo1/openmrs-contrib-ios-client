//
//  MRSVisitCell.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 6/26/15.
//

#import "IdentifierTypeCell.h"
#import "MRSPatientIdentifierType.h"
#import "OpenMRS-iOS-Bridging-Header.h"
#import "OpenMRS_iOS-Swift.h"

@interface IdentifierTypeCell ()

@property (nonatomic, strong) UILabel *display;
@property (nonatomic, strong) UILabel *identifierdescription;
@property (nonatomic, strong) UILabel *displayLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic) BOOL didSetupConstrains;

@end

@implementation IdentifierTypeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIFont *title = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        UIFont *value = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        self.indexLabel = [[UILabel alloc] init];
        self.indexLabel.textAlignment = NSTextAlignmentCenter;
        self.indexLabel.textColor = [UIColor whiteColor];
        self.indexLabel.backgroundColor = [UIColor colorWithRed:39/255.0 green:139/255.0 blue:146/255.0 alpha:1];
        self.indexLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.indexLabel];
        
        self.displayLabel = [[UILabel alloc] init];
        self.displayLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Display", @"Label location")];
        self.displayLabel.textAlignment = NSTextAlignmentLeft;
        self.displayLabel.textColor = [UIColor blackColor];
        self.displayLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.displayLabel.font = title;
        [self.displayLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.displayLabel];
        
        self.descriptionLabel = [[UILabel alloc] init];
        self.descriptionLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Description", @"Label -visit- -type-")];
        self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
        self.descriptionLabel.textColor = [UIColor blackColor];
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.descriptionLabel.font = title;
        [self.descriptionLabel sizeToFit];
        [self.descriptionLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.descriptionLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.descriptionLabel];
        
        self.display = [[UILabel alloc] init];
        self.display.textAlignment = NSTextAlignmentLeft;
        self.display.textColor = [UIColor grayColor];
        self.display.translatesAutoresizingMaskIntoConstraints = NO;
        self.display.font = value;
        [self.contentView addSubview:self.display];
        
        self.identifierdescription = [[UILabel alloc] init];
        self.identifierdescription.textAlignment = NSTextAlignmentLeft;
        self.identifierdescription.textColor = [UIColor grayColor];
        self.identifierdescription.translatesAutoresizingMaskIntoConstraints = NO;
        self.identifierdescription.font = value;
        self.identifierdescription.lineBreakMode = NSLineBreakByWordWrapping;
        self.identifierdescription.numberOfLines = 0;
        [self.contentView addSubview:self.identifierdescription];
        [self updateFonts];
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    return self;
}

- (void)setIdentifierType:(MRSPatientIdentifierType *)identifierType {
    self.display.text = identifierType.display;
    
    self.identifierdescription.text = identifierType.typeDescription;
    NSLog(@"display : %@, des: %@", self.display.text, self.identifierdescription.text);
    _IdentifierType = identifierType;
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
                                @"displayLabel": self.displayLabel,
                                @"descriptionLabel": self.descriptionLabel,
                                @"display": self.display,
                                @"description": self.identifierdescription,
                                @"index": self.indexLabel
                                };
        NSArray *horizonConstForDisplay = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[index(40)]-10-[displayLabel]-5-[display]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizonConstForDisplay];
        
        NSArray *verticalConstForDisplay1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[displayLabel]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstForDisplay1];
        
        NSArray *verticalConstForDisplay2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[display]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstForDisplay2];
        
        NSArray *horizontalConstForDescription = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[index(40)]-10-[descriptionLabel]-5-[description]-5-|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizontalConstForDescription];
        
        NSArray *verticalConstForDescription1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[displayLabel]-5-[descriptionLabel]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstForDescription1];
        
        NSArray *verticalConstForDescription2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[display]-8-[description]" options:0 metrics:nil views:views];
        [self.contentView addConstraints:verticalConstForDescription2];
        
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
                                  UIContentSizeCategoryMedium : @95,
                                  UIContentSizeCategoryLarge : @95,
                                  UIContentSizeCategoryExtraLarge : @107,
                                  UIContentSizeCategoryExtraExtraLarge : @117,
                                  UIContentSizeCategoryExtraExtraExtraLarge : @145
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
    UIFont *desc = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
    self.displayLabel.font = title;
    self.descriptionLabel.font = title;
    self.indexLabel.font = title;
    
    self.display.font = value;
    self.identifierdescription.font = desc;
}

@end
