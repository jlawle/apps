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

// Class CMutils implements functionality using CoreMotion framework
class CMUtils: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {

    let fileUtils = FileUtils()
    let manager = CMMotionManager()
    let healthStore = HKHealthStore()
    let queue = OperationQueue()
    
    var WKsession: HKWorkoutSession? = nil
    var builder: HKLiveWorkoutBuilder? = nil
    
    let interval = 1.0/15.0   //sampling interval, may change
    
    
    override init() {}
    
    // Requests healthstore access, establishes bckgnd session to record sensor data
    // Documentation for setting up a background workout session found here
    // https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/running_workout_sessions
    func startWorkoutSession() {
        log.info("Initializing new workout session")
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
        // Neccesary object, however these data are unused for sensor recording purposes.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            //HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        // Request authorization for those quantity types.
        log.info("Requesting healthstore authorization ... ")
        self.healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: { (success, error) in
                guard success else {
                    fatalError("AUTHORIZATION ERROR: \(String(describing: error))")
                }

                // Create a workout configuration object
                // ** Activity and location type have no effect on sensor data
                let WKconfig = HKWorkoutConfiguration()
                WKconfig.activityType = .walking
                WKconfig.locationType = .indoor
                
                do {
                    // Initialize a new workout session with healthstore and configuration object
                    self.WKsession = try HKWorkoutSession(healthStore: self.healthStore,
                                                          configuration: WKconfig)
                    
                    // Initialize reference to builder object from our workout session
                    self.builder = self.WKsession?.associatedWorkoutBuilder()
                } catch {
                    fatalError("Unable to create workout session!")
                }

            
                // Create an HKLiveWorkoutDataSource object and assign it to the workout builder.
                self.builder?.dataSource = HKLiveWorkoutDataSource(healthStore: self.healthStore,
                                                                   workoutConfiguration: WKconfig)
            
                // Assign delegates to monitor both the workout session and the workout builder.
                self.WKsession?.delegate = self
                self.builder?.delegate = self
                
                // Start session and builder collection of health data
                self.WKsession?.startActivity(with: Date())
                self.builder?.beginCollection(withStart: Date()) { (success, error) in
                    guard success else {
                        fatalError("Unable to begin builder collection of data: \(String(describing: error))")
                    }
                    
                    // Indicate workout session has begun
                    log.info("Workout activity started, builder has begun collection")
                }
        })

        
       

    }
    
    // Ends the current background workout session and collection of data
    func endWorkoutSession() {
        log.info("Ending Workout Session ")
        WKsession!.stopActivity(with: Date())
        WKsession!.end()
        
        if(WKsession!.state == .ended) {
            log.info("Workout ended.")
        } else {
            log.info("Workout has not ended.")
        }
        
        // Stop builder collection of healthstore data
        builder!.endCollection(withEnd: Date()) { (success, error) in
            guard success else {
                // Handle errors
                fatalError("Unable to end builder data collection: \(String(describing: error))")
            }
            
            // Let builder know to finish workout session
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
    
    // Sets struct to all zeros, diagnostic to see where we are/aren't getting data
    func zeroParams() -> sensorParam {
        let sensorData = sensorParam(time: "00:00:00", gyrox: 0, gyroy: 0, gyroz: 0, accx: 0, accy: 0, accz: 0)
        return sensorData
    }
    
    // Begins data retrieval from sensors and appends to csv file in background
    func startUpdates(sendTo filePath: String) {
        
        startWorkoutSession()
        let url = NSURL(fileURLWithPath: filePath)

        // Verify device-motion service is available on device
        if !manager.isDeviceMotionAvailable {
            fatalError("Device motion not available.")
        }

        // Set sampling rate
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
    
    // Stops device motion updates
    func stopUpdates() {
        if (WKsession == nil){
            return
        }
        log.info("Stopping device motion updates ...")
        
        manager.stopDeviceMotionUpdates()
        endWorkoutSession()
    }
    
    // Handles sensor data struct, formats to string to write to csv
    // Change how data is written to file here
    func sortData (usingData params: sensorParam) -> String {
        return "\(params.time),\(params.accx),\(params.accy),\(params.accz),\(params.gyrox),\(params.gyroy),\(params.gyroz)\n"
    }
    
    // Retrieve current Timestamp as string
    func getTime() -> String {
        let currentDateTime = Date()
        
        // "HH" indicates 24-hour, "hh" 12-hour, "SSSS" for ms
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSS"
        
        // Option for returning unix time instead, unusued
        //let timeInterval = NSDate().timeIntervalSince1970
        //let time = String(timeInterval)
        
        //return time
        log.info("Getting time: \(currentDateTime)")
        return formatter.string(from: currentDateTime)
    }
    
    // Retrieve current date as string
    func getDate() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-YYYY"
        return formatter.string(from: currentDateTime)
    }
    
    // Extra stubs&methods needed (code inside is suggested from apple dev forums,
    // but we dont end up using any of it
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for _ in collectedTypes {
                
                DispatchQueue.main.async() {
                    // Update the user interface.
                }
            }
    }
    
    // Necessary func for workout builder
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        //let lastEvent = workoutBuilder.workoutEvents.last
            
            DispatchQueue.main.async() {
                // Update the user interface here.
            }
    }
    
    // Necessary func for workout builder
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        //code
    }
    
    // Necessary func for workout builder
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        //code
    }
    
}
