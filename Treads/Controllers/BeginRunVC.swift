//
//  FirstViewController.swift
//  Treads
//
//  Created by NGUYENLONGTIEN on 6/7/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
class BeginRunVC: LocationVC {
    // MARK: - UI Elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var paceLable: UILabel!
    @IBOutlet weak var distanceLable: UILabel!
    @IBOutlet weak var durationLable: UILabel!
    @IBOutlet weak var previousView: UIView!
    //
    
    // MARK: UI ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        mapView.delegate = self
        //
        configureLocationService()
        //
        //updatePreviousView()
        //
        NotificationCenter.default.addObserver(self, selector: #selector(runDataDidChange), name: NOTIF_RUD_DATA_DID_CHANGE, object: nil)
        //
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //
        mapView.delegate = self
        //
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        //
        updatePreviousView()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager?.stopUpdatingLocation()
    }
    //MARK: - UI Event

    @IBAction func centerLocationBtnPressed(_ sender: Any) {
        //mapView.userTrackingMode = .follow
        //
        if Run.getAllRunFromRealm()?.count == 0{
            centerMapOnUserLocation()
        }else{
            //CenterMapOnPolyline
            centerMapOnPolyline(lastLocation: (Run.getAllRunFromRealm()?.first!.locations)!)
        }
    }
    
    @IBAction func closePreviousViewBtnPressed(_ sender: Any) {
        previousView.isHidden = true
    }
    
    
    // MARK: UI NAvigationController
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        //updatePreviousView()
    }
    
    // MARK: - Helper Method
    func createPolyline(lastRun:Run){
        if mapView.overlays.count > 0{
            mapView.removeOverlays(mapView.overlays)
        }else{
            //Define point for polyline
            let locations = lastRun.locations
            var coordinateLocation = [CLLocationCoordinate2D]()
            for eachLocation in locations{
                let coordinate = CLLocationCoordinate2D(latitude: eachLocation.latitude, longitude: eachLocation.longitude)
                coordinateLocation.append(coordinate)
            }
            //create a Polyline
            let aPolyline = MKPolyline(coordinates: coordinateLocation, count: coordinateLocation.count)
            //Add Polyline to mapView
            mapView.addOverlay(aPolyline)
        }
    }
    //
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager?.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    //
    func centerMapOnPolyline(lastLocation locations:List<Location>){
        var minLatitude = locations.first?.latitude
        var minLongitude = locations.first?.longitude
        var maxLatitude = minLatitude
        var maxLongitude = minLongitude
        for eachLocation in locations{
            minLongitude = min(minLongitude!, eachLocation.longitude)
            minLatitude = min(minLatitude!, eachLocation.latitude)
            maxLatitude = max(maxLatitude!, eachLocation.latitude)
            maxLongitude = max(maxLongitude!, eachLocation.longitude)
        }
        if minLatitude != nil && maxLatitude != nil && maxLongitude != nil && minLongitude != nil{
            let coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLatitude! + maxLatitude!)/2, longitude: (minLongitude! + maxLongitude!)/2), span: MKCoordinateSpan(latitudeDelta: (maxLatitude! - minLatitude!)*1.4, longitudeDelta: (maxLongitude!-minLongitude!)*1.4))
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
    }
    //
    func updatePreviousView(){
        previousView.isHidden = false
        if Run.getAllRunFromRealm()?.count == 0 {
            previousView.isHidden = true
        }else{
            guard let lastRun = Run.getAllRunFromRealm()?.first else {return}
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            paceLable.text = "Pace: \(formatter.string(from: NSNumber(value: lastRun.pace))!) m/s"
            if lastRun.distance > 1000.0{
                self.distanceLable.text = "Distance: \(formatter.string(from: NSNumber(value: lastRun.distance/1000))!) km"
            }else{
                self.distanceLable.text = "Distance: \(formatter.string(from: NSNumber(value: lastRun.distance))!) m"
            }
            durationLable.text = "Duration: \(lastRun.duration.convertFromDurationTimeToTime())"
            //
            createPolyline(lastRun: lastRun)
        }
    }
    @objc func runDataDidChange(){
        updatePreviousView()
    }
    
}
// MARK: - CLLocationManagerDelegate
extension BeginRunVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways{
            mapView.showsUserLocation = true
            if Run.getAllRunFromRealm()?.count == 0{
                //CenterMapOnUserLocation
                mapView.userTrackingMode = .follow
            }else{
                //CenterMapOnPolyline
                centerMapOnPolyline(lastLocation: (Run.getAllRunFromRealm()?.first!.locations)!)
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            polylineRender.lineWidth = 5
            return polylineRender
        }
        return MKOverlayRenderer()
    }
}

