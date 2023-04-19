//
//  TutorialViewController.swift
//  TheCoralSafari
//
//  Created by Eddie Briscoe on 4/19/23.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var tapCount = 1
    let imageNames = ["tutorial1", "tutorial2", "tutorial3", "tutorial4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true

    }
    
    @objc func viewTapped() {
        // Handle the tap event here
        tapCount += 1
        if tapCount >= 5 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "StartPage") as? UITabBarController else {
                fatalError("Failed to instantiate tab bar controller")
            }
            tabBarController.selectedIndex = 0
            tabBarController.modalPresentationStyle = .fullScreen
            present(tabBarController, animated: true, completion: nil)
        }
        let imageName = imageNames[tapCount % imageNames.count]
        imageView.image = UIImage(named: imageName)
        print(tapCount)
    }

}
