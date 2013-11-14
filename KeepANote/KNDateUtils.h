//
//  KNDateUtils.h
//  KeepANote
//
//  Created by Claire Reynaud on 10/21/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNDateUtils : NSObject

+ (NSString *)localizedStringFromDate:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
+ (NSString *)shortLocalizedStringFromDate:(NSDate *)date;

+ (NSDate *)dateFromIsoString:(NSString *)dateString;
+ (NSString *)isoStringFromDate:(NSDate *)date;

@end
