//
//  ViewController.swift
//  Project22
//
//  Created by Dillon McElhinney on 8/31/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?

    @IBOutlet var distanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

        view.backgroundColor = .gray
        distanceLabel.textColor = .white
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }

    // MARK: - Helper Methods

    private func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid,
                                          major: 123,
                                          minor: 456,
                                          identifier: "MyBeacon")

        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }

    private func update(distance: CLProximity) {
        UIView.animate(withDuration: 0.5) {
            switch distance {
            case .far:
                self.view.backgroundColor = .blue
                self.distanceLabel.text = "FAR"
            case .near:
                self.view.backgroundColor = .orange
                self.distanceLabel.text = "NEAR"
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceLabel.text = "RIGHT HERE"
            default:
                self.view.backgroundColor = .gray
                self.distanceLabel.text = "UNKNOWN"
            }
        }
    }
}

