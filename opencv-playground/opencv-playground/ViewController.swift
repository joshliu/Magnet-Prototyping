//
//  ViewController.swift
//  opencv-playground
//
//  Created by Antonio Marino on 19/09/15.
//  Copyright (c) 2015 Team Goat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Wrapper.processImage(nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

