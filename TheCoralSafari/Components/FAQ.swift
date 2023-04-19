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
        FAQ(title: "About Lionfish", image: UIImage(named: "Group_1")!, path: "https://myfwc.com/fishing/saltwater/recreational/lionfish/"),
        FAQ(title: "How to Fish", image: UIImage(named: "Group_2")!, path: "https://www.eddieabriscoe.com/ios/coral-safari/how-to-catch"),
        FAQ(title: "Learn to Fillet", image: UIImage(named: "Group_3")!, path: "https://www.eddieabriscoe.com/ios/coral-safari/how-to-clean"),
        FAQ(title: "Cooking", image: UIImage(named: "Group_4")!, path: "https://www.eddieabriscoe.com/ios/coral-safari/how-to-cook"),
        FAQ(title: "Global Impacts", image: UIImage(named: "Group_5")!, path: "https://www.fisheries.noaa.gov/southeast/ecosystems/impacts-invasive-lionfish"),
        FAQ(title: "More On Us", image: UIImage(named: "Group_6")!, path: "https://www.eddieabriscoe.com/web/coral-safari"),
    ]
}
