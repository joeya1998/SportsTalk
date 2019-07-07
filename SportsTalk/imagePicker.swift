//
//  imagePicker.swift
//  tabbedTest
//
//  Created by Joey Aberasturi on 4/11/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class imagePicker: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
    //variables
    let storageRef = Storage.storage().reference()
    let databaseRef = db.collection("users")
    var imageString = "user"

    //outlets
    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet var background: UIView!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userOneImage: UIImageView!
    @IBOutlet var userTwoImage: UIImageView!
    @IBOutlet var userThreeImage: UIImageView!
    @IBOutlet var userFourImage: UIImageView!
    
    
    //main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make it look nice
        imagePicker.layer.cornerRadius = imagePicker.frame.size.width/2
        imagePicker.clipsToBounds = true
        
        //avatar options
        userImage.makeCircle(image: Images.user!)
        userOneImage.makeCircle(image: Images.user1!)
        userTwoImage.makeCircle(image: Images.user2!)
        userThreeImage.makeCircle(image: Images.user3!)
        userFourImage.makeCircle(image: Images.user4!)
        
        //selction
        userImage.layer.borderColor = UIColor.blue.cgColor
        
    }

    //actions
    @IBAction func imageUpload(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func SignUp(_ sender: Any) {
        saveChanges {
            self.performSegue(withIdentifier: "signupSegue", sender: self)
            }
    }
    
   
    
    @IBAction func user(_ sender: Any) {
        userImage.layer.borderColor = UIColor.blue.cgColor
        userOneImage.layer.borderColor = UIColor.black.cgColor
        userTwoImage.layer.borderColor = UIColor.black.cgColor
        userThreeImage.layer.borderColor = UIColor.black.cgColor
        userFourImage.layer.borderColor = UIColor.black.cgColor
        imageString = "user"
    }
    
    @IBAction func userOne(_ sender: Any) {
        userImage.layer.borderColor = UIColor.black.cgColor
        userOneImage.layer.borderColor = UIColor.blue.cgColor
        userTwoImage.layer.borderColor = UIColor.black.cgColor
        userThreeImage.layer.borderColor = UIColor.black.cgColor
        userFourImage.layer.borderColor = UIColor.black.cgColor
        
        imageString = "user1"
    }

    @IBAction func userTwo(_ sender: Any) {
        userImage.layer.borderColor = UIColor.black.cgColor
        userOneImage.layer.borderColor = UIColor.black.cgColor
        userTwoImage.layer.borderColor = UIColor.blue.cgColor
        userThreeImage.layer.borderColor = UIColor.black.cgColor
        userFourImage.layer.borderColor = UIColor.black.cgColor
        
        imageString = "user2"
    }
    

    @IBAction func userThree(_ sender: Any) {
        userImage.layer.borderColor = UIColor.black.cgColor
        userOneImage.layer.borderColor = UIColor.black.cgColor
        userTwoImage.layer.borderColor = UIColor.black.cgColor
        userThreeImage.layer.borderColor = UIColor.blue.cgColor
        userFourImage.layer.borderColor = UIColor.black.cgColor
        
        
        imageString = "user3"
    }
    
    @IBAction func userFour(_ sender: Any) {
        userImage.layer.borderColor = UIColor.black.cgColor
        userOneImage.layer.borderColor = UIColor.black.cgColor
        userTwoImage.layer.borderColor = UIColor.black.cgColor
        userThreeImage.layer.borderColor = UIColor.black.cgColor
        userFourImage.layer.borderColor = UIColor.blue.cgColor
        
        
        imageString = "user4"
    }
    
    //functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            imagePicker.image = selectedImage
            imageString = "selected"
        }
        dismiss(animated: true, completion: nil)
    }
   
    func saveChanges(completion: () -> () ){
        
        if imageString == "selected" {
        
                //get image name
                let imageName = NSUUID().uuidString
        
                //storage location
                let storedImage = storageRef.child("profile_images").child(myUser.username)
                if let uploadData = self.imagePicker.image!.pngData()
                {
                    storedImage.putData(uploadData, metadata: nil, completion:  { (metadata, error) in
                        if error != nil{
                            print(error)
                            return
                        }
                        storedImage.downloadURL(completion: { (url, error) in
                            if error != nil{
                                print(error)
                                return
                            }
                            if let urlText = url?.absoluteString {
                                self.databaseRef.document(myUser.UID).updateData([
                                    "imageString": urlText
                                ])
                                myUser.imageString = urlText
                            }
                        })
                        
                    })
                    completion()
                }
        } else {
            self.databaseRef.document(myUser.UID).updateData([
                "imageString": imageString
                ])
            myUser.imageString = imageString
            completion()
        }
        
        
    }
 
    
    
    
}
