//
//  BlinkyViewController.swift
//  MantoBlinkyDemo
//
//  Created by Mantosh Kumar on 21/06/24.
//

import UIKit
import CoreBluetooth

class BlinkyViewController: UIViewController {
    
    var sPeripheral: CBPeripheral!
    
    let blinkyServiceUUID = "DE8A5AAC-A99B-C315-0C80-60D4CBB51224"
    let blinkyLightCharUUID = "5B026510-4088-C297-46D8-BE6C736A087A"
    
    var lightPeripherals: CBCharacteristicProperties?
    var lightCharacteristic: CBCharacteristic?
    
    @IBOutlet weak var lightImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = sPeripheral.name
        sPeripheral.delegate = self
        //s-1
        sPeripheral.discoverServices(nil)
        
        lightImage.image = UIImage(systemName: "light.beacon.max")
        lightImage.tintColor = .darkGray
    }
    
    @IBAction func lightOnAction(_ sender: Any) {
        
        let turnOn = Data(bytes: [0x01], count: 1)
        guard let lightCharacteristic = self.lightCharacteristic else { return }
        sPeripheral.writeValue(turnOn, for: lightCharacteristic, type: .withResponse)
        lightImage.image = UIImage(systemName: "light.beacon.max.fill")
        lightImage.tintColor = .systemOrange
    }
    
    @IBAction func lightOffAction(_ sender: Any) {
        
        let turnOn = Data(bytes: [0x00], count: 1)
        guard let lightCharacteristic = self.lightCharacteristic else { return }
        sPeripheral.writeValue(turnOn, for: lightCharacteristic, type: .withResponse)
        lightImage.image = UIImage(systemName: "light.beacon.max")
        lightImage.tintColor = .darkGray
        
    }
}

extension BlinkyViewController: CBPeripheralDelegate {
    
    //s-4
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        debugPrint("services char \(service.characteristics)")
        let finalChar = service.characteristics?.first(where: { char in
            char.uuid.uuidString == blinkyLightCharUUID
        })
        self.lightCharacteristic = finalChar
    }
    
    //s-2
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        debugPrint(" services:- \(peripheral.services)")
        
        if let services = peripheral.services {
            for serv in services {
                if serv.uuid.uuidString == blinkyServiceUUID {
                    //s-3
                    serv.peripheral?.discoverCharacteristics(nil, for: serv) // get char of selected service
                }
            }
        }
    }
}
