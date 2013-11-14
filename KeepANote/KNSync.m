//
// Created by Claire Reynaud on 10/18/13.
// Copyright (c) 2013 Claire Reynaud. All rights reserved.
//


#import "KNSync.h"
#import "AFNetworking.h"
#import "KNAppDelegate.h"
#import "KNNote.h"
#import "KNDateUtils.h"
#import "KNRestClient.h"

#import <CoreData/CoreData.h>

#define BASE_URL_STRING @"https://awesomenotes.herokuapp.com/api"

@interface KNSync()

@property (strong) KNRestClient *restClient;
@property (strong) KNStore *store;

@end

@implementation KNSync

- (id)initWithRestClient:(KNRestClient *)restClient store:(KNStore *)store
{
    self = [super init];
    if (self) {
        self.restClient = restClient;
        self.store = store;
    }
    return self;
}

+ (KNSync *)synchronizer;
{
	static KNSync *sync;
    
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        KNRestClient *restClient = [[KNRestClient alloc] init];
        NSManagedObjectContext *context = ((KNAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
        KNStore *store = [[KNStore alloc] initWithContext:context];
        sync = [[KNSync alloc] initWithRestClient:restClient store:store];
    });
    
    return sync;
}

- (void)getNotes:(NSArray *)uuidAndRevisions completion:(void (^)(void))completionBlock {
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (NSDictionary *uuidAndRevision in uuidAndRevisions) {
        NSString *uuid = [uuidAndRevision valueForKey:NOTE_UUID];
        NSString *revision = [uuidAndRevision valueForKey:NOTE_REVISION];
        KNNote *note = [self.store fetchNoteWithUUID:uuid];
        if (note == nil || ![note.revision isEqualToString:revision]) {
            AFHTTPRequestOperation *operation = [self.restClient getNoteOperation:uuid];
            [mutableOperations addObject:operation];
        }
    }
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"GET notes %d of %d complete", numberOfFinishedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"All GET operations in batch complete");
        dispatch_async(dispatch_get_main_queue(), ^{
            for (AFHTTPRequestOperation *operation in operations) {
                NSDictionary *noteJSON = (NSDictionary *)operation.responseObject;
                NSString *uuid = [noteJSON valueForKey:NOTE_UUID];
                KNNote *note = [self.store fetchNoteWithUUID:uuid];
                if (note) {
                    if (note.state == [NSNumber numberWithInteger:KNNoteStateModified]) {
                        [note solveConflict:noteJSON];
                    } else {
                        [note setFromDictionary:noteJSON];
                    }
                } else {
                    KNNote *newNote = [self.store createNote];
                    [newNote setFromDictionary:noteJSON];
                }
            }
            [self.store saveContext];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionBlock();
            });
        });
    }];
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

- (void)postNewOrUpdatedNotesWithCompletion:(void (^)(void))completionBlock {
    NSArray *array = [self.store fetchNotesWithState:KNNoteStateModified];
    
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (KNNote *note in array) {
        AFHTTPRequestOperation *operation = [self.restClient postOrPutNoteOperation:note];
        [mutableOperations addObject:operation];
    }
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"POST/PUT notes %d of %d complete", numberOfFinishedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"All POST/PUT operations in batch complete");
        dispatch_async(dispatch_get_main_queue(), ^{
            for (AFHTTPRequestOperation *operation in operations) {
                NSDictionary *noteJSON = operation.responseObject;
                KNNote *note = [self.store fetchNoteWithUUID:[noteJSON valueForKey:NOTE_UUID]];
                [note setFromDictionary:noteJSON];
            }
            [self.store saveContext];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionBlock();
            });
        });
    }];
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

- (void)deleteNotesWithCompletion:(void (^)(void))completionBlock {
    NSArray *array = [self.store fetchNotesWithState:KNNoteStateDeleted];
    
    NSMutableArray *mutableOperations = [NSMutableArray array];
    for (KNNote *note in array) {
        AFHTTPRequestOperation *operation = [self.restClient deleteNoteOperation:note];
        operation.userInfo = @{NOTE_UUID: note.uuid};
        [mutableOperations addObject:operation];
    }
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"DELETE note %d of %d complete", numberOfFinishedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"All DELETE operations in batch complete");
        dispatch_async(dispatch_get_main_queue(), ^{
            for (AFHTTPRequestOperation *operation in operations) {
                NSString *uuid = [operation.userInfo valueForKey:NOTE_UUID];
                KNNote *note = [self.store fetchNoteWithUUID:uuid];
                [self.store deleteNote:note];
            }
            [self.store saveContext];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionBlock();
            });
        });
    }];
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

- (void)syncWithServer {
    [self.restClient getAllNoteUuidsWithSuccess:^(NSArray *uuids) {
        NSLog(@"\n");
        NSLog(@"GET note UUIDs and revisions complete");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // TODO delete notes that do not exist anymore
            [self getNotes:uuids completion:^{
                [self postNewOrUpdatedNotesWithCompletion:^{
                    [self deleteNotesWithCompletion:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:KNSyncDone object:nil];
                        });
                    }];
                }];
            }];
        });
    } failure:^(NSError *error) {
        NSLog(@"Error on get all note UUIDs: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:KNSyncDone object:nil];
        });
    }];
}

@end