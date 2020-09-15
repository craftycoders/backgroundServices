//
//  LocationVC.swift
//  BackgroundServices
//
//  Created by Lyle Jover on 9/15/20.
//  Copyright © 2020 craftycoders.io. All rights reserved.
//

import CoreLocation
import MapKit

class LocationVC: UIViewController {
    
  @IBOutlet weak var mapView: MKMapView!

  private var locations: [MKPointAnnotation] = []
  
  private lazy var locationManager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.delegate = self
    manager.requestAlwaysAuthorization()
    if #available(iOS 9, *) {
      manager.allowsBackgroundLocationUpdates = true
    }
    return manager
  }()
  
    @IBAction func enabledChanged(_ sender: UISwitch) {
        if sender.isOn {
          locationManager.startUpdatingLocation()
        } else {
          locationManager.stopUpdatingLocation()
        }
    }
  
    @IBAction func accuracyChanged(_ sender: UISegmentedControl) {
        let accuracyValues = [
          kCLLocationAccuracyBestForNavigation,
          kCLLocationAccuracyBest,
          kCLLocationAccuracyNearestTenMeters,
          kCLLocationAccuracyHundredMeters,
          kCLLocationAccuracyKilometer,
          kCLLocationAccuracyThreeKilometers]
        
        locationManager.desiredAccuracy = accuracyValues[sender.selectedSegmentIndex];
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationVC: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let mostRecentLocation = locations.last else {
      return
    }
    
    // Add another annotation to the map.
    let annotation = MKPointAnnotation()
    annotation.coordinate = mostRecentLocation.coordinate
    
    // Also add to our map so we can remove old values later
    self.locations.append(annotation)
    
    // Remove values if the array is too big
    while locations.count > 100 {
      let annotationToRemove = self.locations.first!
      self.locations.remove(at: 0)
      
      // Also remove from the map
      mapView.removeAnnotation(annotationToRemove)
    }
    
    if UIApplication.shared.applicationState == .active {
      mapView.showAnnotations(self.locations, animated: true)
    } else {
      print("App is backgrounded. New location is %@", mostRecentLocation)
    }
  }
  
}

