//
//  DetailViewController.swift
//  SPONENT
//
//  Created by Rao Ahmad on 16/08/2023.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

protocol DetailViewControllerDelegate: AnyObject {
    func didSelectLocation(_ locationName: String)
 }

class DetailViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, GMSMapViewDelegate{

    //MARK: - Variable
    @IBOutlet weak var detailScrollView: UIScrollView!
    @IBOutlet weak var requestToJoinButton: UIButton!
    @IBOutlet weak var detailSearchBar: UISearchBar!
    @IBOutlet weak var detailViewOne: UIView!
    @IBOutlet weak var detailViewTwo: UIView!
    @IBOutlet weak var detailMapView: GMSMapView!
    @IBOutlet weak var detailMapHeight: NSLayoutConstraint!
    @IBOutlet weak var detailBackLabel: UILabel!
    @IBOutlet weak var detailShareButton: UIButton!
    @IBOutlet weak var detailDoneButton: UIButton!
    var locationSelectedHandler: ((String) -> Void)?
    weak var delegate: DetailViewControllerDelegate?
    weak var homeVC: HomeVC?
    var locationManager = CLLocationManager()
    var isSearchBarHidden = true
    var areViewsHidden = false
    var expandMapHeight = false
    var isShareButtonHidden = false
    var isDoneButtonHidden = true
    var selectedMarker: GMSMarker?
    var selectedRegion: GMSCoordinateBounds?
    var selectedLocationCoordinate: CLLocationCoordinate2D?
    var userLocationCoordinate: CLLocationCoordinate2D?
    var selectedLocationInfo: (name: String, coordinate: CLLocationCoordinate2D)?

    //MARK: - Override Functions
    override func viewDidLoad() {
      super.viewDidLoad()
      detailSearchBar.isHidden = isSearchBarHidden
      detailViewOne.isHidden = areViewsHidden
      detailViewTwo.isHidden = areViewsHidden
      detailShareButton.isHidden = isShareButtonHidden
      detailSearchBar.delegate = self
      detailDoneButton.isHidden = isDoneButtonHidden
      detailMapView.delegate = self
      detailMapView.settings.compassButton = true
      detailMapView.settings.myLocationButton = true
      if expandMapHeight {
          let screenHeight = UIScreen.main.bounds.height
          detailMapHeight.constant = screenHeight
      }
        detailMapView.isMyLocationEnabled = true
        if let locationInfo = selectedLocationInfo {
            let coordinate = locationInfo.coordinate
            let marker = GMSMarker(position: coordinate)
            marker.title = locationInfo.name
            marker.map = detailMapView
            let cameraUpdate = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
            detailMapView.camera = cameraUpdate
        }
        if let userLocationCoordinate = userLocationCoordinate {
            let camera = GMSCameraPosition.camera(withLatitude: userLocationCoordinate.latitude, longitude: userLocationCoordinate.longitude, zoom: 15)
            detailMapView.camera = camera
        }
       
  }
     override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
  }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
         if let annotation = detailMapView.selectedMarker {
             homeVC?.addDetailsLocLabel.text = annotation.title
       }
  }

    //MARK: - Actions
    @IBAction func detailBackButton(_ sender: UIButton) {
       if let tabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
           tabBarController.modalPresentationStyle = .fullScreen
           self.present(tabBarController, animated: false, completion: nil)
      }
  }
    @IBAction func detailDoneBtnClicked(_ sender: UIButton) {
        let searchedLocation = detailSearchBar.text ?? ""
        if !searchedLocation.isEmpty {
            delegate?.didSelectLocation(searchedLocation)
        } else {
            delegate?.didSelectLocation("")
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func requestToJoinBtn(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RequestVC") as? RequestVC {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
    }
    
    
    //MARK: - Helper Functions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       searchBar.resignFirstResponder()
       guard let searchText = searchBar.text, !searchText.isEmpty
        else {
           return
         }
        let filter = GMSAutocompleteFilter()
        filter.types = ["address"]
        let sessionToken = GMSAutocompleteSessionToken.init() 
        let placesClient = GMSPlacesClient.shared()
        placesClient.findAutocompletePredictions(fromQuery: searchText, filter: filter, sessionToken: sessionToken) { [weak self] (results, error) in
        guard let self = self
            else {
               return
        }
             if let error = error {
                print("Error in autocomplete: \(error.localizedDescription)")
                return
        }
              if let prediction = results?.first {
                  let placeID = prediction.placeID
                  let placesClient = GMSPlacesClient.shared()
                  placesClient.lookUpPlaceID(placeID) { [weak self] (place, placeError) in
              guard let self = self
                    else {
                        return
                    }
              if let placeError = placeError {
                    print("Error in place lookup: \(placeError.localizedDescription)")
                    return
              }
                      if let place = place {
                         let coordinate = place.coordinate
                         self.selectedMarker?.map = nil
                         self.selectedMarker = GMSMarker(position: coordinate)
                         self.selectedMarker?.title = place.name
                         self.selectedMarker?.map = self.detailMapView
                         let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 15)
                         self.detailMapView.animate(with: cameraUpdate)
                    }
                }
            }
        }
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let locationName = marker.title {
                delegate?.didSelectLocation(locationName)
                dismiss(animated: true, completion: nil)
            }
            return true
        }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
           let geocoder = GMSGeocoder()
           geocoder.reverseGeocodeCoordinate(coordinate) { [weak self] (response, error) in
               guard let self = self, let result = response?.firstResult() else {
                   return
            }
               let locationName = result.lines?.joined(separator: ", ") ?? ""
               self.delegate?.didSelectLocation(locationName)
               self.dismiss(animated: true, completion: nil)
           }
       }
   }
//    func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//   }
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse {
//           locationManager.startUpdatingLocation()
//      }
//   }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let userLocation = locations.last?.coordinate {
//            let camera = GMSCameraPosition.camera(withLatitude: userLocation.latitude, longitude: userLocation.longitude, zoom: 15)
//            detailMapView.camera = camera
//            locationManager.stopUpdatingLocation()
//          }
//      }
//  }
