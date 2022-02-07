//
//  ViewController.swift
//  fileTest
//
//  Created by John Lawler on 1/31/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let str = "Testing string of data from app container."
           let url = getDocumentsDirectory().appendingPathComponent("message.txt")

           do {
               try str.write(to: url, atomically: true, encoding: .utf8)
               let input = try String(contentsOf: url)
               print(input)
           } catch {
               print(error.localizedDescription)
           }
    }

    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

}

