//
//  AccountViewController.swift
//  TheCoralSafari
//
//  Created by Eddie Briscoe on 3/22/23.
//

import UIKit

class AccountViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var memberSince: UILabel!
    @IBOutlet weak var fishSpotted: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var pinsMarked: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let safeName = defaults.object(forKey: "username") as? String else { return }
        username.text = safeName
        
        getTimeSince()
        getUserStats()
    }
    
    func getTimeSince() {
        guard let safeName = defaults.object(forKey: "username") as? String else { return }
        
        // Define the URL you want to post to
        let url = URL(string: "https://us-east1-portfolio-bd41c.cloudfunctions.net/api/user")!

        // Define the JSON data you want to post
        let json: [String: Any] = [
            "username": safeName,
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
            // Handle the response here
            
            guard let safeData = data else { return }
            let decoder = JSONDecoder()
            let date = try! decoder.decode(MemberSince.self, from: safeData)
            DispatchQueue.main.async {
                self.memberSince.text = date.date
            }
        }
        task.resume()
    }
    
    func getUserStats() {
        guard let safeName = defaults.object(forKey: "username") as? String else { return }
        
        // Define the URL you want to post to
        let url = URL(string: "https://us-east1-portfolio-bd41c.cloudfunctions.net/api/userPins")!

        // Define the JSON data you want to post
        let json: [String: Any] = [
            "username": safeName,
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
            // Handle the response here
            
            guard let safeData = data else { return }
            let decoder = JSONDecoder()
            let info = try! decoder.decode(UserInfo.self, from: safeData)
            DispatchQueue.main.async {
                self.fishSpotted.text = String(info.numFish)
                self.pinsMarked.text = String(info.numPins)
            }
        }
        task.resume()
    }
    
    func sendToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginPage = storyboard.instantiateViewController(withIdentifier: "Login")
        
        loginPage.modalPresentationStyle = .fullScreen
        present(loginPage, animated: true, completion: nil)
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        defaults.set(false, forKey: "isLoggedIn")
        defaults.set("", forKey: "username")
        sendToLogin()
    }
}

struct MemberSince: Decodable {
    let date: String
}

struct UserInfo: Decodable {
    let numPins: Int
    let numFish: Int
}
