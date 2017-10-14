//
//  JKLocationManager.swift
//  JKMaterialKit
//
//  Created by Jitendra Kumar on 20/01/17.
//  Copyright © 2017 Jitendra. All rights reserved.
//

import UIKit
import CoreLocation
typealias JKUpdateLocationsHanlder = ( _ locations: [CLLocation],_ manager: CLLocationManager)->Void
typealias JKFailureLocationsHanlder = (_ error :Error,_ manager: CLLocationManager)->Void

class JKLocationManager: NSObject {

    var updateLocationBlock : JKUpdateLocationsHanlder!
    var failureLocationBlovk :JKFailureLocationsHanlder!
    class var shared:JKLocationManager {
        struct Singleton {
            static let instance = JKLocationManager()
            
        }
        
        return Singleton.instance
    }
    func setuploaction() {
        locationManager.delegate = self
    }
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if(manager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) || manager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))) {
            manager.requestAlwaysAuthorization()
            manager.requestWhenInUseAuthorization()
            //or
            //locationManager.requestWhenInUseAuthorization()
            if #available(iOS 9.0, *) {
                manager.requestLocation()
            } else {
                // Fallback on earlier versions
                manager.startUpdatingLocation()
            }
        }
        return manager
    }()
    
    func updateLocations(didUpdateLocarionCompletion:@escaping JKUpdateLocationsHanlder,didFailWithErrorCompletion:@escaping JKFailureLocationsHanlder){
        
        updateLocationBlock = didUpdateLocarionCompletion
        failureLocationBlovk = didFailWithErrorCompletion
    }
    
}
extension JKLocationManager:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (self.updateLocationBlock != nil)
        {
            self.updateLocationBlock(locations,manager)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            if #available(iOS 9.0, *) {
                locationManager.requestLocation()
            } else {
                // Fallback on earlier versions
                locationManager.startUpdatingLocation()
            }
            break
        case .authorizedAlways:
            if #available(iOS 9.0, *) {
                locationManager.requestLocation()
            } else {
                // Fallback on earlier versions
                locationManager.startUpdatingLocation()
            }
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            self.loacationAlert(message: "User can't enable Location Services, but can grant access from Settings.app")
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
          
            self.loacationAlert(message: "user denied your app access to Location Services, but can grant access from Settings.app")
            break
            
        }
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if (self.failureLocationBlovk != nil)
        {
            self.failureLocationBlovk(error,manager)
        }
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
    }
    func loacationAlert(message:String){
        
        JKNotificationView.showNotificationView(image: #imageLiteral(resourceName: "language_ar"), withTitle: kAlertTitle, withMessage: message, AutoHide: true, onTouchHandler: { (animated:Bool) in
            UIApplication.shared.openURL(URL(string: "prefs:root=LOCATION_SERVICES")!)
        })
    }
   
    //* CLBeacon-
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
    }
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        
    }
   
}
