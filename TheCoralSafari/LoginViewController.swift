//
//  ViewController.swift
//  TheCoralSafari
//
//  Created by Eddie Briscoe on 2/1/23.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var smallButton: UIButton!
    @IBOutlet weak var prompt: UILabel!
    @IBOutlet weak var bigButton: UIButton!
    
    var isSignup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessage.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        guard let safeLogin = defaults.object(forKey: "isLoggedIn") as? Bool else { return }
        if safeLogin {
            loadApp()
        }
    }
    
    func loadApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "StartPage") as? UITabBarController else {
            fatalError("Failed to instantiate tab bar controller")
        }
        tabBarController.selectedIndex = 0
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }
    
    @IBAction func bigButton(_ sender: UIButton) {
        if !isSignup {
            guard let safeUser = username.text else { return }
            guard let safePass = password.text else { return }
            
            let url = URL(string: "https://us-east1-portfolio-bd41c.cloudfunctions.net/api/users")!
            
            // Define the JSON data you want to post
            let json: [String: Any] = [
                "username": safeUser,
                "password": safePass,
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: json)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let safeData = data else { return }
                let decoder = JSONDecoder()
                let responseData = try! decoder.decode(ServerResponse.self, from: safeData)
                if !responseData.dataMatches {
                    DispatchQueue.main.async {
                        self.errorMessage.text = responseData.errorMessage
                    }
                } else {
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "isLoggedIn")
                    defaults.set(safeUser, forKey: "username")
                    defaults.synchronize()
                    DispatchQueue.main.async {
                        self.loadApp()
                    }
                }
            }
            task.resume()
        } else {
            guard let safeUser = username.text else { return }
            guard let safePass = password.text else { return }
            
            let url = URL(string: "https://us-east1-portfolio-bd41c.cloudfunctions.net/api/newUser")!
            
            // Define the JSON data you want to post
            let json: [String: Any] = [
                "username": safeUser,
                "password": safePass,
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: json)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let safeData = data else { return }
                let decoder = JSONDecoder()
                let responseData = try! decoder.decode(ServerResponse.self, from: safeData)
                if !responseData.dataMatches {
                    DispatchQueue.main.async {
                        self.errorMessage.text = responseData.errorMessage
                    }
                } else {
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "isLoggedIn")
                    defaults.set(safeUser, forKey: "username")
                    defaults.synchronize()
                    DispatchQueue.main.async {
                        self.loadApp()
                    }
                }
            }
            task.resume()
        }
    }
    
    @IBAction func smallButton(_ sender: UIButton) {
        isSignup = !isSignup
        if isSignup {
            prompt.text = "Please Sign Up!"
            bigButton.setTitle("Sign Up", for: .normal)
            smallButton.setTitle("Log In", for: .normal)
        } else {
            prompt.text = "Please Log In!"
            bigButton.setTitle("Log In", for: .normal)
            smallButton.setTitle("Sign Up", for: .normal)
        }
    }
    
}

struct ServerResponse: Decodable {
    let dataMatches: Bool
    let errorMessage: String
}

