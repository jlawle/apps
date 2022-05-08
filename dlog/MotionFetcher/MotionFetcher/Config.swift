//
//  Config.swift
//  MotionFetcher
//
//  Created by John Lawler on 5/7/22.
//

import Foundation

enum Config {
    // Set the iCloud container identifier here - where it is uploaded to in cloudkit console
    static let containerIdentifier = "iCloud.com.Hoover.watchLog.watchkitapp.watchkitextension"
    
    // Define the header used for the csv file
    static let CSVHeader = "Time,accx,accy,accz,gyrox,gyroy,gyroz\n"
    
    // Define a single file name to manipulate during storing data
    // Auto-deletes file after uploading to cloudkit
    static let CSVFilename = "sensordata.csv"
}
