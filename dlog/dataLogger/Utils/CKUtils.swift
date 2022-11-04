//
//  CKUtils.swift
//  dataLogger WatchKit Extension
//
//  Created by John Lawler on 3/11/22.
//

import Foundation
import CloudKit

// CKUtils implements creating/uploading of record to iCloud
class CKUtils {
    typealias FinishedUpload = () -> ()
    let fileUtils = FileUtils()
    var container: CKContainer
    var database: CKDatabase
    
    
    init(){
        // Initialize our container to our identifer
        self.container = CKContainer(identifier: Config.containerIdentifier)
        
        // Set up database to point to public
        self.database = container.privateCloudDatabase
    }
    
    
    // Intitialize a new cloudkit record with provided type and ID
    func createRecord(Type: String, ID: String) -> CKRecord {
        log.info("Generating new record of type \(Type) with ID \(ID)")
        return CKRecord.init(recordType:    Type,
                             recordID:      CKRecord.ID(recordName: ID))
    }
    
    // Generate a new record filename to save to a record field
    func generateRecordFileName() -> String {
        
        // Retrieve current Time and Date
        let time = getTime(ms: false)
        let currentDate = getDate()
        
        // Retrieve unique user ICloud ID
        let recordData = requestUserID()
        // Format filename as DATE_TIME_USERID.csv
        return currentDate + "_" + time + recordData.0 + ".csv"
    }
    
    
    // Uploads a record to cloudkit with file path, timestamp and CKRecord
    func saveRecord(record: CKRecord, completion: FinishedUpload) {
        let container = CKContainer(identifier: Config.containerIdentifier)
        let filename = Config.CSVFilename
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
            log.info("urlPath cannot append with url: \(fileurl). filename: \(filename)")
            fatalError("Path unavailable")
        }
        
        // Set the record values, stores time and file data to record object
        record.setValuesForKeys(["Time": getTime(ms: false),
                                 "File": asset,
                                 "Filename": self.generateRecordFileName()])
        
        // Check account status, handle gracefully
        container.accountStatus { accountStatus, error in
            switch accountStatus {
            case .available:
                log.info("Account status available")
                
                // Check if record already exists
                // Currently generates unique record each time, no need for check yet
                // ....
                
                // Save record to public database
                self.database.save(record, completionHandler: { record, error in
                    if let saveError = error {
                        log.error("Error saving record: \(saveError)")
                    } else {
                        // Saved record
                        log.info("Record saved. Record info: \(String(describing: record))")
                        
                        // Delete temporary csv file from watch directory
                        log.info("Removing file from watch...")
                        FileUtils().deleteFile(filename: Config.CSVFilename)
                        
                        // Verify file was deleted
                        _ = FileUtils().checkFile(name: Config.CSVFilename)
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
        completion()
    }
}
    
