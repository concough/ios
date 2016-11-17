//
//  ViewController.swift
//  Concough
//
//  Created by Owner on 2016-11-06.
//  Copyright © 2016 Famba. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var json: JSON = ["name": "Abolfazl", "age": 24, "lessons": ["math", "art"]]
        
        if let name = json["lessons"].array {
            print(name[0])
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

