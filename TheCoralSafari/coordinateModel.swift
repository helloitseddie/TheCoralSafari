//
//  coordinateModel.swift
//  TheCoralSafari
//
//  Created by Matthew Duyvelaar on 2/21/23.
//

import Foundation
import MapKit

struct address: Codable{
    
    let data: [coordinate]
    
}

struct coordinate: Codable{
    
    let latitude, longitude: Double
    let name: String
    
}

struct location: Identifiable{
    
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    
}

