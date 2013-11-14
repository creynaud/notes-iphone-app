//
//  KNRestClient.m
//  KeepANote
//
//  Created by Claire Reynaud on 11/8/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import "KNRestClient.h"
#import "AFNetworking.h"

#define BASE_URL_STRING @"http://localhost:8000/api"

@interface KNRestClient()

@property (strong) AFHTTPRequestOperationManager *manager;

@end

@implementation KNRestClient

- (id)initWithManager:(AFHTTPRequestOperationManager *)manager
{
    self = [super init];
    if (self) {
        self.manager = manager;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:BASE_URL_STRING];
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *string = @"claire:test";
        NSString *base64EncodedString = [[string dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        [serializer setValue:[NSString stringWithFormat:@"Basic %@", base64EncodedString] forHTTPHeaderField:@"Authorization"];

        [self.manager setRequestSerializer:serializer];
        // JSON response serializer is the default, but let it be explicit
        [self.manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    }
    return self;
}

- (void)getAllNoteUuidsWithSuccess:(void (^)(NSArray *uuidAndRevisions))success failure:(void (^)(NSError *error))failure {
    NSString *notesURL = [NSString stringWithFormat:@"%@/notes-uuids/", BASE_URL_STRING];
    [self.manager GET:notesURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *array = (NSArray *)responseObject;
        NSMutableArray *uuidAndRevisions = [NSMutableArray array];
        for (NSDictionary *noteJSON in array) {
            NSDictionary *noteUUIDAndRevision = @{NOTE_UUID: [noteJSON valueForKey:NOTE_UUID], NOTE_REVISION: [noteJSON valueForKey:NOTE_REVISION]};
            [uuidAndRevisions addObject:noteUUIDAndRevision];
        }
        success(uuidAndRevisions);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error getting all note uuids: %@", error);
        failure(error);
    }];
}

- (AFHTTPRequestOperation *)getNoteOperation:(NSString *)uuid {
    NSString *noteURL = [NSString stringWithFormat:@"%@/notes/%@/", BASE_URL_STRING, uuid];
    NSURLRequest *request = [self.manager.requestSerializer requestWithMethod:@"GET" URLString:noteURL parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    return operation;
}

- (AFHTTPRequestOperation *)postOrPutNoteOperation:(KNNote *)note {
    NSString *URLString = [NSString stringWithFormat:@"%@/notes/", BASE_URL_STRING];
    NSString *method = @"POST";
    if (note.revision != nil) {
        URLString = [NSString stringWithFormat:@"%@/notes/%@/", BASE_URL_STRING, note.uuid];
        method = @"PUT";
    }
    NSDictionary *noteJSON = [note toDictionary];
    NSURLRequest *request = [self.manager.requestSerializer requestWithMethod:method URLString:URLString parameters:noteJSON];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    return operation;
}

- (AFHTTPRequestOperation *)deleteNoteOperation:(KNNote *)note {
    NSString *urlString = [NSString stringWithFormat:@"%@/notes/%@/?revision=%@", BASE_URL_STRING, note.uuid, note.revision];
    NSURLRequest *request = [self.manager.requestSerializer requestWithMethod:@"DELETE" URLString:urlString parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    return operation;
}

@end
