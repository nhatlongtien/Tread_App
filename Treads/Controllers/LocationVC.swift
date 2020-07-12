//
//  LocationVC.swift
//  Treads
//
//  Created by NGUYENLONGTIEN on 6/7/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit
import MapKit
class LocationVC: UIViewController, MKMapViewDelegate {
    // MARK: - Model
    var locationManager:CLLocationManager?
    var auth = CLLocationManager.authorizationStatus()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.activityType = .fitness
    }
    func configureLocationService(){
        if auth == .notDetermined{
            locationManager?.requestAlwaysAuthorization()
        }else{
            return
        }
    }
}
