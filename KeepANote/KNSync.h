//
// Created by Claire Reynaud on 10/18/13.
// Copyright (c) 2013 Claire Reynaud. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "KNRestClient.h"
#import "KNStore.h"

#define KNSyncDone @"SyncDone"

@interface KNSync : NSObject

- (id)initWithRestClient:(KNRestClient *)restClient store:(KNStore *)store;
+ (KNSync *)synchronizer;

- (void)syncWithServer;

@end