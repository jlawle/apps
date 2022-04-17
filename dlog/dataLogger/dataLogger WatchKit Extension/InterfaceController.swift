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
        fileUtils.deleteFile(withPath: filePath)
    }
    
    @IBAction func recordButtonPressed() {
        if(!logging) {
            print("Start log button press")
            // code to execute after "START LOG" button is pressed
            logButton.setTitle("STOP LOG")
            logButton.setBackgroundColor(UIColor.red)
            logging = true
            
            // sends function to execute on seperate thread, allowing button to update
            // basically, without this, button won't change til after all logging is done
            logThread.async {
                self.startLogging()
            }
            
        } else {
            print("Stop log button press")
            // code to execute after "STOP LOG" button is pressed
            logButton.setTitle("START LOG")
            logButton.setBackgroundColor(UIColor.green)
            logging = false
            
            // sends function to seperate thread, allowing button to update.
            logThread.async {
                self.stopLogging()
            }
            
        }
    }
    
    func startLogging() {
        print("Starting logging")
        
        //  Create filename from Date, will be MM-dd-YYYY.csv
        let dateString = cmutils.getDate()
        fileName = dateString + ".csv"
        
        // Create file in directory, get path of file
        filePath = fileUtils.getPath(inDirectory: fileUtils.documentDirectory(), withFileName: fileName)
        
        // Start sending updates to file
        cmutils.startUpdates(sendTo: filePath)
    }
    
    func stopLogging() {
        print("Stopping Logging")
        
        // Stop updating the file
        cmutils.stopUpdates()
        
        // create record ID from date & time
        var recordID = cmutils.getDate()
        recordID.append(" \(cmutils.getTime())")
        
        // Create & save record
        ckutils.saveRecord(filename: fileName, time: cmutils.getTime(), record: ckutils.createRecord(Type: "Motion", ID: recordID))
    }
    
    
    // CAN BE DELETED, added different versions [getDate() and getTime() to CMUtils]
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
