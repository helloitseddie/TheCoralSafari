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
    
    func updateSearchResults(for searchController: UISearchController) {

        guard let text = searchController.searchBar.text else {return}

        searchLocation(addressL: text, delta: 5.0)
        updateMap()

    }
    
    
    
    func textFieldShouldReturn(_ searchController: UISearchController) -> Bool{
        
        print("Returned")
        
        searchController.resignFirstResponder()
        guard let text = searchController.searchBar.text else {return false}
        
        searchLocation(addressL: text, delta: 5.0)
        updateMap()
        
        return true
        
    }
    
    // map variable
    @IBOutlet weak var map: MKMapView!
    
    // manages getting location of the device
    let locationManager = CLLocationManager()
    
    
    
    
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
        
        /* I commented out this code so that it is easier
           to test the simulator for update location button */
        //locationManager.startUpdatingLocation()
        
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
            
            
                // Creating a label for the lionfish info so that a longer subtitle fits
                let subtitleView = UILabel()
                subtitleView.numberOfLines = 0
                subtitleView.text = annotation.subtitle!
                annotationView!.detailCalloutAccessoryView = subtitleView

            
        }else{
            // sets the view's annotaton to the annotation passed into the method
            annotationView?.annotation = annotation
        }
        
        if annotation.title == "User Searched Location"{
            annotationView?.image = UIImage(named: "Red Circle")
        }
        else if annotation.title == "Lionfish Here"{
            annotationView?.image = UIImage(named: "lionfish")
        }
   
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
            
            // create a pin on the user's location
            searchPin(location.coordinate)
        }
    }
    
    func render(_ location: CLLocation){
        
        // sets the region of the map to be around the user's location
        // span = how far should the map camera show ?
        map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
        
        // sends any messages from map to self
        map.delegate = self
    }
    
    func addPin(_ coordinate: CLLocationCoordinate2D, depth: String, count: String, notes: String){
        
        // point annotation is used when all that is needed is the title and subtitle
        let pin = MKPointAnnotation()
        
        let message = "Depth: \(depth) \nCount: \(count) \nNotes: \(notes)"
        
        pin.coordinate = coordinate
        pin.title = "Lionfish Here"
        pin.subtitle = message
        
        // adds the created pin to the map.
        map.addAnnotation(pin)
    }
    
    //Makes a pin for the user searched location
    func searchPin(_ coordinate: CLLocationCoordinate2D){
        
        // point annotation is used when all that is needed is the title and subtitle
        let pin = MKPointAnnotation()

        pin.coordinate = coordinate
        pin.title = "User Searched Location"
        
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
            
            
            // modal screen showing confirm cancel
            let pinAlert = UIAlertController(title: "Lionfish Found", message: "This action will place a lionfish pin. Please input the following:", preferredStyle: UIAlertController.Style.alert)

            pinAlert.addTextField { (textField) in
                textField.placeholder = "Water Depth"
            }
            pinAlert.addTextField { (textField) in
                textField.placeholder = "Number of Lionfish"
            }
            pinAlert.addTextField { (textField) in
                textField.placeholder = "Notes"
            }
            
            pinAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                  print("User confirmed placing pin")
                
                let depthTextField = pinAlert.textFields![0]
                let depthText = depthTextField.text
                
                let numFishTextField = pinAlert.textFields![1]
                let numFishText = numFishTextField.text
                
                let notesTextField = pinAlert.textFields![2]
                let notesText = notesTextField.text
                
                if depthText!.isEmpty || numFishText!.isEmpty {
                    
                    if depthText!.isEmpty{
                        depthTextField.layer.borderColor = UIColor.red.cgColor
                        depthTextField.layer.borderWidth = 1
                    }
                    if numFishText!.isEmpty{
                        numFishTextField.layer.borderColor = UIColor.red.cgColor
                        numFishTextField.layer.borderWidth = 1
                    }
                    self.present(pinAlert, animated: true, completion: nil)
                }else{
                    // add the pin to the map
                    self.addPin(touchMapCoordinate, depth: depthText!, count: numFishText!, notes: notesText!)
                }
            }))

            pinAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                  print("User canceled placing pin")
            }))

            present(pinAlert, animated: true, completion: nil)
            
          
            
        }
    }
    
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
    
    // This action centers the map on user's location on button tap
    @IBAction func didTapUpdateLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    
}

