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
    
   // let interval = 1.0/Double(samplingRate)
    
    
    override init() {}
    
    // Requests healthstore access, establishes bckgnd session to record sensor data
    // Documentation for setting up a background workout session found here
    //https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/running_workout_sessions
    
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

        // Request authorization for those quantity types.
        log.info("Requesting healthstore authorization ... ")
        self.healthStore.requestAuthorization(toShare: typesToShare, read: nil, completion: { (success, error) in
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
                    print(error)
                    self.WKsession = nil
                    return
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
                        print("Unable to begin builder collection of data: \(String(describing: error))")
                        return
                        //fatalError("Unable to begin builder collection of data: \(String(describing: error))")
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
                print("Unable to end builder data collection: \(String(describing: error))")
                return
                //fatalError("Unable to end builder data collection: \(String(describing: error))")
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
    func startUpdates(filename: String) {
        startWorkoutSession()

        // Verify device-motion service is available on device
        if !manager.isDeviceMotionAvailable {
            fatalError("Device motion not available.")
        }

        // Set sampling rate
        let interval = 1/Double(samplingRate)
        print("Interval is: ", interval)
        
        manager.deviceMotionUpdateInterval = interval
        
        print("Deevice motion interval:", manager.deviceMotionUpdateInterval)
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
                
                sensorData.time = getTime(ms: true)
                let sortedData = self.sortData(usingData: sensorData)
                self.fileUtils.updtateCSV(filename: filename, withInfo: sortedData)
            }
        }
        
        print("Device motion interval:", manager.deviceMotionUpdateInterval)
        
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
