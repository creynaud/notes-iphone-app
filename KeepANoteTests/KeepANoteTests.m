//
//  KeepANoteTests.m
//  KeepANoteTests
//
//  Created by Claire Reynaud on 10/17/13.
//  Copyright (c) 2013 Claire Reynaud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "KNSync.h"

@interface KeepANoteTests : XCTestCase

@property (strong) NSManagedObjectModel *model;
@property (strong) NSPersistentStoreCoordinator *coordinator;
@property (strong) NSPersistentStore *store;
@property (strong) NSManagedObjectContext *context;
@property (strong) KNRestClient *restClient;
@property (strong) KNSync *synchronizer;

@end

@implementation KeepANoteTests

- (void)setUp
{
    [super setUp];
    
    self.model = [NSManagedObjectModel mergedModelFromBundles: nil];

    self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];

    self.store = [self.coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    self.context = [[NSManagedObjectContext alloc] init];
    [self.context setPersistentStoreCoordinator:self.coordinator];
    
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatEnvironmentWorks
{
    XCTAssertNotNil(self.store, @"no persistent store");
}

@end
