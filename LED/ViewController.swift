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

    private let ServiceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    private let CharacteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")

    private var central: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?

    override func viewDidLoad() {
        super.viewDidLoad()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        var int = Int(slider.value)
        if int >= 0 && int <= 100 {
            label.text = "\(int) %"

            if let peripheral = peripheral, characteristic = characteristic {
                let data = NSData(bytes: &int, length: sizeof(Int))
                peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
            }
        }
    }

    private func reset() {
        self.peripheral = nil
        self.characteristic = nil
        slider.enabled = false
        label.text = "Disconnected"
    }

    private func scan() {
        if let central = central {
            central.scanForPeripheralsWithServices([ServiceUUID], options: nil)
            label.text = "Scanning for peripherals..."
        }
    }

    private func disconnect() {
        if let central = central, peripheral = peripheral {
            central.cancelPeripheralConnection(peripheral)
        }
    }

    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == .PoweredOn {
            scan()
        } else {
            central.stopScan()
            reset()
        }
    }

    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if self.peripheral != peripheral {
            self.peripheral = peripheral
            central.stopScan()
            central.connectPeripheral(peripheral, options: nil)
            label.text = "Connecting to peripheral..."
        }
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([ServiceUUID])
        label.text = "Discovering services..."
    }

    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        reset()
        scan()
    }

    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        reset()
        scan()
    }

    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let _ = error {
            disconnect()
        } else if let services = peripheral.services {
            for service in services where service.UUID == ServiceUUID {
                peripheral.discoverCharacteristics([CharacteristicUUID], forService: service)
                label.text = "Discovering characteristics..."
                break
            }
        }
    }

    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let _ = error {
            disconnect()
        } else if let characteristics = service.characteristics {
            for characteristic in characteristics where characteristic.UUID == CharacteristicUUID {
                self.characteristic = characteristic
                slider.enabled = true
                label.text = "Connected"
                break
            }
        }
    }

}
