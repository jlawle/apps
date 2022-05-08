//
//  ViewController.swift
//  MotionFetcher
//
//  Created by John Lawler on 5/7/22.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var RecordTableView: NSScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    private func writeFile () {
        var isDir: ObjCBool = true //needed to create new directory
        
        let file = "test.csv"
        let contents = "some text..."
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("MotionFetcher")
        let fileURL = appDir.appendingPathComponent(file)

        
        if !FileManager.default.fileExists(atPath: appDir.path, isDirectory: &isDir) {
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        }

        do {
            try contents.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch {
            print("Error: \(error)")
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func buttonPressed(_ sender: Any) {
        print("Button Pressed")
        let records = CKModel().getRecords()
       //writeFile()
        
        log.info("Printing retrieved records ...")
        print(records)
        for record in records {
            let filename = record["Filename"]
            print(filename ?? "nil")
        }
    }
    
}

