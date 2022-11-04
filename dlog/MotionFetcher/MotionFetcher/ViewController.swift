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
    var selectedItem: Int!
    var files: [CKRecord] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    private func writeFile (data: String, filename: String) {
        var isDir: ObjCBool = true //needed to create new directory
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("MotionFetcher")
        let fileURL = appDir.appendingPathComponent(filename)

        
        if !FileManager.default.fileExists(atPath: appDir.path, isDirectory: &isDir) {
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        }

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
        if selectedItem != -1 {
            let file = files[selectedItem]
            if let asset = file["File"] as? CKAsset {
                if let url = asset.fileURL, let data = try? String(contentsOf: url){
                    writeFile(data: data, filename: file["Filename"] as! String)
                }
            }
        } else {
            // Don't attempt to fetch a file, user needs to select a row
        }
    }
    
    
    // Deletes a record from the database
    @IBAction func DeleteEntry(_ sender: Any) {
        print("Deleting item at row: ", selectedItem ?? "nil")
        
        if selectedItem != -1 {
            let file = files[selectedItem]
            deleteRecordWithID(file.recordID) { recordID, error in
                if (error != nil) {
                    print("Error deleting record:", error!)
                }
            }
        }
        
        // Remove file from our list of records
        files.remove(at: selectedItem)
        
        
        // reload table data
        tableView.reloadData()
    }
    
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = false
    }
}

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
//        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "deleteColumn") {
//            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "RMCell")
//            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
//            cellView.textField?.stringValue = "Delete From Cloud"
//            return cellView
//
//        }
        return nil
    }
}


