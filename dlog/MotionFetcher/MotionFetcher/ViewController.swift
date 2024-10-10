//
//  ViewController.swift
//  MotionFetcher
//
//  Created by John Lawler on 5/7/22.
//

import Cocoa
import CloudKit

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    var selectedItem: Int?
    var files: [CKRecord] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load our table data
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = false
    }
    

    // Function recieves file data and writes to file on host machine in Documents directory
    private func writeFile (data: String, filename: String) {
        var isDir: ObjCBool = true //needed to create new directory
        let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("MotionFetcher")
        let fileURL = appDir.appendingPathComponent(filename)

        // Verify path exists to write data
        if !FileManager.default.fileExists(atPath: appDir.path, isDirectory: &isDir) {
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        }

        // Attempt to write data to url
        do {
            try data.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch {
            print("Error: \(error)")
        }
    }
    

    // Downloads record from database to computer
    @IBAction func DownloadEntry(_ sender: Any) {
        print("Downloading item at row: ", selectedItem ?? "nil")
        
        // Proceed to download item at the row location
        if let row = selectedItem, row != -1 {
            let file = files[selectedItem!]
            if let asset = file["File"] as? CKAsset {
                if let url = asset.fileURL, let data = try? String(contentsOf: url){
                    writeFile(data: data, filename: file["Filename"] as! String)
                }
            }
            
            // Return to a state of no selection
            selectedItem = -1
        } else {
            // Don't attempt to fetch a file, user needs to select a row
            print("sekected item is nil or no row selected")
        }
    }
    
    
    // Deletes a record from the database
    @IBAction func DeleteEntry(_ sender: Any) {
        print("Deleting item at row: ", selectedItem ?? "nil")
        
        if let row = selectedItem, row != -1 {
            let file = files[selectedItem!]
            // Call handler to remove record from database
            deleteRecordWithID(file.recordID) { recordID, error in
                if (error != nil) {
                    print("Error deleting record:", error!)
                }
            }
            
            // Remove file from our list of records
            files.remove(at: selectedItem!)
            
            // Return to a state of no selection
            selectedItem = -1
            
            // reload table data
            tableView.reloadData()
        } else {
            print("selected item is nil")
        }
    }
    
    // Handler to call to remove record from cloudkit database
    func deleteRecordWithID(_ recordID: CKRecord.ID, completion: ((_ recordID: CKRecord.ID?, _ error: Error?) -> Void)?) {

        CKModel().database.delete(withRecordID: recordID) { (recordID, error) in
            completion?(recordID, error)
        }
    }
    
    
    // Button loads icloud records into a global array storing the record data
    @IBAction func FetchRecords(_ sender: Any) {
        print("Loading iCloud records...")
        let records = CKModel().getRecords()
        files = records
        
        tableView.reloadData()
    }
}

// Obtain total count of rows in table
extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return files.count
    }
}

extension ViewController: NSTableViewDelegate {
    // Handle a row selection of data
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedItem = tableView.selectedRow
    }
    
    // Populate the table with data
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let record = files[row]
        
        // Write each records' data to each row in the table
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "recordColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "RNCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = record.recordID.recordName
            return cellView

        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "startTime") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "STCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = record["Time"] as! String
            return cellView

        }
        return nil
    }
}


