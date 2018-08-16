//
//  ViewController.swift
//  Doordash
//
//  Created by Utsha Guha on 8/13/18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import UIKit
import MapKit

struct ConstantString {
    static let kCurrentLocationPinTitle                     = "Current Location"
    static let kBlank                                       = ""
    static let kNoRecordTitle                               = "No Record Found"
    static let kNoRecordMessage                             = "No nearby restaurants found for this location."
    static let kAlert                                       = "Alert"
    static let kSegueId                                     = "ShowRestaurants"
    static let kAddressKey                                  = "address"
    static let kLatitudeKey                                 = "lat"
    static let kLongitudeKey                                = "lng"
    static let kCoordinateKey                               = "coordinate"
    static let kTitleKey                                    = "title"
    static let kNameKey                                     = "name"
    static let kSubtitleKey                                 = "subtitle"
    static let kDescriptionKey                              = "description"
    static let kCoverImageKey                               = "cover_img_url"
    static let kASAPTimeKey                                 = "asap_time"
    static let kDeliveryFeeKey                              = "delivery_fee"
    static let kFreeDeliveryKey                             = "Free delivery"
    static let kImageKey                                    = "image"
    static let kNavigatorImage                              = "nav-address@2x"
    static let kCellId                                      = "restCellId"
    static let kMapLocDistance                              = 5000
    
}

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var addressField: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    let locManager = CLLocationManager()
    let regionRadius: CLLocationDistance = CLLocationDistance(ConstantString.kMapLocDistance)
    var currentLocation: CLLocation!
    var selectedLocation:CLLocationCoordinate2D?
    var nearbyRestaurants:[[String:Any]]?
    var searchedPlaceArray:[Any] = []
    var imageArray:[UIImage] = []
    
    
    var tmpNearbyRest:[[String:Any]] = []
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.markCurrentLocationForInitialLoad()
        self.addGestureControlFunctionalityOnMap()
        
        let yourBackImage = UIImage(named: ConstantString.kNavigatorImage)
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
    }
    
    /********   Initial Setup: Begin   ********/
    func markCurrentLocationForInitialLoad() {
        self.confirmButton.isEnabled = false
        self.myActivityIndicator.isHidden = false
        self.addAnnotation(locCoordinate: self.getCurrentLocationCoordinate(), title:ConstantString.kCurrentLocationPinTitle, subTitle: ConstantString.kBlank)
        self.getLocationFromCoordinates(coordinate: self.getCurrentLocationCoordinate())
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.getCurrentLocationCoordinate(),
                                                                  self.regionRadius, self.regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addGestureControlFunctionalityOnMap() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPressGesture)
    }
    
    func getCurrentLocationCoordinate() -> CLLocationCoordinate2D {
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingHeading()
        currentLocation = locManager.location
        let initialLocation = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        return initialLocation.coordinate
    }
    /********   Initial Setup: End   ********/
    
    /********   Long Press on Map: Start   ********/
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            for currentAnnotation in mapView.annotations{
                mapView.removeAnnotation(currentAnnotation)
            }
            
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            self.selectedLocation = coordinate
            self.getLocationFromCoordinates(coordinate: self.selectedLocation!)
            self.findNearbyRestaurants(completion: {
                self.dropPinOnNearbyRestaurants()
                self.downloadImage()
                self.myActivityIndicator.isHidden = true
            })
        }
    }
    /********   Long Press on Map: End   ********/
    
    /********   Find nearby restaurants: Start   ********/
    func findNearbyRestaurants(completion: @escaping ()->Void) {
        if (self.myActivityIndicator != nil) {
            self.myActivityIndicator.isHidden = false
        }
        self.searchedPlaceArray.removeAll()
        let urlString:String = "https://api.doordash.com/v1/store_search/?lat=\(self.selectedLocation!.latitude)&lng=\(self.selectedLocation!.longitude)"
        let myUrl = URL(string:urlString)
        let request = URLRequest(url:myUrl!)
        
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if error == nil{
                DispatchQueue.main.async {
                    self.confirmButton.isEnabled = true
                }
                self.nearbyRestaurants = try! JSONSerialization.jsonObject(with: data!, options: []) as? [[String : Any]]
                if self.nearbyRestaurants?.count == 0 {
                    self.showAlert(heading: ConstantString.kNoRecordTitle, message: ConstantString.kNoRecordMessage, buttonTitle: ConstantString.kAlert)
                    return
                }
                else{
                    for nearbyRest in self.nearbyRestaurants!{
                        let nearbyDict = nearbyRest
                        let addressDict = nearbyDict[ConstantString.kAddressKey] as! [String:Any]
                        let latitude = addressDict[ConstantString.kLatitudeKey]
                        let longitude = addressDict[ConstantString.kLongitudeKey]
                        let restCoordinate = CLLocationCoordinate2D.init(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
                        self.searchedPlaceArray.append([ConstantString.kCoordinateKey:restCoordinate,ConstantString.kTitleKey:nearbyDict[ConstantString.kNameKey]! as! String,ConstantString.kSubtitleKey:nearbyDict[ConstantString.kDescriptionKey]! as! String])
                    }
                }
            }
            else{
                self.showAlert(heading: ConstantString.kNoRecordTitle, message: ConstantString.kNoRecordMessage, buttonTitle: ConstantString.kAlert)
                return
            }
            completion()
        }
        task.resume()
    }
    /********   Find nearby restaurants: End   ********/
    
    /********   Drop pin and download image for all the nearby locations: Start   ********/
    func dropPinOnNearbyRestaurants() {
        for searchedLoc in self.searchedPlaceArray{
            let loc:[String:Any] = searchedLoc as! [String : Any]
            self.addAnnotation(locCoordinate: loc[ConstantString.kCoordinateKey] as! CLLocationCoordinate2D, title:loc[ConstantString.kTitleKey] as! String, subTitle:loc[ConstantString.kSubtitleKey] as! String)
            
        }
        let lastObject:[String:Any] = self.searchedPlaceArray.last as! [String : Any]
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(lastObject[ConstantString.kCoordinateKey] as! CLLocationCoordinate2D,
                                                                  self.regionRadius, self.regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func downloadImage() {
        self.tmpNearbyRest.removeAll()
        for var nearbyRest in self.nearbyRestaurants!{
            var tmpRst:[String:Any] = nearbyRest
            let posterURL = nearbyRest[ConstantString.kCoverImageKey] as? String
            let myUrl = URL(string:posterURL!)
            let request = URLRequest(url:myUrl!)
            self.imageArray.removeAll()
            let task = URLSession.shared.dataTask(with: request){
                (data, response, error) in
                if error == nil{
                    let image : UIImage = UIImage(data: data!)!
                    self.imageArray.append(image)
                    tmpRst[ConstantString.kImageKey] = image
                    self.tmpNearbyRest.append(tmpRst)
                }
            }
            task.resume()
            
        }
    }
    /********   Drop pin and download image for all the nearby locations: End   ********/
    
    
    /********   Drop Pin: Begin   ********/
    func addAnnotation(locCoordinate:CLLocationCoordinate2D, title:String, subTitle:String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoordinate
        annotation.title = title
        annotation.subtitle = subTitle
        mapView.addAnnotation(annotation)
    }
    /********   Drop Pin: End   ********/
    
    /********   Get street address from tabbed location: Begin   ********/
    func getLocationFromCoordinates(coordinate: CLLocationCoordinate2D) {
        let selectedLoc = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(selectedLoc,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil {
                                                    let firstLocation = placemarks?[0]
                                                    self.addressField.text = firstLocation?.name!
                                                }
                                                else {
                                                    self.addressField.text = ConstantString.kBlank
                                                }
                                                self.myActivityIndicator.isHidden = true
            })
    }
    
    /********   Get street address from tabbed location: End   ********/
    
    /********   Open List view: Begin   ********/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ConstantString.kSegueId {
            if let destination = segue.destination as? RestaurantsListViewController {
                destination.restaurantsList = self.tmpNearbyRest
            }
        }
    }
    /********   Open List view: End   ********/
    
}


