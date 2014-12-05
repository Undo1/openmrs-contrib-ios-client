//
//  SelectEncounterTypeView.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/5/14.
//  Copyright (c) 2014 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRSEncounterType;
@protocol SelectEncounterTypeViewDelegate <NSObject>
- (void)didSelectEncounterType:(MRSEncounterType *)encounterType;
@end

@interface SelectEncounterTypeView : UITableViewController
@property (nonatomic, strong) NSObject<SelectEncounterTypeViewDelegate> *delegate;
@property (nonatomic, strong) NSArray *encounterTypes;
@end
