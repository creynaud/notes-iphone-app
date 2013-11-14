//
//  KNNote.h
//  KeepANote
//
//  Created by Claire Reynaud on 10/20/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, KNNoteState) {
    KNNoteStateModified,
    KNNoteStateUpToDate,
    KNNoteStateDeleted
};

#define NOTE_UUID @"uuid"
#define NOTE_REVISION @"revision"
#define NOTE_TITLE @"title"
#define NOTE_TEXT @"text"
#define NOTE_DATE @"date"

@interface KNNote : NSManagedObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)toDictionary;

- (void)setFromDictionary:(NSDictionary *)dictionary;
- (void)solveConflict:(NSDictionary *)dictionary;

@property NSString *uuid;
@property NSString *revision;
@property NSString *title;
@property NSString *text;
@property NSNumber *state;
@property NSDate *date;

@end
