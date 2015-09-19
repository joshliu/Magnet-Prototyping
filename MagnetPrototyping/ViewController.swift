//
//  ViewController.swift
//  MagnetPrototyping
//
//  Created by Joshua Liu on 9/19/15.
//  Copyright © 2015 Joshua Liu. All rights reserved.
//

import UIKit

import CoreLocation

class ViewController: UIViewController, UIApplicationDelegate, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

