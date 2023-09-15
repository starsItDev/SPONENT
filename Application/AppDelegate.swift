//
//  AppDelegate.swift
//  SPONENT
//
//  Created by Rao Ahmad on 10/08/2023.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sleep(0)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        GMSServices.provideAPIKey("AIzaSyAa4XBFBGFJWSjcEdfCHniqmUOEPlKG0L0")
        GMSPlacesClient.provideAPIKey("AIzaSyBlfZiL0XCaYgADnu9O0lvRfGLUBo_s8HI")
        if CLLocationManager.locationServicesEnabled() {
                    locationManager.startUpdatingLocation()
        }
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           if status == .authorizedWhenInUse {
               locationManager.startUpdatingLocation()
           }
       }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
                self.userLocation = location
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
                  // detailMapView.camera = camera
                   locationManager.stopUpdatingLocation()
        }
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

