//
//  SignUpViewController.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 5/21/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController, UITextFieldDelegate {

    //variables
    var db: Firestore!
    var usernames: [String] = [String]()
    
    //outlets
    @IBOutlet weak var signupPassword: UITextField!
    @IBOutlet weak var signupEmail: UITextField!
    @IBOutlet weak var signupUsername: UITextField!
    @IBOutlet weak var errorLabel1: UILabel!
    @IBOutlet var backGround1: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegates
        self.signupUsername?.delegate = self
        self.signupEmail?.delegate = self
        self.signupPassword?.delegate = self
       
        //initialize firebase
        db = Firestore.firestore()
        
        //load list of usernames
        getUsernames()
    }
    
    //actions
    @IBAction func signUpButton(_ sender: Any) {
        
        //make sure its not blank
        if self.signupPassword.text == "" || self.signupEmail.text == "" || self.signupUsername.text == "" {
            errorLabel1.text = "Please fill in all fields."
        } else {
            //sign up
            signUp(email: signupEmail.text!, password: signupPassword.text!, username: signupUsername.text!) {
                //perform segue
                self.performSegue(withIdentifier: "imagePickerSegue", sender: self)
            }
        }
        
        
    }

    //functions
    func getUsernames(){
        db.collection("usernames").document("usernames").getDocument { (document, error) in
            if let document = document {
                self.usernames = document["username"] as? Array ?? [""]
                print("usernames \(self.usernames)")
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
    
    func logIn(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, Error) in
            
            //if user exists... sign in
            if user != nil
            {
                
            }
                
                //if user does not exist, show error
            else
            {
                if let myError = Error?.localizedDescription
                {
                    self.errorLabel1.text = myError
                }
                else
                {
                    print("ERROR")
                }
            }
        })
        
    }
    
    func signUp(email: String, password: String, username: String, completion1: @escaping () -> ()) {
        
        //check if user exists
        if self.usernames.contains(username) == true {
            self.errorLabel1.text = "Username is taken. Please try a different one."
        } else {
            //if user does not exist, sign up
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, Error) in
                if user != nil
                {
                    let UID = user?.user.uid
                    
                    //create user object
                    let newUser = User(UID: UID!, username:username, score:0, imageString:"", posts:[DocumentReference](), likes:[DocumentReference](), promotedPosts: [DocumentReference](), dislikes:[DocumentReference](), ref: self.db.collection("users").document(UID!), comments: [DocumentReference]())
                    
                    //add to database
                    self.db.collection("users").document(UID!).setData(newUser.dictionary){
                        error in
                        
                        if let error = error {
                            print("error adding: \(error.localizedDescription)")
                        }
                        else {
                            print("document added")
                        }
                    }
                    
                    //add to username list
                    self.db.collection("usernames").document("usernames").updateData([
                        "username": FieldValue.arrayUnion([username])
                        ])
                    
                    //get user document
                    myUser = newUser
                    print(myUser)
                    
                    //login
                    self.logIn(email: email, password: password)
                    
                    //done
                    completion1()
                }
                    
                else
                {
                    if let myError = Error?.localizedDescription
                    {
                        self.errorLabel1.text = myError
                    }
                    else
                    {
                        print("ERROR")
                    }
                }
                
            })
        }
        
    }
        
    }

