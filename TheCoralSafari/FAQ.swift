//
//  FAQ.swift
//  TheCoralSafari
//
//  Created by Daniel King on 3/7/23.
//

import Foundation
import UIKit

struct FAQ {
    let title: String
    let path: String
}

extension FAQ {
    static var FAQs: [FAQ] = [
        FAQ(title: "Lionfish FAQs", path: "https://www.google.com/"),
        FAQ(title: "Fishing", path: "https://www.google.com/"),
        FAQ(title: "Cleaning", path: "https://www.google.com/"),
        FAQ(title: "Cooking", path: "https://www.google.com/"),
        FAQ(title: "Environment Impacts", path: "https://www.google.com/"),
        FAQ(title: "About Us", path: "https://www.google.com/"),
    ]
}
