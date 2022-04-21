//
//  InterfaceController.swift
//  dataLogger WatchKit Extension
//
//  Created by John Lawler on 2/28/22.
//

import WatchKit
import Foundation
import CloudKit
import CoreMotion

class InterfaceController: WKInterfaceController {
    
    // Declare button variables
    @IBOutlet var logButton: WKInterfaceButton!
    
    // Declare file utilities
    let fileUtils = FileUtils()
    let ckutils = CKUtils()
    let cmutils = CMUtils()
    let logThread = DispatchQueue(label: "BackgroundThread", qos: .background)
    
    
    var logging: Bool = false   // Boolean to determine button state
    var filePath: String = ""
    var fileName: String = ""
    
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    @IBAction func deleteTempButtonPressed() {
        // deletes whatever file was made that date from documents directory
        // press AFTER file has been uploaded to cloudkit, this is a temp utility
        // function so we do not overcrowd the documents directory
        //fileUtils.deleteFile(withPath: filePath)
    }
    
    @IBAction func recordButtonPressed() {
        if(!logging) {
            
            // Code to execute after "START LOG" button is pressed
            log.info("Start log button pressed")
            logButton.setTitle("STOP LOG")
            logButton.setBackgroundColor(UIColor.red)
            logging = true
            
            // Execute fcn on seperate thread s.t. button to updates its color
            logThread.async {
                self.startLogging()
            }
            
        } else {
            
            // Code to execute after "STOP LOG" button is pressed
            log.info("Stop log button pressed")
            logButton.setTitle("START LOG")
            logButton.setBackgroundColor(UIColor.green)
            logging = false
            
            // Sends function to seperate thread, allowing button to update.
            logThread.async {
                self.stopLogging()
            }
            
        }
    }
    
    func startLogging() {
        log.info("Starting logging ...")
        
        // Start sending updates to file
        cmutils.startUpdates(filename: Config.CSVFilename)
    }
    
    func stopLogging() {
        log.info("Stopping logging ...")
        
        // Stop updating the file
        cmutils.stopUpdates()
        
        // create record ID from date & time
        var recordID = getDate()
        recordID.append("_\(getTime(ms: false))")
        
        // Create & save record
        ckutils.saveRecord(record: ckutils.createRecord(Type: "Motion",ID: recordID), completion: {() -> () in
                // Delete our file in documents directory
                //fileUtils.deleteFile(filename: Config.CSVFilename)
        })
    }
   
}
