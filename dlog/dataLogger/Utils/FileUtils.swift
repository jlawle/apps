//
//  FileUtils.swift
//  dataLogger
//
//  Created by John Lawler on 3/7/22.
//

import Foundation



public class FileUtils {
    
    init() {}
    
    
    // Retrieve the documents directory
    func documentDirectory() -> String {
        // Returns array of strings
        let documentDirectory = NSSearchPathForDirectoriesInDomains(
                                    .documentDirectory,
                                    .userDomainMask,
                                    true)
        return documentDirectory[0]
    }
    
    // Function for appending a string to a URL path in doc directory
    func append(toPath path: String, withPathComponent pathComponent: String) -> String? {
        // Check if path provided exists, if so append
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)
            return pathURL.absoluteString
        } else {
            print("errors with pathurl appending")
        }
        
        return nil
    }
    
    // Basic function for saving a file to documents directory given text string
    func save(text: String, toDirectory directory: String, withFileName fileName: String) -> String {
        
        
        // Create the filepath by appending the filename
        guard let filePath = self.append(toPath: directory, withPathComponent: fileName)
        else {
            // handle error here
            print("Error with creating filepath ...")
            return "nil"
        }
        
        // Attempt to write data to file
        do {
            try text.write(toFile: filePath,
                           atomically: true,
                           encoding: .utf8)
        } catch let error as NSError {
            print("Error writing file: ", error)
            return "nil"
        }
        
        print("Save successful")
        return filePath
    }
    
    
    
    
    // Function to check if file exists in documents directory
    func checkFile(name: String) -> Bool {
        let url = NSURL(fileURLWithPath: self.documentDirectory())
            if let pathComponent = url.appendingPathComponent(name) {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    print("FILE AVAILABLE")
                    return true
                } else {
                    print("FILE NOT AVAILABLE")
                    return false
                }
            } else {
                print("FILE PATH NOT AVAILABLE")
                return false
            }
        
    }
}


