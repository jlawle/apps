//
//  Config.swift
//  dataLogger WatchKit Extension
//
//  Created by John Lawler on 3/11/22.
//
import Logging
import CloudKit


let log = Logger(label: "")

public var samplingRate = 15

enum Config {
    // Set the iCloud container identifier here - where it is uploaded to in cloudkit console
    static let containerIdentifier = "iCloud.com.Hoover.watchLog.watchkitapp.watchkitextension"
    
    // Define the header used for the csv file
    static let CSVHeader = "Time,accx,accy,accz,gyrox,gyroy,gyroz\n"
    
    // Define a single file name to manipulate during storing data
    // Auto-deletes file after uploading to cloudkit
    static let CSVFilename = "sensordata.csv"
}

// Options for returning userID
enum UserRecordIDResponse {
    case success(record: CKRecord.ID)
    case failure(error: Error)
    case unavailable(accountStatus: CKAccountStatus)
}

//struct for transmitting setting data


// Implements retrieval of the iCloud container ID for a specific user
class RecordIDProvider: NSObject {
    
    
    // Check if ICloud account exists, then send request to fetch recordID
    class func getUserRecordID(completion: @escaping (_ response: UserRecordIDResponse) -> ()) {
        let container = CKContainer(identifier: Config.containerIdentifier)
        
        // Validate iCloud account is available
        container.accountStatus() { accountStatus, error in
            if accountStatus == .available {
                
                // Fetch icloud user ID using given container
                container.fetchUserRecordID(completionHandler: {(recordID, error) -> Void in
                    
                    guard let recordID = recordID else {
                        log.error("Error fetching Record ID: \(String(describing: error))")
                        let error = error ?? NSError(domain: "", code: 0, userInfo: nil)
                        completion(.failure(error: error))
                        return
                    }
                    // Return if successful in retrieving ID
                    completion(.success(record: recordID))
                })
            } else {
                completion(.unavailable(accountStatus: accountStatus))
                
            }
        }
    }
}

// Send request to fetch the user iCloud identifer and return as string
// Waits for closure to finish to return the user ID
func requestUserID() -> (String, CKRecord.ID) {
    var userID = String()
    var record = CKRecord.ID()
    let semaphore = DispatchSemaphore(value: 0)

    RecordIDProvider.getUserRecordID() { response in
        switch response {
        case .success(let recordID):
            userID = recordID.recordName
            record = recordID
            log.info("User ID found: \(record.recordName)")
        case .failure(let error):
            log.error("error requesting userID: \(error)")
        case .unavailable(let status):
            log.error("Account unavailable: \(status)")
        }
        semaphore.signal()
    }
    
    // Wait for closure to finish so userID is set
    semaphore.wait()
    return (userID, record)
}
    
// Retrieve current date as string
func getDate() -> String {
    let currentDateTime = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-YYYY"
    return formatter.string(from: currentDateTime)
}

// Retrieve current Timestamp as string
func getTime(ms: Bool) -> String {
    let currentDateTime = Date()
    
    // Format "HH" indicates 24-hour, "hh" 12-hour, "SSSS" for ms
    let formatter = DateFormatter()
    if ms {
        formatter.dateFormat = "HH:mm:ss.SSSS"
    } else {
        formatter.dateFormat = "HH-mm-ss"
    }
    
    // Return time
    return formatter.string(from: currentDateTime)
}

    

