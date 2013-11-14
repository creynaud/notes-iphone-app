//
//  KNStore.m
//  KeepANote
//
//  Created by Claire Reynaud on 11/12/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import "KNStore.h"

@interface KNStore()

@property (strong) NSManagedObjectContext *context;

@end

@implementation KNStore

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.context = context;
    }
    return self;
}

- (KNNote *)fetchNoteWithUUID:(NSString *)uuid {
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
    [request setPredicate:predicate];
    NSArray *array = [self.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error on fetch note with uuid %@, %@: %@", uuid, error, [error userInfo]);
        return nil;
    } else {
        return [array firstObject];
    }
}

- (NSArray *)fetchNotesWithState:(KNNoteState)state {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == %@", [NSNumber numberWithInteger:state]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [self.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error on fetch notes with state %d, %@: %@", state, error, [error userInfo]);
        return [NSArray array];
    } else {
        return array;
    }
}

- (void)deleteNote:(KNNote *)note {
    [self.context deleteObject:note];
}

- (KNNote *)createNote {
    return (KNNote *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.context];
}

- (void)saveContext {
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Unresolved error while saving NSManagedObjectContext %@, %@", error, [error userInfo]);
    }
}

@end
