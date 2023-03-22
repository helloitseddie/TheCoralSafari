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
        FAQ(title: "Lionfish FAQs", path: "https://myfwc.com/fishing/saltwater/recreational/lionfish/"),
        FAQ(title: "Fishing", path: "https://rushkult.com/eng/scubamagazine/how-to-hunt-lionfish-without-getting-hurt/"),
        FAQ(title: "Cleaning", path: "https://www.youtube.com/watch?v=vqAhXceCYUk"),
        FAQ(title: "Cooking", path: "https://lionfishcentral.org/resources/lionfish-recipes/"),
        FAQ(title: "Environment Impacts", path: "https://www.fisheries.noaa.gov/southeast/ecosystems/impacts-invasive-lionfish"),
        FAQ(title: "About Us", path: "https://www.eddieabriscoe.com/web/coral-safari"),
    ]
}
