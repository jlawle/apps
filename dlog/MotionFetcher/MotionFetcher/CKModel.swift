//
//  CKModel.swift
//  MotionFetcher
//
//  Created by John Lawler on 5/7/22.
//

import Foundation
import CloudKit
import Logging



enum RecordResponse {
    case success(records: [CKRecord])
    case failure(errorString: String)
}

class CKModel {
    @Published var SignedIn: Bool = false
    var container: CKContainer
    var database: CKDatabase
    
    init() {
        // Get icloud  container and database reference
        self.container = CKContainer(identifier: Config.containerIdentifier)
        self.database = container.privateCloudDatabase
        
        // Check account status
        checkStatus()
    }
    
    
    // Verify account status is good
    private func checkStatus() {
        self.container.accountStatus { accountStatus, error in
            DispatchQueue.main.async {
                switch accountStatus {
                case .available:
                    log.info("iCloud account available ")
                    self.SignedIn = true
                case .noAccount:
                    log.error("iCloud account not found ...")
                case .temporarilyUnavailable:
                    log.error("iCloud account temporarily unavailable")
                case .couldNotDetermine:
                    log.error("Could not determine account status")
                case .restricted:
                    log.error("iCloud account status restricted")
                @unknown default:
                    fatalError("Error getting iCLoud account status: \(String(describing: error))")
                }
            }
        }
    }

    // Return list of records to caller
    func getRecords() -> [CKRecord] {
        log.info("Getting records ... ")
        var recordlist: [CKRecord] = []
        let semaphore = DispatchSemaphore(value: 0)
        

        // Fetch records with completion handler
        sendQueryOperation() { response in
            switch response {
            case .success(let records):
                log.info("Successfully retrieved records")
                recordlist = records
                
            case .failure(let errString):
                log.error("error retrieving records: \(errString)")
            }
            semaphore.signal()
        }

        semaphore.wait()
        return recordlist
    }

    // Fetch records functions retrieves a list of CKRecords and returns them on completion
    func sendQueryOperation(completion: @escaping (_ response: RecordResponse) -> ()) {
        log.info("Querying Cloudkit ...")

        var fetchedRecordIDs : [CKRecord.ID] = []
        var records : [CKRecord] = []

        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "Filename", ascending: true);
        let query = CKQuery(recordType: "Motion", predicate: predicate)
        query.sortDescriptors = [sort]

        let queryOperation = CKQueryOperation(query: query)


        queryOperation.recordMatchedBlock = { recordID, result in
            if let record = try? result.get() as CKRecord {
                fetchedRecordIDs.append(recordID)
                records.append(record)
            }
        }


        queryOperation.queryResultBlock = { result in
          switch result {
          case .success:
              completion(.success(records: records))
              break
          case .failure:
              log.info("queryOperation:queryResultBlock - result failure = \(result)")
              completion(.failure(errorString: "Error querying result block"))
            // TODO: An error happened at the operation level, check the error and decide what to do. Retry might be applicable, or tell the user to connect to internet, etc..
            break
          }
        }

        database.add(queryOperation)
    }
}


