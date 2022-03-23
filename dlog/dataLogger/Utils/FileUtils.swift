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
    
    // UNUSED, CAN BE DELETED
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
    
    // split save file into two fns (get path & update CSV), can prob combine some way but it works
    func getPath(inDirectory directory:String, withFileName fileName: String) -> String {
        guard let filePath = self.append(toPath: directory, withPathComponent: fileName)
        else {
            // handle error here
            print("Error with creating filepath ...")
            return "nil"
        }
        return filePath
    }
    
    // Updates CSV file at URL w info (encodes info: string  into data)
    func updtateCSV(atURL fileURL: NSURL, withInfo info: String) {
        
        guard let data = info.data(using: String.Encoding.utf8) else {return}
       
        // If file exists, go to end of file, adds encoded info->data
        if FileManager.default.fileExists(atPath: (fileURL as URL).path) {
            if let fileHandle = try? FileHandle(forWritingTo: fileURL as URL) {
                       fileHandle.seekToEndOfFile()
                       fileHandle.write(data)
                       fileHandle.closeFile()
                   }
            print("[added] \(info)")
        } else {
            // File DNE at path, adds header & info to new file
            var csvHeader = "Time,accx,accy,accz,gyrox,gyroy,gyroz\n"
            csvHeader.append(info)
            print("[header] \(csvHeader)")
            
            do {
                try csvHeader.write(to: fileURL as URL, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
        }
    }
    
    func deleteFile(withPath filePath: String) {
        let manager = FileManager.default
        if manager.fileExists(atPath: filePath) {
            try? manager.removeItem(atPath: filePath)
            print("file deleted?")
        } else {
            print("file does not exist")
        }
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


