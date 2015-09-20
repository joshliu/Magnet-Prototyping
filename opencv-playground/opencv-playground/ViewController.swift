//
//  ViewController.swift
//  opencv-playground
//
//  Created by Antonio Marino on 19/09/15.
//  Copyright (c) 2015 Team Goat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    
    var normalImage:UIImage?
    var processedImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let screenSize = UIScreen.mainScreen().bounds.size
        
        normalImage = UIImage(named: "Untitled-10")!
        
        image1.image = normalImage;
        
        let result = Wrapper.processImage(normalImage, withVC: self);
        processedImage = result as UIImage!
        
        image2.image = processedImage;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

