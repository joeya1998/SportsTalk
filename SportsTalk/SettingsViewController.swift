//
//  SettingsViewController.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 6/27/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SettingsViewController: UIViewController {

    
    @IBOutlet var emailText: UILabel!
    @IBOutlet var usernameText: UITextField!
    @IBOutlet var passwordText: UITextField!
    var usernames = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameText.text = myUser.username
        emailText.text = Auth.auth().currentUser?.email

    }
    
    func updateUsername() {
        let username: String! = usernameText.text
        
        getUsernames {
            
            //check if user exists
            if self.usernames.contains(username) == true {
                print("Username is taken. Please try a different one.")
            } else {
                myUser.changeUsername(newUsername: username)
                
            }
        }
        
    }

    
    @IBAction func save(_ sender: Any) {
        if usernameText.text != myUser.username {
            updateUsername()
        }
    
        let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
        
        mainTabController.selectedViewController = mainTabController.viewControllers?[3]
        
        self.present(mainTabController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func cancel(_ sender: Any) {
 
        let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
        
        mainTabController.selectedViewController = mainTabController.viewControllers?[3]
        
        self.present(mainTabController, animated: true, completion: nil)

    }
    

    //functions
    func getUsernames(completion: @escaping ()->()){
        db.collection("usernames").document("usernames").getDocument { (document, error) in
            if let document = document {
                self.usernames = document["username"] as? Array ?? [""]
                print("usernames \(self.usernames)")
            } else {
                print("Document does not exist")
            }
            completion()
        }
        
    }
    
}

class changePasswordViewController: UIViewController {
    @IBOutlet var currentPassword: UITextField!
    @IBOutlet var newPassword: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updatePassword() {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: currentPassword.text!)
        
        user?.reauthenticate(with: credential, completion: { (nil, error) in
            if let error = error?.localizedDescription {
                self.errorLabel.text = "\(error)"
            } else {
                user?.updatePassword(to: self.newPassword.text!, completion: { (error) in
                    if let error = error?.localizedDescription {
                        self.errorLabel.text = "\(error)"
                    } else {
                        let mainTabController = self.storyboard?.instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
                        
                        mainTabController.selectedViewController = mainTabController.viewControllers?[1]
                        
                        self.present(mainTabController, animated: true, completion: nil)
                    }
                })
            }
        })
        
    }
    
    
    @IBAction func changePassword(_ sender: Any) {
        if newPassword.text == confirmPassword.text {
            updatePassword()
        } else {
            errorLabel.text = "Passwords do not match."
        }
        
    }
    
}
