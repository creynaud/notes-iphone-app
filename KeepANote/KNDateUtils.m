//
//  KNDateUtils.m
//  KeepANote
//
//  Created by Claire Reynaud on 10/21/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import "KNDateUtils.h"

@implementation KNDateUtils

+ (NSDateFormatter *)localeDateFormatter
{
	static NSDateFormatter *dateFormatter;
    
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDoesRelativeDateFormatting:YES];
    });
    
    return dateFormatter;
}

+ (NSDateFormatter *)isoDateFormatter
{
    static NSDateFormatter *dateFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    });
    
    return dateFormatter;
}

+ (NSString *)localizedStringFromDate:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *localeDateFormatter = [KNDateUtils localeDateFormatter];
    localeDateFormatter.dateStyle = dateStyle;
    localeDateFormatter.timeStyle = timeStyle;
    return [localeDateFormatter stringFromDate:date];
}

+ (NSString *)shortLocalizedStringFromDate:(NSDate *)date {
    return [KNDateUtils localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

+ (NSDate *)dateFromIsoString:(NSString *)dateString {
    return [[KNDateUtils isoDateFormatter] dateFromString:dateString];
}

+ (NSString *)isoStringFromDate:(NSDate *)date {
    return [[KNDateUtils isoDateFormatter] stringFromDate:date];
}

@end
