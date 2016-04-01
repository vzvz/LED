//
//  ViewController.swift
//  LED
//
//  Created by Marco Ebert on 26.03.16.
//  Copyright © 2016 Marco Ebert. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("View did load.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Did receive memory warning.")
    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        print("Slider value changed: \(sender.value)")
    }

}

