//
//  CurrentRunVC.swift
//  Treads
//
//  Created by NGUYENLONGTIEN on 6/7/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
class CurrentRunVC: LocationVC, UIGestureRecognizerDelegate {
    // MARK: - UI Elements
    @IBOutlet weak var swipeBGImageView: UIImageView!
    @IBOutlet weak var sliderImageView: UIImageView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var DistanceLbl: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var unitDistanceLbl: UILabel!
    // MARK: Model
    var startLocation:CLLocation!
    var lastLocation:CLLocation!
    var distance = 0.0
    //
    var couter = 0
    //
    var pace = 0.0
    var counterTimer:Timer!
    var averagePaceTimer:Timer!
    //
    var coordinateLocation = List<Location>()
    
    
    
    // MARK: -UI ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        paceLbl.text = "0.00"
        //Add panGesture to sliderImageView
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(CurrentRunVC.endRunSwiped(sender:)))
        sliderImageView.addGestureRecognizer(swipeGesture)
        sliderImageView.isUserInteractionEnabled = true
        swipeGesture.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        locationManager?.delegate = self
        locationManager?.distanceFilter = 10
        //
        startRun()
    }
    // MARK: - UI Events
    @IBAction func pressedPauseButton(_ sender: Any) {
        if averagePaceTimer.isValid && counterTimer.isValid{
            //
            pauseRun()
        }else{
            startRun()
            pauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        }
    }
    // MARK: - Helper method
    //
    func startRun(){
        locationManager?.startUpdatingLocation()
        //
        startTimer()
        //
        coutAveragePace()
        
    }
    //
    func stopRun(){
        locationManager?.stopUpdatingLocation()
        //add our obfect to realm
        Run.addRunToRealm(pace: pace, duration: couter, distance: distance, location: coordinateLocation)
    }
    //
    func pauseRun(){
        startLocation = nil
        lastLocation = nil
        counterTimer.invalidate()
        averagePaceTimer.invalidate()
        locationManager?.stopUpdatingLocation()
        pauseButton.setImage(UIImage(named: "resumeButton"), for: UIControl.State.normal)
    }
    //
    func startTimer(){
        counterTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    //
    func coutAveragePace(){
        averagePaceTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateAveragePace), userInfo: nil, repeats: true)
    }
    
    
    //----------------------------------//
    
    @objc func updateAveragePace(){
        pace = distance / Double(couter)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        paceLbl.text = formatter.string(from: NSNumber(value: pace))
    }
    @objc func updateCounter(){
        couter += 1
        durationLbl.text = couter.convertFromDurationTimeToTime()
        
    }
    @objc func endRunSwiped(sender:UIPanGestureRecognizer){
        let minAdjust:CGFloat = 65
        let maxAdjust:CGFloat = 105
        if let sliderView = sender.view{
            if sender.state == .began || sender.state == .changed{
                // start to swipe or swiping
                let translation = sender.translation(in: self.view)
                if sliderView.center.x >= swipeBGImageView.center.x - minAdjust && sliderView.center.x <= swipeBGImageView.center.x + maxAdjust {
                    sliderView.center.x = sliderView.center.x + translation.x
                }else if sliderView.center.x >= swipeBGImageView.center.x + maxAdjust{
                    sliderView.center.x = swipeBGImageView.center.x + maxAdjust
                    //End Run Code Here
                    stopRun()
                    //dismiss(animated: true, completion: nil)
                    performSegue(withIdentifier: unwindSegue, sender: nil)
                }else{
                    sliderView.center.x = swipeBGImageView.center.x - minAdjust
                }
                sender.setTranslation(CGPoint.zero, in: self.view)
            }else if sender.state == .ended{
                // end of swipe
                UIView.animate(withDuration: 0.1) {
                    sliderView.center.x = self.swipeBGImageView.center.x - minAdjust
                }
            }
        }
    }
}
// MARK: - Location ManagerDelegate
extension CurrentRunVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            configureLocationService()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil{
            startLocation = locations.first
        }else if let location = locations.last{
            distance += lastLocation.distance(from: location)
            // tinh thoi gian khi app o che do bacground mode
            let time = location.timestamp
            let queue = DispatchQueue(label: "time")
            queue.async {
                var startTime:Date?
                guard let beginningTime = startTime else {
                    startTime = time
                    return
                }

                let elapsed = time.timeIntervalSince(beginningTime)

                if elapsed >= 5.0 {
                    self.couter = Int(elapsed)
                    startTime = time
                }
            }
            
            //
            var newCoordinate = Location(latitude: Double((locations.last?.coordinate.latitude)!), longitude: Double((locations.last?.coordinate.longitude)!))
            coordinateLocation.insert(newCoordinate, at: 0)
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            
            //
            if distance > 1000{
                let newDistance = distance / 1000
                DistanceLbl.text = "\(formatter.string(from: NSNumber(value: newDistance))!)"
                unitDistanceLbl.text = "Km"
            }else{
                DistanceLbl.text = "\(formatter.string(from: NSNumber(value: distance))!)"
                unitDistanceLbl.text = "m"
            }
        }
        lastLocation = locations.last
    }
}
