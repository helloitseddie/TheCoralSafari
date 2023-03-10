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
}

extension FAQ {
    static var FAQs: [FAQ] = [
        FAQ(title: "Lionfish FAQs"),
        FAQ(title: "Fishing"),
        FAQ(title: "Cleaning"),
        FAQ(title: "Cooking"),
        FAQ(title: "Environment Impacts"),
        FAQ(title: "About Us"),
    ]
}
