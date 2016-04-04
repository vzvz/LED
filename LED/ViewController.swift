//
//  ViewController.swift
//  LED
//
//  Created by Marco Ebert on 26.03.16.
//  Copyright © 2016 Marco Ebert. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!

    private var centralMananger: CBCentralManager?
    private var discoveredPeripheral: CBPeripheral?

    private let ServiceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD666661")
    private let CharacteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6F66666D4")

    // UIViewController delegates.

    override func viewDidLoad() {
        super.viewDidLoad()

        centralMananger = CBCentralManager(delegate: self, queue: nil)
        print("Central manager initalized.")
    }

    override func viewWillDisappear(animated: Bool) {
        centralMananger?.stopScan()
        print("Scanning stopped.")

        super.viewWillAppear(animated)
    }

    // UI methods.

    /**
     * Updates the shown text of the label to the current value of the slider.
     */
    func updateLabel() {
        let int = Int(self.slider.value)
        let string = String(int)
        label.text! = "\(string) W"
    }

    /**
     * Updates the shown text of the label to the current value of the slider.
     */
    @IBAction func sliderValueChanged(sender: UISlider) {
        if sender == self.slider {
            updateLabel()
        }
    }

    // Bluetooth methods.

    /**
     * Scans for services with the specified UUID.
     */
    func scan() {
        centralMananger?.scanForPeripheralsWithServices([ServiceUUID], options: nil)
        print("Scanning started.")
    }

    func clean() {
        if let services = discoveredPeripheral?.services {
            for service in services {
                if let characteristics = service.characteristics {
                    for characteristic in characteristics {
                        if characteristic.UUID == CharacteristicUUID {

                        }
                    }
                }
            }
        }
    }

    /**
     * Notifiy central manager state changes.
     *
     * Starts scanning when Bluetooth is powered on.
     */
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("Central manager did update state: \(central.state)")

        if central.state != .PoweredOn {
            return
        }

        scan()
    }

    /**
     * Checks peripherals discovered in scan() and connects to the first valid one.
     */
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if RSSI.integerValue > -15 || RSSI.integerValue < -35 {
            print("Peripheral signal strength is invalid.")
            return
        }

        print("Discovered peripheral \(peripheral.name) at \(RSSI.integerValue).")

        if discoveredPeripheral != peripheral {
            discoveredPeripheral = peripheral

            print("Connecting to peripheral.")
            centralMananger?.connectPeripheral(peripheral, options: nil)
        }
    }

    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect to peripheral \(peripheral.name): \(error?.description).")
    }

}
