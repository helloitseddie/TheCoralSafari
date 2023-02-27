//
//  ViewController.swift
//  TheCoralSafari
//
//  Created by Rachel Quijano, Mathew Duyvelaar, Renier Daniel Luces
//

import UIKit
import SwiftUI
// Map functionality
import MapKit
// Locations
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchControllerDelegate, UISearchResultsUpdating{
    
    private let BASE_URL = "http://api.positionstack.com/v1/forward"
    private let API_KEY = "0bf2b1aeb4c7e8c2f89b5614d10b73ea"
    
    @Published var region: MKCoordinateRegion!
    @Published var coordinates = []
    @Published var locations: [location] = []
    
    //##############################################################################################################################
    //Search Function
    
    //Constantly updates map while typing in address | Needs to be updated only when return is pressed
    func updateSearchResults(for searchController: UISearchController) {

        guard let text = searchController.searchBar.text else {return}
        print(text)

        searchLocation(addressL: text, delta: 5.0)
        updateMap()

    }
    
    //Non functional function that should update map oly when return is pressed
//    func textFieldShouldReturn(_ searchController: UISearchController) -> Bool{
//
//        print("Returned")
//
//        searchController.resignFirstResponder()
//        guard let text = searchController.searchBar.text else {return false}
//
//        searchLocation(addressL: text, delta: 5.0)
//        updateMap()
//
//        return true
//
//    }
    
    // map variable
    @IBOutlet weak var map: MKMapView!
    
    // manages getting location of the device
    let locationManager = CLLocationManager()
    
    //##############################################################################################################################
    //Standard functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let search = UISearchController(searchResultsController: nil)
        search.delegate = self
        search.searchResultsUpdater = self
        search.searchBar.returnKeyType = .done
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Enter location or coordinates"
        navigationItem.searchController = search
        
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
    
    //##############################################################################################################################
    //PIN DETAILS

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
        
        if annotation.title != "Lionfish Here"{
            annotationView?.image = UIImage(named: "Red Circle")
        }
        else{
            annotationView?.image = UIImage(named: "lionfish")
        }
   
        return annotationView
    }
    
    //##############################################################################################################################
    //MAP
   
    //This function is called when the manager does startUpdatingLocation()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if a location has been found
        if let location = locations.first{
            
            // stop updating the location
            locationManager.stopUpdatingLocation()
            
            // render the map with the given location
            render(location)
        }
    }
    
    //Sets region of the map
    func render(_ location: CLLocation){
        
        // sets the region of the map to be around the user's location
        // span = how far should the map camera show ?
        map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
        
        // sends any messages from map to self
        map.delegate = self
    }
    
    //##############################################################################################################################
    //PINS
    
    //Makes a pin for a lionfish location
    func addPin(_ coordinate: CLLocationCoordinate2D){
        
        // point annotation is used when all that is needed is the title and subtitle
        let pin = MKPointAnnotation()
        
        pin.coordinate = coordinate
        pin.title = "Lionfish Here"
        pin.subtitle = "Verified Lionfish Location"
        
        // adds the created pin to the map.
        map.addAnnotation(pin)
    }
    
    //Makes a pin for the user searched location
    func searchPin(_ coordinate: CLLocationCoordinate2D){
        
        // point annotation is used when all that is needed is the title and subtitle
        let pin = MKPointAnnotation()

        pin.coordinate = coordinate
        pin.title = locations[0].name
        //pin.title = "User Searched Location"
        
        // adds the created pin to the map.
        map.addAnnotation(pin)
    }

    //This function is what allows users to long press the screen to create a pin
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
    
    //##############################################################################################################################
    //SEARCH BAR API + MAP
    
    //Changes Map Location upon entering search bar
    func updateMap(){

        if !coordinates.isEmpty{
            let latitude:Double = coordinates[0] as! Double
            let longitude:Double = coordinates[1] as! Double
            map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
            searchPin(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        
    }
    
    //API Search of address
    func searchLocation(addressL: String, delta:Double){
        
        let pAddress = addressL.replacingOccurrences(of: " ", with: "%20")
        let url_string = "\(BASE_URL)?access_key=\(API_KEY)&query=\(pAddress)"
        
        guard let url = URL(string: url_string) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url){ (data, response, error) in
            guard let data = data else {
                print(error!.localizedDescription)
                return
            }
            
            guard let newCoordinates = try? JSONDecoder().decode(address.self, from: data) else {return}
            
            if newCoordinates.data.isEmpty{
                print("Could not find address...")
                return
            }
            
            DispatchQueue.main.async {
                
                let details = newCoordinates.data[0]
                let lat = details.latitude
                let lon = details.longitude
                let name = details.name
                
                self.coordinates = [lat,lon]
                self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
                let new_location = location(name: name, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                
                self.locations.removeAll()
                self.locations.insert(new_location, at: 0)
                
                //print("Successfully loaded the location!")
            }
            
        }.resume()
            
    }
    
}

