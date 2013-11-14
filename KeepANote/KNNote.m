//
//  KNNote.m
//  KeepANote
//
//  Created by Claire Reynaud on 10/20/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import "KNNote.h"
#import "KNDateUtils.h"

@implementation KNNote

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.uuid = [dictionary valueForKey:NOTE_UUID];
        self.revision = [dictionary valueForKey:NOTE_REVISION];
        self.title = [dictionary valueForKey:NOTE_TITLE];
        self.text = [dictionary valueForKey:NOTE_TEXT];
        self.date = [KNDateUtils dateFromIsoString:[dictionary valueForKey:NOTE_DATE]];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *noteJSON = [NSMutableDictionary dictionary];
    [noteJSON setValue:self.uuid forKey:NOTE_UUID];
    [noteJSON setValue:self.title forKey:NOTE_TITLE];
    [noteJSON setValue:self.text forKey:NOTE_TEXT];
    [noteJSON setValue:[KNDateUtils isoStringFromDate:self.date] forKey:NOTE_DATE];
    if (self.revision != nil) {
        [noteJSON setValue:self.revision forKey:NOTE_REVISION];
    }
    return noteJSON;
}

- (void)setFromDictionary:(NSDictionary *)dictionary {
    self.uuid = [dictionary valueForKey:NOTE_UUID];
    self.revision = [dictionary valueForKey:NOTE_REVISION];
    self.title = [dictionary valueForKey:NOTE_TITLE];
    self.text = [dictionary valueForKey:NOTE_TEXT];
    self.state = [NSNumber numberWithInteger:KNNoteStateUpToDate];
    self.date = [KNDateUtils dateFromIsoString:[dictionary valueForKey:NOTE_DATE]];
}

- (void)solveConflict:(NSDictionary *)noteJSON {
    NSString *localTitle = self.title;
    NSString *localText = self.text;
    NSString *remoteTitle = [noteJSON valueForKey:NOTE_TITLE];
    NSString *remoteText = [noteJSON valueForKey:NOTE_TEXT];
    self.title = [NSString stringWithFormat:@"Conflict: %@", localTitle];
    if (![localTitle isEqualToString:remoteTitle]) {
        self.title = [NSString stringWithFormat:@"Conflict: %@ vs %@", localTitle, remoteTitle];
    }
    if (![localText isEqualToString:remoteText]) {
        self.text = [NSString stringWithFormat:@"Local text: %@\n\nRemote text: %@", localText, remoteText];
    }
    self.date = [NSDate date];
    self.revision = [noteJSON valueForKey:NOTE_REVISION];
    self.state = KNNoteStateModified;
}

@dynamic uuid;
@dynamic revision;
@dynamic title;
@dynamic text;
@dynamic date;
@dynamic state;

@end
