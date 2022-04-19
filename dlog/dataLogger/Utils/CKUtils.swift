//
//  CKUtils.swift
//  dataLogger WatchKit Extension
//  CKUtils provides helper functions for creating/uploading
//  a record to cloudkit using CK framework.
//
//  Created by John Lawler on 3/11/22.
//

import Foundation
import CloudKit

class CKUtils {
    let fileUtils = FileUtils()
    var container: CKContainer
    var database: CKDatabase
    
    
    init(){
        // Initialize our container to our identifer
        self.container = CKContainer(identifier: Config.containerIdentifier)
        
        // Set up database to point to public
        self.database = container.publicCloudDatabase
    }
    
    
    // Intitialize a new cloudkit record with provided type and ID
    func createRecord(Type: String, ID: String) -> CKRecord {
        log.info("Generating new record of type \(Type) with ID \(ID)")
        return CKRecord.init(recordType:    Type,
                             recordID:      CKRecord.ID(recordName: ID))
    }
    
    // Fetch user's iCloud ID
    func fetchUserID(container: CKContainer) -> String? {
        var userID: String?
        self.container.fetchUserRecordID(completionHandler: {(recordID, error) in
            // If recordID exists, save it
            if let name = recordID?.recordName {
                log.info("iCloud ID: \(name)")
                userID = name
            }
            // Handle errors
            else if let error = error {
                log.error("\(String(describing: error.localizedDescription))")
            }
        })
        return userID
    }
    
    // Uploads a record to cloudkit with file path, timestamp and CKRecord
    func saveRecord(filename: String, time: String, record: CKRecord) {
        let asset: CKAsset
        
        // Check if file exists at url
        if fileUtils.checkFile(name: filename) {
            log.info("File \(filename) found")
        } else {
            log.error("File \(filename) not found!")
        }
    
        // Create url to documents directory
        let fileurl = NSURL(fileURLWithPath: fileUtils.documentDirectory())
        
        // Append file path to url and create asset if exists
        if let urlPath = fileurl.appendingPathComponent(filename){
            // Generate cloudkit asset to store file
            asset = CKAsset(fileURL: urlPath)
        } else {
            print("Path unavailable")
            return
        }
        
        // Set the record values, stores time and file data to record object
        record.setValuesForKeys(["Time": time, "File": asset, "Filename": filename])
        
        // Check account status, handle gracefully
        self.container.accountStatus { accountStatus, error in
            switch accountStatus {
            case .available:
                log.info("Account status available")
                
                // Check if record already exists
                // ....
                
                // Save record to public database
                self.database.save(record, completionHandler: { record, error in
                    if let saveError = error {
                        log.error("Error saving record: \(saveError)")
                    } else {
                        // Saved record
                        log.info("Record saved. Record info: \(String(describing: record))")
                        }
                })
            case .couldNotDetermine:
                log.info("Cannot determine account status")
            case .restricted:
                log.info("Account status restricted")
            case .noAccount:
                log.info("No iCloud account found!")
            case .temporarilyUnavailable:
                log.info("Account status temporarily unavailable.")
            @unknown default:
                fatalError("Error verifying account status: \(String(describing: error))")
            }
        }
    }
}
    
