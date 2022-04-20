//
//  Config.swift
//  dataLogger WatchKit Extension
//
//  Created by John Lawler on 3/11/22.
//
import Logging

let log = Logger(label: "")

enum Config {
    // Set the iCloud container identifier here - where it is uploaded to in cloudkit console
    static let containerIdentifier = "iCloud.com.Hoover.watchLog.watchkitapp.watchkitextension"
    
    // Define the header used for the csv file
    static let CSVHeader = "Time,accx,accy,accz,gyrox,gyroy,gyroz\n"
}
