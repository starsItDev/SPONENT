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
import GoogleSignIn
import FacebookCore
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sleep(0)
        ApplicationDelegate.shared.application(
                   application,
                   didFinishLaunchingWithOptions: launchOptions
               )
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        GMSServices.provideAPIKey("AIzaSyAa4XBFBGFJWSjcEdfCHniqmUOEPlKG0L0")
        GMSPlacesClient.provideAPIKey("AIzaSyBlfZiL0XCaYgADnu9O0lvRfGLUBo_s8HI")
        if CLLocationManager.locationServicesEnabled() {
                    locationManager.startUpdatingLocation()
        }
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
              // Show the app's signed-out state.
            } else {
              // Show the app's signed-in state.
            }
          }
        let vc: UIViewController?
            vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
                window?.rootViewController = vc
                window?.makeKeyAndVisible()
        UNUserNotificationCenter.current().delegate = self
        checkForPermissions()
        return true
    }
    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation])
      var handled: Bool
      handled = GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }
      // If not handled by this app, return false.
      return false
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
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           completionHandler([.alert, .sound])
    }
    func checkForPermissions() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                break
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.dispatchNotification(message: "Notifications Allowed For Sponent", userID: "")
                    }
                }
            default:
                return
            }
        }
    }
    func dispatchNotification(message: String, userID: String) {
            UNUserNotificationCenter.current().delegate = self
            let identifier = "NotificationIdentifier"
            let notificationCenter = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Sponent"
            content.body = message
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            notificationCenter.requestAuthorization(completionHandler: {(granted, error) in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for user: \(userID)")
            }
        })
//            notificationCenter.add(request) { error in
//                if let error = error {
//                    print("Failed to schedule notification: \(error.localizedDescription)")
//                } else {
//                    print("Notification scheduled successfully for user: \(userID)")
//                }
//            }
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

