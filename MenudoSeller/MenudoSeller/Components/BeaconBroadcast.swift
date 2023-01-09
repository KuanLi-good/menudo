//
//  BeaconBroadcast.swift
//  MenudoAdmin
//
//  Created by kuan on 1/11/22.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreLocation
import SwiftUI

class BeaconBroadcast: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    @AppStorage("uuid_major") var uuid_major: Int = -1
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!

    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }

        let localBeaconUUID = "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"
        let localBeaconMajor: CLBeaconMajorValue = CLBeaconMajorValue(self.uuid_major)
        let localBeaconMinor: CLBeaconMinorValue = 0

        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(uuid: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "Mybeacon")

        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        print ("start broadcasting")
    }

    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
        
        print ("stop broadcasting")
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
        
    }
}
