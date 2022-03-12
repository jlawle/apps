//
//  InterfaceController.swift
//  dataLogger WatchKit Extension
//
//  Created by John Lawler on 2/28/22.
//

import WatchKit
import Foundation
import CloudKit


class InterfaceController: WKInterfaceController {
    // Declare file utilities
    let fileUtils = FileUtils()
    let ckutils = CKUtils()
    
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        testFileUpload()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    
    
    
    // Test an icloud Record upload
    func testFileUpload() {
       // Get time
        let timeStr = getTime()
        let filename = "FileWithTime"
        let fileDataStr = String(format: "%@%@", "The current time: ", timeStr)
        print(fileDataStr)
        
        // Save file with given text string to documents directory
        _ = fileUtils.save(text: fileDataStr,
                       toDirectory: fileUtils.documentDirectory(),
                       withFileName: filename)
        

        
        // Create Record for new file
        let record = ckutils.createRecord(Type: "Motion",
                                          ID: timeStr )
        

        // Save record with file given corresponding pathurl
        ckutils.saveRecord(filename: filename,
                           time: getTime(),
                           record: record)
        
         // PErformed in saveRecord()
//        // Set the corresponding record ID to current time
//        //record.recordID = timeStr
//        record.setValuesForKeys([
//            "Time": getTime()
//        ])
        
//        // Set up container
//        //let container = CKContainer.default()
//        let container = CKContainer(identifier: "iCloud.com.Hoover.watchLog.watchkitapp.watchkitextension")
//
//        let database = container.publicCloudDatabase
        
        
        
        // Check account status, handle gracefully
//        container.accountStatus { accountStatus, error in
//            // Handle for if user has no account
//            if accountStatus == .noAccount {
//              print("Account Status >> No account found")
//            }
//            else {
//                // Save your record here.
//                // Check if record exists already (fetchRecord)
//
//                database.save(record, completionHandler: { record, error in
//                    if let saveError = error {
//                            print("An error occurred in \(saveError)")
//                        } else {
//                            // Saved record
//                            print("Saved?")
//                        }
//                })
//            }
//        }
    }
    
    // Retrieve date and time
    func getTime() -> String {
        // get the current date and time
        let currentDateTime = Date()

        // initialize the date formatter and set the style
        let formatter = DateFormatter()

        // get the date time String from the date object
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        let str = formatter.string(from: currentDateTime)
    
        return str
    }
   
}
