//
//  SettingsController.swift
//  dataLogger
//
//  Created by Cameron Burroughs on 4/26/22.
//

import Foundation
import WatchKit
import UIKit

class SettingsController: WKInterfaceController {
    
    //outlet definitions
    @IBOutlet var picker: WKInterfacePicker!
    @IBOutlet var sampRateLabel: WKInterfaceLabel!
    
    private var rateSelected : Int?
    
    //ViewController methods
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        populatePicker()
        self.picker.focus()
        picker.setSelectedItemIndex(samplingRate-1)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    
    //Action definitions
    @IBAction func DoneButtonPressed(_ sender: WKInterfaceButton) {
        samplingRate = rateSelected ?? 15

        picker.resignFocus()
        pop()
        //pushController(withName: "mainController", context: settings)
    }
    
    
    @IBAction func PickerChanged(_ value: Int) {
        rateSelected = value + 1
    }
    
 
    func populatePicker()->Void {
        var frequencies = [WKPickerItem]()
        
        for freq in 1...100 {
            let item = WKPickerItem()
            item.title = "\(freq) Hz"
            frequencies.append(item)
        }

        picker.setItems(frequencies)
    }
    
}
