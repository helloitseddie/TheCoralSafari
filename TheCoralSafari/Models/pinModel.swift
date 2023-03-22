//
//  File.swift
//  TheCoralSafari
//
//  Created by Eddie Briscoe on 3/20/23.
//

import Foundation

struct Pin: Decodable {
    let title: String
    let user: String
    let location: Location
    let depth: Int
    let count: Int
    let notes: String
    
    struct Location: Decodable {
        let lat: Double
        let lon: Double
    }
}
