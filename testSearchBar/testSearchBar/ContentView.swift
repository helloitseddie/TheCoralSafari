//
//  ViewController.swift
//  testSearch
//
//  Created by Matthew Duyvelaar on 2/14/23.
//

import UIKit
import SwiftUI
import MapKit

struct ContentView:View{
    @StateObject private var mapAPI = MapAPI()
    @State private var text = ""
    
    var body: some View{
        VStack{
            TextField("Enter an address", text: $text)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("Find address"){
                mapAPI.getLocation(address: text, delta: 0.5)
            }
            Map(coordinateRegion: $mapAPI.region, annotationItems: mapAPI.locations){
                location in
                MapMarker(coordinate: location.coordinate, tint: .blue)
            }
            .ignoresSafeArea()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
