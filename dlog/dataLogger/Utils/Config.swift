//
//  Config.swift
//  dataLogger WatchKit Extension
//
//  Created by John Lawler on 3/11/22.
//
import Logging

let log = Logger(label: "")

enum Config {
    /// iCloud container identifier.
    /// Update this if you wish to use your own iCloud container.
    static let containerIdentifier = "iCloud.com.Hoover.watchLog.watchkitapp.watchkitextension"
}
