//
//  ComposeViewController.swift
//  Sports Talk
//
//  Created by Joey Aberasturi on 5/12/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class ComposeViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //variables__________________________________________________________________________________________________________
    var db:Firestore!
    var postRef:DocumentReference? = nil
    var usersRef:DocumentReference? = nil
    var bottomConstraintConstant:CGFloat = 0.0
    var characterCount = 0
    let storageRef = Storage.storage().reference()
    var postedImageString = ""
    
    //outlets__________________________________________________________________________________________________________
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var switchOutlet: UISwitch!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var aboveKeyBoardView: UIView!
    @IBOutlet var removeButtonOutlet: UIButton!
    
    @IBOutlet var imageCommentWidth: NSLayoutConstraint!
    //main ____________________________________________________________________________________________________________
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        //declare database
        db = Firestore.firestore()
        usersRef = db.collection("users").document(myUser.UID)
        textView.delegate = self
        
        //set bottom constraint
        self.bottomConstraintConstant = self.bottomConstraint.constant
        
        //keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //make things look nice
        characterCountLabel.text = "0/150"
        textView.text = "Type your thoughts..."
        textView.textColor = UIColor.gray
        viewHeightConstraint.constant = 0
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        
        removeButtonOutlet.setImage(Images.delete, for: .normal)
        removeButtonOutlet.imageView?.contentMode = .scaleAspectFit
        //removeButtonOutlet.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        
    }

    
    //functions
    @objc private func keyboardWillShow(notification:Notification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            self.bottomConstraint.constant = keyboardSize.cgRectValue.height + 10
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification:Notification) {
            self.bottomConstraint.constant = self.bottomConstraintConstant
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
    }
    
  
    
    func textViewDidChange(_ textView: UITextView) {
        characterCount = textView.text.count
        characterCountLabel.text = "\(characterCount)/150"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor != UIColor.black {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            
            UIView.animate(withDuration: 0.2) {
                self.viewHeightConstraint.constant = 250
                self.imageView.image = selectedImage
                var aspectRatio = selectedImage.size.width / selectedImage.size.height
                self.imageCommentWidth.constant = 250 * aspectRatio
            }
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func postImage(ID: String, completion1: @escaping () -> ()){
        
        //get image name
        let imageName = NSUUID().uuidString
        
        //storage location
        let storedImage = storageRef.child("post_images").child(ID)
        if let uploadData = self.imageView.image!.pngData()
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
                        //update imageString for post
                        self.db.collection("posts").document(ID).updateData([
                            "imageString": urlText
                            ])
                        
                        //done
                        completion1()
                    }
                })
                
            })
        }
    }
    
        func hideKeyboardWhenTappedAround() {
            
            let scroll: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
            scroll.direction = UISwipeGestureRecognizer.Direction.down
            scroll.cancelsTouchesInView = false
            textView.addGestureRecognizer(scroll)
            aboveKeyBoardView.addGestureRecognizer(scroll)
            
        }
        
        @objc func dismissKeyboard() {
            view.endEditing(true)
            
            if textView.text == "" {
                textView.text = "Type your thoughts..."
                textView.textColor = UIColor.gray
            }
            
        }
    

    func donePosting() {
        //make sure content is there
        if characterCount < 151 && (characterCount > 0 || imageView.image != nil) {
            //create Post object
            let newPost = Post(content: textView.text, user:usersRef!, score:0, timeStamp:Timestamp(), likes: [DocumentReference](), dislikes:[DocumentReference](), ID: "", commentCount: 0, isAnonymous: switchOutlet.isOn, imageString: "", ref: db.collection("posts").document("x"), sport: segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)!)
            
            
            
            //add the document to "posts"
            postRef = self.db.collection("posts").addDocument(data: newPost.dictionary) {
                error in
                
                if let error = error {
                    print("error adding: \(error.localizedDescription)")
                }
                else {
                    print("document added")
                }
            }
            //update id for post
            db.collection("posts").document(postRef!.documentID).updateData([
                "ID": postRef!.documentID
                ])
            
            //if there is an image
            if imageView.image != nil {
                
                //post the image
                postImage(ID: postRef!.documentID) {
                    
                    //leave the page
                    self.performSegue(withIdentifier: "doneComposingSegue", sender: self)
                }
                
            } else {
                //leave the page
                performSegue(withIdentifier: "doneComposingSegue", sender: self)
            }
            
            //add post to "users" database
            usersRef?.updateData([
                "posts": FieldValue.arrayUnion([db.collection("posts").document(postRef!.documentID)])
                ])
            
            //update ref
            db.collection("posts").document(postRef!.documentID).updateData([
                "ref": db.collection("posts").document(postRef!.documentID)
                ])
            
            //leave the page
            // performSegue(withIdentifier: "doneComposingSegue", sender: self)
        }
    }
        
        func donePostingPromoted() {
            //make sure content is there
            if characterCount < 151 && (characterCount > 0 || imageView.image != nil) {
                //create Post object
                let newPost = PromotedPost(content: textView.text, user:usersRef!, score:0, timeStamp:Timestamp(), likes: [DocumentReference](), dislikes:[DocumentReference](), ID: "", commentCount: 0, isAnonymous: switchOutlet.isOn, imageString: "", ref: db.collection("posts").document("x"), sport: segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)!, numViews: 0, numViewsPaidFor: 0, numClicks: 0, numLinkClicks: 0, link: "")
                
                //add the document to "posts"
                postRef = self.db.collection("promotedPosts").addDocument(data: newPost.dictionary) {
                    error in
                    
                    if let error = error {
                        print("error adding: \(error.localizedDescription)")
                    }
                    else {
                        print("document added")
                    }
                }
                //update id for post
                db.collection("promotedPosts").document(postRef!.documentID).updateData([
                    "ID": postRef!.documentID
                    ])
                
                //if there is an image
                if imageView.image != nil {
                    
                    //post the image
                    postImage(ID: postRef!.documentID) {
                        
                        //leave the page
                        self.performSegue(withIdentifier: "doneComposingSegue", sender: self)
                    }
                    
                } else {
                    //leave the page
                    performSegue(withIdentifier: "doneComposingSegue", sender: self)
                }
                
                //add post to "users" database
                usersRef?.updateData([
                    "posts": FieldValue.arrayUnion([db.collection("promotedPosts").document(postRef!.documentID)])
                    ])
                
                //update ref
                db.collection("promotedPosts").document(postRef!.documentID).updateData([
                    "ref": db.collection("promotedPosts").document(postRef!.documentID)
                    ])
                
                //leave the page
                // performSegue(withIdentifier: "doneComposingSegue", sender: self)
            }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? PromotePopUpViewController
       
        //create Post object
        let newPost = PromotedPost(content: textView.text, user:usersRef!, score:0, timeStamp:Timestamp(), likes: [DocumentReference](), dislikes:[DocumentReference](), ID: "", commentCount: 0, isAnonymous: switchOutlet.isOn, imageString: "", ref: db.collection("posts").document("x"), sport: segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)!, numViews: 0, numViewsPaidFor: 0, numClicks: 0, numLinkClicks: 0, link: "")
    
        vc?.post = newPost
        vc?.image = imageView.image
    }
    
    
    //actions __________________________________________________________________________________________________________
    
    
    @IBAction func anonymousSwitch(_ sender: Any) {
        if switchOutlet.isOn == true {
            userNameLabel.text = ""
        } else {
            userNameLabel.text = "-\(myUser.username)"
        }
    }
    
    @IBAction func imagePicker(_ sender: Any) {
        
        if textView.textColor != UIColor.black {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        //picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func removeButton(_ sender: Any) {
        imageView.image = nil
        viewHeightConstraint.constant = 0
        
    }
    
    @IBAction func postButton(_ sender: Any) {
       donePosting()
    }
    
    @IBAction func promoteButton(_ sender: Any) {
        if characterCount < 151 && (characterCount > 0 || imageView.image != nil) {
            self.performSegue(withIdentifier: "promotePopUpSegue", sender: nil)
        }
    }

}
