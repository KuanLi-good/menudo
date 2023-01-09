//  https://github.com/shu2syu2/BeaconDetector
//  https://www.hackingwithswift.com/quick-start/swiftui/how-to-send-state-updates-manually-using-objectwillchange

import Combine
import CoreLocation
import SwiftUI

class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    var didChange = PassthroughSubject<Void, Never>()
    var locationManager: CLLocationManager?
    @Published var seller: Seller? {
        willSet {
            objectWillChange.send()
        }
    }
    var lastMajor = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    var lastDistance = CLProximity.unknown {
        willSet {
            objectWillChange.send()
        }
    }
    
    var beacons: [CLBeacon] = []
    @Published var sellerList = SellerList()
    
    override init() {
        super.init()
        get_users()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization state : CLAuthorizationStatus) {
        if state == .authorizedWhenInUse || state == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        locationManager?.startMonitoring(for: CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "Beacon"))
        locationManager?.startRangingBeacons(satisfying: constraint)
    }
    
    /// detect beacon satisfy certain range, can be multilple use the same constraints
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
//        print(beacons)
//        dump(beacons)
        let beacon = beacons.min (by: { $0.proximity.rawValue < $1.proximity.rawValue })
        update(distance: beacon?.proximity ?? .unknown,
               major: beacon?.major ?? 0)
    }
    
    func update(distance: CLProximity, major: NSNumber) {
        lastDistance = distance
        lastMajor = Int(major)
        if lastDistance == .immediate || lastDistance == .near {
            seller = sellerList.find_by_major(major: lastMajor) ?? Seller()
        } else {
            seller = nil
        }
        print(lastDistance.rawValue, lastMajor)
        didChange.send(())
    }
    
    func get_users(){
        Serverless.shared.get_users { [self] result in
            switch result {
            case .success(let sellers) :
                sellerList.set(list: sellers)
                dump(sellerList)
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
}
