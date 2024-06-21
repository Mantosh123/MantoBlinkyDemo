//
//  ViewController.swift
//  MantoBlinkyDemo
//
//  Created by Mantosh Kumar on 21/06/24.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    var central: CBCentralManager!
    var scanedPeripherals: [CBPeripheral] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Peripheral List"
        setStatusBarBGColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // for ios > 13 IOS
    private func setStatusBarBGColor() {
        let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
        let statusBar = UIView(frame: window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
        statusBar.backgroundColor = .systemOrange
        window?.addSubview(statusBar)
        navigationController?.navigationBar.backgroundColor = .systemOrange
    }
    
    private func moveToNextScreen(peripheral: CBPeripheral) {
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let viewCtr = storyboard.instantiateViewController(withIdentifier: "BlinkyViewController") as! BlinkyViewController
        viewCtr.sPeripheral = peripheral
       navigationController?.pushViewController(viewCtr, animated: true)
    }
    @IBAction func scanButtonAction(_ sender: Any) {
        central = CBCentralManager(delegate: self, queue: nil)
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Check Bluetooth Status
        if central.state == CBManagerState.poweredOn {
            debugPrint("Bluetooth is ON")
            central.scanForPeripherals(withServices: nil)
        } else {
            debugPrint("Bluetooth is OFF")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Peripheral: \(peripheral)")
        
        // TODO: Need to filter only new peripheral can add into array
        scanedPeripherals.append(peripheral)
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanedPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: "PeripheralCell") as! PeripheralCell
        cell.nameLabel.text = scanedPeripherals[indexPath.row].name ?? "Unknown device"
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedPeripheral = scanedPeripherals[indexPath.row]
        central.stopScan()
        central.connect(selectedPeripheral) // connect to selected peripheral device , it may take some time. 
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.moveToNextScreen(peripheral: selectedPeripheral)
        }
    }
    
}



