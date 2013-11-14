//
//  KNRestClient.h
//  KeepANote
//
//  Created by Claire Reynaud on 11/8/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNNote.h"
#import "AFNetworking.h"

@interface KNRestClient : NSObject

- (id)initWithManager:(AFHTTPRequestOperationManager *)manager;

- (void)getAllNoteUuidsWithSuccess:(void (^)(NSArray *uuidAndRevisions))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)getNoteOperation:(NSString *)uuid;
- (AFHTTPRequestOperation *)postOrPutNoteOperation:(KNNote *)note;
- (AFHTTPRequestOperation *)deleteNoteOperation:(KNNote *)note;

@end
