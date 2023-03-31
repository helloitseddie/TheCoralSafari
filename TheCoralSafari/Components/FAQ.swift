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
    let image: UIImage
    let path: String
}

extension FAQ {
    static var FAQs: [FAQ] = [
        FAQ(title: "Lionfish FAQs", image: UIImage(named: "lionfish")!, path: "https://myfwc.com/fishing/saltwater/recreational/lionfish/"),
        FAQ(title: "Fishing", image: UIImage(named: "lionfish")!, path: "https://rushkult.com/eng/scubamagazine/how-to-hunt-lionfish-without-getting-hurt/"),
        FAQ(title: "Cleaning", image: UIImage(named: "lionpin")!, path: "https://www.youtube.com/watch?v=vqAhXceCYUk"),
        FAQ(title: "Cooking", image: UIImage(named: "lionpin")!, path: "https://lionfishcentral.org/resources/lionfish-recipes/"),
        FAQ(title: "Environment Impacts", image: UIImage(named: "lionfish")!, path: "https://www.fisheries.noaa.gov/southeast/ecosystems/impacts-invasive-lionfish"),
        FAQ(title: "About Us", image: UIImage(named: "lionfish")!, path: "https://www.eddieabriscoe.com/web/coral-safari"),
    ]
}
