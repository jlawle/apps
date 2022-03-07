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

    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    
    
    
    // Test an icloud Record upload
    func testUpload() {
        
        // Initialize record with type
        let record = CKRecord(recordType: "Motion")
        
        // Set the corresponding record ID to current time
        record.recordID = getTime()
        record.setValuesForKeys([
            "Time": getTime()
        ])
        
        // Set up container
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        
        
        
        // Check account status, handle gracefullu
        CKContainer.default().accountStatus { accountStatus, error in
            if accountStatus == .noAccount {
                DispatchQueue.main.async {
                    let message =
                        """
                        Sign in to your iCloud account to write records.
                        On the Home screen, launch Settings, tap Sign in to your
                        iPhone/iPad, and enter your Apple ID. Turn iCloud Drive on.
                        """
                    let alert = UIAlertController(
                        title: "Sign in to iCloud",
                        message: message,
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
                }
            }
            else {
                // Save your record here.
            }
        }
        
        
        
    }
    
    // Retrieve date and time
    func getTime() -> NSString {
        // get the current date and time
        let currentDateTime = Date()

        // initialize the date formatter and set the style
        let formatter = DateFormatter()

        // get the date time String from the date object
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        str = formatter.string(from: currentDateTime)
        
        print(str)
        return str
    }
}
