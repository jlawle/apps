/*
//  CKManager.m
//  watchLog WatchKit Extension
//  Created by John Lawler on 2/19/22.
 
 Provides implementation for record creation, updating, and retrieval functionality
*/

#import <Foundation/Foundation.h>
#import "CKManager.h"
#import <CloudKit/CloudKit.h>

@implementation CKManager

// Returns pointer to the public cloud database
+ (CKDatabase *)publicCloudDatabase {
    return [[CKContainer defaultContainer] publicCloudDatabase];
}




// Create record
// - recordID type should be Date_Time


@end
