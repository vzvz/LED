//
//  ViewController.swift
//  LED
//
//  Created by Marco Ebert on 26.03.16.
//  Copyright © 2016 Marco Ebert. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateLabel()
        print("View did load.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Did receive memory warning.")
    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        if (sender == self.slider) {
            updateLabel()
        }
    }

    func updateLabel() {
        let int = Int(self.slider.value)
        let string = String(int)
        label.text! = "\(string) W"
    }

}
