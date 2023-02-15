//
//  ViewController.swift
//  TheCoralSafari
//
//  Created by Rachel Quijano, Mathew Duyvelaar, Renier Daniel Luces
//

import UIKit

// Map functionality
import MapKit

// Locations
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // map variable
    @IBOutlet weak var map: MKMapView!
    
    // manages getting location of the device
    let locationManager = CLLocationManager()
    
    let searchController = UISearchController(searchResultsController: nil)

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        
        view.backgroundColor = .white
    
    }
    
    
    // When the view appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // how precise we want the accuracy from the location GPS
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //can influence battery
        // messages from location manager sent to self
        locationManager.delegate = self
        // requests authorization from user to get location
        locationManager.requestWhenInUseAuthorization()
        // updates location based on user's location
        locationManager.startUpdatingLocation()
        
    }

    // Creates a view for the given annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // pin annotation is not the user's current location
        guard !(annotation is MKUserLocation) else{
            return nil
        }
        
        // creating a custom annotation view
        var annotationView = map.dequeueReusableAnnotationView(withIdentifier: "custom")
    
        if annotationView == nil {
            // create the view
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            
            annotationView?.canShowCallout = true
            
            // customize further here as needed
            
            // example thing to add: annotationView?.rightAnchor
            
        }else{
            // sets the view's annotaton to the annotation passed into the method
            annotationView?.annotation = annotation
        }
    
        annotationView?.image = UIImage(named: "lionfish")
            
        return annotationView
    }

   
   // this function is called when the manager does startUpdatingLocation()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if a location has been found
        if let location = locations.first{
            
            // stop updating the location
            locationManager.stopUpdatingLocation()
            
            // render the map with the given location
            render(location)
        }
    }
    
    func render(_ location: CLLocation){
        
        // sets the region of the map to be around the user's location
        // span = how far should the map camera show ?
        map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
        
        // sends any messages from map to self
        map.delegate = self
    }
    
    func addPin(_ coordinate: CLLocationCoordinate2D){
        
        // point annotation is used when all that is needed is the title and subtitle
        let pin = MKPointAnnotation()
        
        pin.coordinate = coordinate
        pin.title = "Lionfish Here"
        pin.subtitle = "Verified Lionfish Location"
        
        // adds the created pin to the map.
        map.addAnnotation(pin)
    }
    
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        
        // if the long press has ended
        if sender.state == UIGestureRecognizer.State.ended {
            
            // create a point of touch
            let point: CGPoint = sender.location(in: map)
            
            // convert it into a longitude/latitude
            let touchMapCoordinate: CLLocationCoordinate2D = map.convert(point, toCoordinateFrom: map)
            
            // add the pin to the map
            addPin(touchMapCoordinate)
            
        }
    }
    
    
}

