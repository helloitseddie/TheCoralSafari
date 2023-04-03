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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating{
       
    private let BASE_URL = "http://api.positionstack.com/v1/forward"
    private let API_KEY = "0bf2b1aeb4c7e8c2f89b5614d10b73ea"
    
    @Published var region: MKCoordinateRegion!
    @Published var coordinates = []
    @Published var locations: [location] = []
    
    func updateSearchResults(for searchController: UISearchController) {
        let allPins = map.annotations
        for x in allPins{
            if x.title == "User Searched Location" {
                print("Removing Location Pin")
                map.removeAnnotation(x)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        guard let text = searchBar.text else {return}
        
        searchLocation(addressL: text, delta: 5.0)
        //updateMap()
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
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activityIndicator.color = .orange
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        queryAllPinsFromServer()
        
        let search = UISearchController(searchResultsController: nil)
        search.delegate = self
        search.searchBar.delegate = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchResultsUpdater = self
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
        
        var annotationView: MKAnnotationView?
            
        if annotation.title == "User Searched Location" {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "searchedLocation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "searchedLocation")
            
            annotationView?.image = UIImage(named: "Search Pin")
        } else {
            annotationView = BottomAnchoredPinAnnotationView(annotation: annotation, reuseIdentifier: "lionfishLocation")
            
            annotationView?.canShowCallout = true
            
            annotationView?.image = UIImage(named: "lionpin")
            
            let subtitleView = UILabel()
            subtitleView.numberOfLines = 0
            subtitleView.text = annotation.subtitle!
            annotationView!.detailCalloutAccessoryView = subtitleView
            
        }
        
   
        return annotationView
    }
    
    func queryAllPinsFromServer() {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        let url = URL(string: "https://us-east1-portfolio-bd41c.cloudfunctions.net/api/pins")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let safeData = data else { return }
            print(safeData)
            let decoder = JSONDecoder()
            let pins = try! decoder.decode([Pin].self, from: safeData)
            DispatchQueue.main.async {
                self.map.removeAnnotations(self.map.annotations)
                for pin in pins {
                    self.addPin(coordinate: CLLocationCoordinate2D(latitude: pin.location.lat, longitude: pin.location.lon), title: pin.title, depth: pin.depth, count: pin.count, notes: pin.notes)
                }
                self.map.delegate = self
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
            }
        }
        task.resume()
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
    
    func addPin(coordinate: CLLocationCoordinate2D, title: String, depth: Int, count: Int, notes: String){
        
        // point annotation is used when all that is needed is the title and subtitle
        let pin = MKPointAnnotation()
        
        var message: String
        if notes == "" {
            message = "Depth: \(depth) \nCount: \(count)"
        } else {
            message = "Depth: \(depth) \nCount: \(count) \nNotes: \(notes)"
        }
        
        pin.coordinate = coordinate
        pin.title = title
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
    
    func uploadPinToDatabase(title: String, user: String, location: CLLocationCoordinate2D, depth: Int, count: Int, notes: String) {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        // Define the URL you want to post to
        let url = URL(string: "https://us-east1-portfolio-bd41c.cloudfunctions.net/api/pins")!

        // Define the JSON data you want to post
        let json: [String: Any] = [
            "title": title,
            "user": user,
            "location": [
                "lat": location.latitude,
                "lon": location.longitude
            ],
            "depth": depth,
            "count": depth,
            "notes": notes
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)

        // Create a URLRequest object with the URL and set the HTTP method to POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Set the request body to the JSON data
        request.httpBody = jsonData

        // Set the content type header to application/json
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create a URLSessionDataTask to send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
            }
        }
        task.resume()
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

            // adding text fields for lionfish info input
            pinAlert.addTextField { (textField) in
                textField.placeholder = "Pin Title"
            }
            pinAlert.addTextField { (textField) in
                textField.placeholder = "Water Depth"
            }
            pinAlert.addTextField { (textField) in
                textField.placeholder = "Number of Lionfish"
            }
            pinAlert.addTextField { (textField) in
                textField.placeholder = "Notes"
            }
            
            // confirm action
            pinAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in
                
                // gathering input
                let titleTextField = pinAlert.textFields![0]
                guard let titleText = titleTextField.text else { return }
                
                let depthTextField = pinAlert.textFields![1]
                guard let depthText = depthTextField.text else { return }
                guard let depthNum = Int(depthText) else {
                    let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid integer for depth. Avoid units such as 'ft' or 'm'", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                let numFishTextField = pinAlert.textFields![2]
                guard let numFishText = numFishTextField.text else { return }
                guard let numFish = Int(numFishText) else {
                    let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid integer for number of fish.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                let notesTextField = pinAlert.textFields![3]
                let notesText = notesTextField.text
                
                // if either input box is empty, outline it red and ask again
                if depthText.isEmpty || numFishText.isEmpty || titleText.isEmpty {
                    
                    if titleText.isEmpty{
                        titleTextField.layer.borderColor = UIColor.red.cgColor
                        titleTextField.layer.borderWidth = 1
                    }
                    if depthText.isEmpty{
                        depthTextField.layer.borderColor = UIColor.red.cgColor
                        depthTextField.layer.borderWidth = 1
                    }
                    if numFishText.isEmpty{
                        numFishTextField.layer.borderColor = UIColor.red.cgColor
                        numFishTextField.layer.borderWidth = 1
                    }
                    self.present(pinAlert, animated: true, completion: nil)
                } else {
                    let defaults = UserDefaults.standard
                    guard let safeUsername = defaults.object(forKey: "username") as? String else { return }
                    
                    self.uploadPinToDatabase(title: titleText, user: safeUsername, location: touchMapCoordinate, depth: depthNum, count: numFish, notes: notesText ?? "")
                    
                    // add the pin to the map with the info passed to the annotation
                    self.addPin(coordinate: touchMapCoordinate, title: titleText, depth: depthNum, count: numFish, notes: notesText!)
                    
                    print("User confirmed placing pin")
                }
            }))

            // cancel action
            pinAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                  print("User canceled placing pin")
            }))

            // show alert view
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
                
                print("Successfully loaded the location!")
                self.updateMap()
            }
            
        }.resume()
        //updateMap()
    }
    
    // This action centers the map on user's location on button tap
    @IBAction func didTapUpdateLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    
}

class BottomAnchoredPinAnnotationView: MKAnnotationView {

    override var annotation: MKAnnotation? {
        didSet {
            // Set the pin image to a custom image with the bottom center anchor point
            self.image = UIImage(named: "lionpin")
            self.centerOffset = CGPoint(x: 0, y: -self.image!.size.height/2)
        }
    }
    
}
