//
//  ViewController.swift
//  Project16
//
//  Created by Dillon McElhinney on 7/20/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let londonCoordinates = CLLocationCoordinate2D(latitude: 51.507222,
                                                       longitude: -0.1275)
        let london = Capital(title: "London",
                             coordinate: londonCoordinates,
                             info: "Home to the 2012 Summer Olympics.")

        let osloCoordinates = CLLocationCoordinate2D(latitude: 59.95,
                                                     longitude: 10.75)
        let oslo = Capital(title: "Oslo",
                           coordinate: osloCoordinates,
                           info: "Founded over a thousand years ago.")

        let parisCoordinates = CLLocationCoordinate2D(latitude: 48.8567,
                                                      longitude: 2.3508)
        let paris = Capital(title: "Paris",
                            coordinate: parisCoordinates,
                            info: "Often called the City of Light.")

        let romeCoordinates = CLLocationCoordinate2D(latitude: 41.9,
                                                     longitude: 12.5)
        let rome = Capital(title: "Rome",
                           coordinate: romeCoordinates,
                           info: "Has a whole country inside it.")

        let washingtonCoordinates = CLLocationCoordinate2D(latitude: 38.895111,
                                                           longitude: -77.036667)
        let washington = Capital(title: "Washington DC",
                                 coordinate: washingtonCoordinates,
                                 info: "Named after George himself.")

        mapView.addAnnotations([london, oslo, paris, rome, washington])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change Map Style", style: .plain, target: self, action: #selector(presentMapTypeAlertController))
    }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil }

        let identifier = "Capital"

        var annotationView = mapView
            .dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: identifier)
            annotationView?.canShowCallout = true

            let button = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.pinTintColor = .cyan

        return annotationView
    }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        guard let capital = view.annotation as? Capital else { return }

        let placeName = capital.title

        let webViewController = WebViewController()
        webViewController.selectedItem = placeName

        navigationController?.pushViewController(webViewController,
                                                 animated: true)
    }
    
    @objc private func presentMapTypeAlertController() {
        let alertController =
            UIAlertController(title: "Map Display Type",
                              message: "How would you like to display the map?",
                              preferredStyle: .actionSheet)
        
        for mapType in MapType.allCases {
            let action = UIAlertAction(title: mapType.rawValue,
                                       style: .default,
                                       handler: changeMapType)
            
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func changeMapType(_ action: UIAlertAction) {
        let mapType = MapType(rawValue: action.title!)!
        
        mapView.mapType = mapType.mapType()
    }
    
    enum MapType: String, CaseIterable {
        case standard = "Standard"
        case muted = "Muted"
        case hybrid = "Hybrid"
        case satellite = "Satellite"
        
        func mapType() -> MKMapType {
            switch self {
            case .standard:
                return .standard
            case .muted:
                return .mutedStandard
            case .hybrid:
                return .hybrid
            case .satellite:
                return .satellite
            }
        }
    }

}

