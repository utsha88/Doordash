//
//  DoordashTests.swift
//  DoordashTests
//
//  Created by Utsha Guha on 8/13/18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import XCTest
import MapKit
@testable import Doordash

class DoordashTests: XCTestCase,CLLocationManagerDelegate,MKMapViewDelegate {
    
    var vc = ViewController()
    var detailVC = RestaurantsListViewController()
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCurrentLocation() {
        let locManager = CLLocationManager()
        var currentLocation: CLLocation!
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingHeading()
        currentLocation = locManager.location
        XCTAssert((currentLocation.coordinate.latitude == vc.getCurrentLocationCoordinate().latitude) && (currentLocation.coordinate.longitude == vc.getCurrentLocationCoordinate().longitude), "Current location is not proper.")
    }
}
