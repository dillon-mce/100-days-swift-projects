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

    private var hasAlertBeenShown = false
    private var uuids = [
        UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!: "My Beacon",
        UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935")!: "Apple AirLocate",
        UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!: "Other Apple AirLocate"
    ]
    private var currentRegion: CLBeaconRegion?

    @IBOutlet var beaconLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var circleView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

        view.backgroundColor = .gray
        distanceLabel.textColor = .white
        beaconLabel.textColor = .white
        beaconLabel.transform = beaconLabel.transform.scaledBy(x: 1, y: 0.001)

        circleView.layer.cornerRadius = 128
        circleView.backgroundColor = .white
        circleView.transform = circleView.transform.scaledBy(x: 0.001, y: 0.001)
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
                         didEnterRegion region: CLRegion) {

        if let beaconRegion = region as? CLBeaconRegion {
            if let current = currentRegion {
                locationManager?.stopRangingBeacons(in: current)
            }
            currentRegion = nil
            locationManager?.startRangingBeacons(in: beaconRegion)
            currentRegion = beaconRegion
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            locationManager?.stopRangingBeacons(in: beaconRegion)
            update(distance: .unknown, name: "")
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            let name = uuids[beacon.proximityUUID] ?? "Unknown Beacon"
            update(distance: beacon.proximity, name: name)
        } else {
            update(distance: .unknown, name: "")
        }
    }

    // MARK: - Helper Methods
    private func startScanning() {
        for (uuid, identifier) in uuids {
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid,
                                              identifier: identifier)

            locationManager?.startMonitoring(for: beaconRegion)
        }

    }

    private func update(distance: CLProximity, name: String) {
        if distance != .unknown && !hasAlertBeenShown { presentAlert() }
        UIView.animate(withDuration: 0.5) {
            self.beaconLabel.text = name
            switch distance {
            case .far:
                self.view.backgroundColor = .blue
                self.distanceLabel.text = "FAR"
                self.beaconLabel.transform = .identity
                self.circleView.transform = CGAffineTransform.identity.scaledBy(x: 0.25, y: 0.25)
            case .near:
                self.view.backgroundColor = .orange
                self.distanceLabel.text = "NEAR"
                self.beaconLabel.transform = .identity
                self.circleView.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceLabel.text = "RIGHT HERE"
                self.beaconLabel.transform = .identity
                self.circleView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            default:
                self.view.backgroundColor = .gray
                self.distanceLabel.text = "UNKNOWN"
                self.beaconLabel.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 0.001)
                self.circleView.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
            }
            self.view.layoutIfNeeded()
        }
    }

    private func presentAlert() {
        hasAlertBeenShown = true
        let alertController = UIAlertController(title: "Found a beacon",
                                                message: nil,
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay",
                                   style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}

