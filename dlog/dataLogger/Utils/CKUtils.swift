//
//  CKUtils.swift
//  dataLogger WatchKit Extension
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
    
    
    // Simple fcn for creating and returing a new record
    func createRecord(Type: String, ID: String) -> CKRecord {
        // Initialize record with type and ID
        return CKRecord.init(recordType:    Type,
                             recordID:      CKRecord.ID(recordName: ID))
    }
    
    // Function to save data to a record given key and data
    func saveRecord(filename: String, time: String, record: CKRecord) {
        let asset: CKAsset
        
        // Check if file exists at url
        if fileUtils.checkFile(name: filename) {
            print("The file exists")
        } else {
            print("The file does not exist! ")
            return
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
        
        
        // Set the record values
        record.setValuesForKeys(["Time": time, "File": asset])
        
        // Check account status, handle gracefully
        self.container.accountStatus { accountStatus, error in
            // Handle for if user has no account
            if accountStatus == .noAccount {
              print("Account Status >> No account found")
            }
            else {
                // Save your record here.
                // TODO: Check if record exists already (fetchRecord)
                
                
                
                // Save record to public database
                self.database.save(record, completionHandler: { record, error in
                    if let saveError = error {
                            print("An error occurred in \(saveError)")
                        } else {
                            // Saved record
                            print("Saved?")
                        }
                })
            }
        }
    }
    
    
    
}
