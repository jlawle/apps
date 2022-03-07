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
  // NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatDate = [[NSDateFormatter alloc] init];
    [formatDate setDateFormat:@"yyyy-MM-dd"]; //removed time temporarily capital HH gives 24-hour time format, hh is 12-hour, no AM/PM
    NSDateFormatter *formatTime = [[NSDateFormatter alloc] init];
    [formatTime setDateFormat:@"HH:mm:ss"];
    
    //create hello world file + url to file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/HelloWorld.txt", documentsDir];
    NSString *data = @"Hello World!\n";
    [data writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    NSLog(@"DocPath: %@", documentsDir);
    
    NSURL *url = [NSURL fileURLWithPath:fileName];
    CKAsset *myFileAsset = [[CKAsset alloc] initWithFileURL:url];
    NSLog(@"url: %@", url);
    
    NSString *dateString = [formatDate stringFromDate:currentDate];
    NSString *timeString = [formatTime stringFromDate:currentDate];
    dateString = [dateString stringByAppendingString:timeString];
    NSLog(@"Record Name: %@", dateString);
    // Create record ID using timeStamp
    // NOTE: currently recordID is date & time, may want to change to date, add time to record information
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName: dateString];
    
    // Create CloudKit Record
    CKContainer *container = [CKContainer defaultContainer];  //NOT SURE IF THIS IS RIGHT
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Motion" recordID:recordID];
    [record setObject:timeString forKey:@"Time"];
    [record setObject:myFileAsset forKey:@"File"];
    
    CKDatabase *database = [container publicCloudDatabase];
    NSLog(@"Record: %@", record);
   // NSLog(@"Container: %@", container);
   // NSLog(@"Database: %@", database);
    //save record
<<<<<<< HEAD:dlog/watchLog/watchLog WatchKit Extension/InterfaceController.m
    [database saveRecord:record completionHandler:^(CKRecord *recordRet, NSError *error) {
       //  NSLog(@"Record after save attempt: %@", recordRet);
=======
    
    // Check if Fetchable record
//    [database fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
//        NSLog(@"Account status: %@, error: %@", record, error);
//
//        [record setObject:timeString forKey:@"Time"];
//
//        [database saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
//            NSLog(@"Record after save attempt: %@, %@", record, error);
//        }];
//
//    }];
           
    
//    // check account status
//    [container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
//        //Here goes your code to handle the account status
//        NSLog(@"Account status: %ld, error: %@", (long)accountStatus, error);
//    }];
    
    // Save Record manually
    [database saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
        NSLog(@"Record after save attempt: %@, %@", record, error);
>>>>>>> 6267a47... simple record upload with date-time string as name:dlog/watchLog/watchLog WatchKit Extension/Controllers/InterfaceController.m
    }];
    
 
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
}

@end


