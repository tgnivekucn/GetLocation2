//
//  ViewController.swift
//  GetLocation
//
//  Created by 粘光裕 on 2018/11/5.
//  Copyright © 2018年 com.open.lib. All rights reserved.
//

import UIKit
import CoreLocation
class ViewController: UIViewController {
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self //每次設定CLLocationManager的delegate,都會執行到didChangeAuthorization這個system callback
    }

    
    @IBAction func requestAuthorization(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func showCustomAlert() {
        let alert = UIAlertController(title: "", message: "要求定位權限", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "前往設定頁面", style: .default) {
            _ in
            UIApplication.shared.open(URL(string: "App-Prefs:root=com.open.lib.GetLocation")!, options: [:], completionHandler: nil)
            
        })
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var statusString = ""
        switch status {
        case .authorizedAlways:
            statusString = "authorizedAlways"
            break
        case .authorizedWhenInUse:
            statusString = "authorizedWhenInUse"
            break
        case .denied:
            statusString = "denied"
            break
        case .notDetermined:
            statusString = "notDetermined"
            break
        case .restricted:
            statusString = "restricted"
            break
        }
        if status == .denied || status ==  .restricted {
            showCustomAlert()
        }
        print("didChangeAuthorization  status is: \(statusString)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.locationManager.stopUpdatingLocation()
        getAddressFromLatLonWithLocale(pdblLatitude: "\(locValue.latitude)", withLongitude: "\(locValue.longitude)")
        
    }

    func getAddressFromLatLonWithLocale(pdblLatitude: String, withLongitude pdblLongitude: String) {
        let lat: Double = Double("\(pdblLatitude)")!
        let lon: Double = Double("\(pdblLongitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude: lat, longitude: lon)
        
        let locale = Locale(identifier: "zh_TW")
        if #available(iOS 11.0, *) {
            ceo.reverseGeocodeLocation(loc, preferredLocale: locale) {
                (placemarks, error) in
                if error == nil {
                    let pm = placemarks! as [CLPlacemark]
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        print(pm.country ?? "")
                        print(pm.locality ?? "")
                        print(pm.subLocality ?? "")
                        print(pm.thoroughfare ?? "")
                        print(pm.postalCode ?? "")
                        print(pm.subThoroughfare ?? "")
                    }
                }
            }
        } else {
            UserDefaults.standard.set(["zh_TW"], forKey: "AppleLanguages")
            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    UserDefaults.standard.removeObject(forKey: "AppleLanguages")
                    if error == nil {
                        let pm = placemarks! as [CLPlacemark]
                        if pm.count > 0 {
                            let pm = placemarks![0]
                            print(pm.country ?? "")
                            print(pm.locality ?? "")
                            print(pm.subLocality ?? "")
                            print(pm.thoroughfare ?? "")
                            print(pm.postalCode ?? "")
                            print(pm.subThoroughfare ?? "")
                        }
                    }
            })
        }
        
    }

}
