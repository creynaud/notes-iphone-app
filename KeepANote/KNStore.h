//
//  KNStore.h
//  KeepANote
//
//  Created by Claire Reynaud on 11/12/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNNote.h"

@interface KNStore : NSObject

- (id)initWithContext:(NSManagedObjectContext *)context;

- (KNNote *)fetchNoteWithUUID:(NSString *)uuid;
- (NSArray *)fetchNotesWithState:(KNNoteState)state;

- (KNNote *)createNote;
- (void)deleteNote:(KNNote *)note;

- (void)saveContext;

@end
