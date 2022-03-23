//
//  CMUtils.swift
//  dataLogger WatchKit Extension
//
//  Created by Cameron Burroughs on 3/22/22.
//

import Foundation
import CoreMotion
import HealthKit

struct sensorParam {
    var time: String
    
    // gyro values
    var gyrox: Double
    var gyroy: Double
    var gyroz: Double
    
    // acc values
    var accx: Double
    var accy: Double
    var accz: Double
}

class CMUtils: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {

    let fileUtils = FileUtils()
    let manager = CMMotionManager()
    let healthStore = HKHealthStore()
    let queue = OperationQueue()
    
    var WKsession: HKWorkoutSession? = nil
    var builder: HKLiveWorkoutBuilder? = nil
    
    let interval = 1.0/60.0   //sampling interval, may change
    
    
    override init() {}
    
    func startWorkoutSession() {
        // if session is already started, do nothing
        if WKsession != nil {
            return
        }
        
        if !HKHealthStore.isHealthDataAvailable() {
            fatalError("HKHealthScore Unavailable!")
        }
        
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the health store.
        // here as more of an example of infor we can get, don't NEED these for our current purposes
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle errors here.
            guard success else {
                fatalError("AUTHORIZATION ERROR: \(String(describing: error))")
            }
        }
        
        let WKconfig = HKWorkoutConfiguration()
        WKconfig.activityType = .walking
        WKconfig.locationType = .indoor
        
        // Setup builder & session
        do {
            WKsession = try HKWorkoutSession(healthStore: healthStore, configuration: WKconfig)
            builder = WKsession?.associatedWorkoutBuilder()
        } catch {
            fatalError("Unable to create workout session!")
        }

        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: WKconfig)
        
        WKsession?.delegate = self
        builder?.delegate = self
        
        // Start session and builder
        WKsession?.startActivity(with: Date())
        builder?.beginCollection(withStart: Date()) { (success, error) in
            guard success else {
                fatalError("Unable to begin builder collection of data: \(String(describing: error))")
            }
        }

    }
    
    func endWorkoutSession() {
        
        WKsession!.end()
        builder!.endCollection(withEnd: Date()) { (success, error) in
            
            guard success else {
                // Handle errors
                fatalError("Unable to end builder data collection: \(String(describing: error))")
            }
            
            self.builder!.finishWorkout { (workout, error) in
                
                guard workout != nil else {
                    // Handle errors
                    fatalError("Unable to finish builder workout: \(String(describing: error))")
                }
                
                DispatchQueue.main.async() {
                    // Update the user interface.
                }
            }
        }
        WKsession = nil
    }
    
    // sets struct to all zeros, diagnostic to see where we are/aren't getting data
    func zeroParams() -> sensorParam {
        let sensorData = sensorParam(time: "00:00:00", gyrox: 0, gyroy: 0, gyroz: 0, accx: 0, accy: 0, accz: 0)
        return sensorData
    }
    
    func startUpdates(sendTo filePath: String) {
        
        startWorkoutSession()
        let url = NSURL(fileURLWithPath: filePath)

        if !manager.isDeviceMotionAvailable {
            fatalError("Device motion not available.")
        }

        manager.deviceMotionUpdateInterval = interval
        
        // Continually gets motion data and updates CSV file
        manager.startDeviceMotionUpdates(to: queue){ (data,err) in
            if err != nil {
                print("Error starting Device Updates: \(err!)")
            }
            var sensorData = self.zeroParams()
            
            if data != nil {
                sensorData.accx = data!.userAcceleration.x
                sensorData.accy = data!.userAcceleration.y
                sensorData.accz = data!.userAcceleration.z
                sensorData.gyrox = data!.rotationRate.x
                sensorData.gyroy = data!.rotationRate.y
                sensorData.gyroz = data!.rotationRate.z
                
                sensorData.time = self.getTime()
                let sortedData = self.sortData(usingData: sensorData)
                self.fileUtils.updtateCSV(atURL: url, withInfo: sortedData)
            }
        }
        
    }
    
    func stopUpdates() {
        if (WKsession == nil){
            return
        }
        
        manager.stopDeviceMotionUpdates()
        endWorkoutSession()
    }
    
    // Takes in sensor parameters and sorts them into a csv-style string CHANGE INFO ORDER HERE
    func sortData (usingData params: sensorParam) -> String {
        return "\(params.time),\(params.accx),\(params.accy),\(params.accz),\(params.gyrox),\(params.gyroy),\(params.gyroz)\n"
    }
    
    func getTime() -> String {
        // get current date/time
        let currentDateTime = Date()
        
        //initialize formatter & style
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"   //"HH" indicates 24-hour, "hh" 12-hour
        
        return formatter.string(from: currentDateTime)
    }
    
    func getDate() ->String {
        // get current date/time
        let currentDateTime = Date()
        
        //initialize formatter & style
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-YYYY"
        
        return formatter.string(from: currentDateTime)
    }
    
    // Extra stubs&methods needed (code inside is suggested from apple dev forums,
    // but we dont end up using any of it
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
                guard let quantityType = type as? HKQuantityType else {
                    return // Nothing to do.
                }
                
                // Calculate statistics for the type.
                let statistics = workoutBuilder.statistics(for: quantityType)
                
                DispatchQueue.main.async() {
                    // Update the user interface.
                }
            }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        //let lastEvent = workoutBuilder.workoutEvents.last
            
            DispatchQueue.main.async() {
                // Update the user interface here.
            }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        //code
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        //code
    }
    
}
