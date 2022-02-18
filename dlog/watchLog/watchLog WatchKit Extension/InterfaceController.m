//
//  InterfaceController.m
//  watchLog WatchKit Extension
//
//  Created by Cameron Burroughs on 2/7/22.
//

#import "InterfaceController.h"
#import <CloudKit/CloudKit.h>




@interface InterfaceController ()

@end


@implementation InterfaceController
- (void)getiCloudStatus {
/*    printf("filler for now");
    CKDatabase *publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
    CKContainer.defaultContainer.accountStatusWithCompletionHandler(CKAccountStatus accountStatus, NSError * _Nullable error) {
        // code
        printf("heRE");
    };*/
    
    
}

- (void)awakeWithContext:(id)context {
    // Configure interface objects here.
    // Create string with date/time
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
    [formatDate setDateFormat:@"yyyy-MM-dd"]; //removed time temporarily capital HH gives 24-hour time format, hh is 12-hour, no AM/PM
    NSDateFormatter *formatTime = [[NSDateFormatter alloc] init];
    [formatTime setDateFormat:@"HH:mm:ss"];
    

    
    NSString *dateString = [formatDate stringFromDate:currentDate];
    NSString *timeString = [formatTime stringFromDate:currentDate];
    NSLog(@"Record Name: %@", dateString);
    // Create record ID using timeStamp
    // NOTE: currently recordID is date & time, may want to change to date, add time to record information
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName: dateString];
    
    // Create CloudKit Record
    CKContainer *container = CKContainer.defaultContainer;  //NOT SURE IF THIS IS RIGHT
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Motion" recordID:recordID];
    [record setObject:timeString forKey:@"Time"];
    
    CKDatabase *database = container.publicCloudDatabase;
    NSLog(@"Record: %@", record);
    NSLog(@"Container: %@", container);
    NSLog(@"Database: %@", database);
    //save record
    [database saveRecord:record completionHandler:^(CKRecord *recordRet, NSError *error) {
         NSLog(@"Record after save attempt: %@", recordRet);
    }];
    
 
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
}

@end



