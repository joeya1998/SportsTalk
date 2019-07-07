//
//  Login.swift
//  tabbedTest
//
//  Created by Joey Aberasturi on 1/15/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

var myUser: User!
var usersRef: DocumentReference!

class Login: UIViewController, UITextFieldDelegate {

    //variables
    var db: Firestore!
    var usernames:[String] = [String]()
    
    //outlets
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet var backGround: UIView!
    
    
    //main
    override func viewDidLoad() {
         super.viewDidLoad()
       
        //set up textViews
        self.emailText?.delegate = self
        self.passwordText?.delegate = self
        
        //initialize database
        db = Firestore.firestore()
        
        //for background change color
        //backGround?.setGradientBackground(colorOne: Colors.lightGreen, colorTwo: Colors.darkBlue)
        
    }

    //actions
    @IBAction func emailButton(_ sender: Any) {
        
        //make sure it is not blank
        if emailText.text != "" && passwordText.text != ""
        {
            //login in
            logIn(email: emailText.text!, password: passwordText.text!) {
                
                //perform segue
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let alertController = UIAlertController(title: "Forgot Password", message: "Please enter email address.", preferredStyle: .alert)
        
        //text field
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Email Address"
        }
        
        //OKAY
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
            self.changeEmail(email: alertController.textFields![0].text!)
        }))
        
        //Cancel
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
       
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //functions
    
    func changeEmail(email: String) {
        var auth = Auth.auth()
        
        auth.sendPasswordReset(withEmail: email) { (error) in
            if let error = error?.localizedDescription {
               let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Success!", message: "Email sent.", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    func getMyData(id: String){
        
        //get document
        db.collection("users").document(id).getDocument { (document, error) in
            
            //capture the document
            if let document = document, document.exists {
                
                //make the user object
                myUser = User(dictionary: document.data()!)
                print("user: \(myUser)")
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    //hide keyboard when user touches outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //hide keyboard when user touches return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
 
    func logIn(email: String, password: String, completion1: @escaping () -> ()) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, Error) in
        
            //if user exists... sign in
            if user != nil
            {
                var uid = user?.user.uid
                
                //get users document
                self.getMyData(id: uid!)
                
                //complete
                completion1()
            }
                
            //if user does not exist, show error
            else
            {
                if let myError = Error?.localizedDescription
                {
                    self.errorLabel.text = myError
                }
                else
                {
                    print("ERROR")
                }
            }
        })
        
    }
}

