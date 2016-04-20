//
//  MRSEncounterOb.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/5/14.
//

#import <Foundation/Foundation.h>

@interface MRSEncounterOb : NSObject <NSCoding>
@property (nonatomic, strong) NSString *display;
@property (nonatomic, strong) NSString *encounterDisplay;
@property (nonatomic, strong) NSString *UUID;
@end
