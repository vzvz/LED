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
    private var discoveredCharacteristic: CBCharacteristic?

    private let ServiceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    private let CharacteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")

    // UIViewController delegates.

    override func viewDidLoad() {
        super.viewDidLoad()

        centralMananger = CBCentralManager(delegate: self, queue: nil)
        slider.enabled = false
        label.text = "Not yet connected."
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
            if let peripheral = discoveredPeripheral, characteristic = discoveredCharacteristic {
                var intValue = Int(sender.value)
                let data = NSData(bytes: &intValue, length: sizeof(Int))
                peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
            }
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

    /**
     * Cancels any subscriptions to characteristics and disconnects from the peripheral.
     */
    func clean() {
        /*
        guard let peripheral = discoveredPeripheral, services = peripheral.services else {
            return
        }

        for service in services {
            guard let characteristics = service.characteristics else {
                continue
            }

            for characteristic in characteristics where characteristic.UUID == CharacteristicUUID && characteristic.isNotifying {
                peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                return
            }
        }

        centralMananger?.cancelPeripheralConnection(peripheral)
        */

        if let central = centralMananger, peripheral = discoveredPeripheral {
            central.cancelPeripheralConnection(peripheral)
        }
    }

    /**
     * Notifiy central manager state changes.
     *
     * Starts scanning when Bluetooth is powered on.
     */
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("Central manager did update state: \(central.state)")

        if central.state == .PoweredOn {
            scan()
        }
    }

    /**
     * Checks peripherals discovered in scan() and connects to the first valid one.
     */
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        /*if RSSI.integerValue > -15 || RSSI.integerValue < -35 {
            print("Peripheral signal strength is invalid.")
            return
        }*/

        print("Discovered peripheral \(peripheral.name) at \(RSSI.integerValue).")

        if discoveredPeripheral != peripheral {
            discoveredPeripheral = peripheral

            print("Connecting to peripheral.")
            centralMananger?.connectPeripheral(peripheral, options: nil)
        }
    }

    /**
     * Cleans and disconnects everything on fail.
     */
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect to peripheral \(peripheral.name): \(error?.description).")
        clean()
    }

    /**
     * We successfully connected to a peripheral. Time to discover the service.
     */
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Peripheral connected.")

        centralMananger?.stopScan()
        print("Scanning stopped.")

        peripheral.delegate = self
        peripheral.discoverServices([ServiceUUID])
    }

    /**
     * Dereference peripheral and characteristic after disconnect.
     */
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Peripheral disconnected.")
        discoveredPeripheral = nil
        discoveredCharacteristic = nil
        slider.enabled = false
        label.text = "Disconnected"
        scan()
    }

    /**
     * Services has been discovered - lets discover their characteristics.
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let error = error {
            print("Failed to discover service: \(error.description).")
            clean()
        } else if let services = peripheral.services {
            for service in services where service.UUID == ServiceUUID {
                peripheral.discoverCharacteristics([CharacteristicUUID], forService: service)
            }
        }
    }

    /**
     * Characteristics has been discovered - register for value change notifications.
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let error = error {
            print("Failed to discover characteristics: \(error.description).")
            clean()
            return
        }

        if let characteristics = service.characteristics {
            for characteristic in characteristics where characteristic.UUID == CharacteristicUUID {
                // peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                discoveredCharacteristic = characteristic
                slider.enabled = true

                var intValue = -1
                if let data = characteristic.value {
                    data.getBytes(&intValue, length: sizeof(Int))
                }
                if intValue != -1 {
                    label.text = "\(intValue) W"
                } else {
                    label.text = "Connected"
                }

                return
            }
        }
    }

}
