//
//  PromotePopUpViewController.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 6/26/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class PromotePopUpViewController: UIViewController {

    @IBOutlet var popUpView: UIView!
    @IBOutlet var pointSlider: UISlider!
    @IBOutlet var pointCount: UILabel!
    @IBOutlet var viewCount: UILabel!
    @IBOutlet var viewSlider: UISlider!
    @IBOutlet var linkText: UITextView!
    
    var post: PromotedPost!
    var costPerView: Float = 0.5
    var image: UIImage!
    var viewNum = 0
    var pointNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //declare database
        db = Firestore.firestore()
        usersRef = db.collection("users").document(myUser.UID)
        
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
        viewSlider.minimumValue = 0
        viewSlider.maximumValue = 100
        pointSlider.minimumValue = 0
        pointSlider.maximumValue = 100
        
    }
    
    @IBAction func viewSliderAction(_ sender: Any) {
        viewNum = Int(viewSlider.value.rounded())
        pointNum = Int((viewSlider.value * costPerView).rounded())
        
        viewCount.text = "\(viewNum)"
        pointSlider.setValue((viewSlider.value * costPerView), animated: true)
        pointCount.text = "\(pointNum)"
    }
    
    @IBAction func pointSliderAction(_ sender: Any) {
        pointNum = Int(pointSlider.value.rounded())
        viewNum = Int((pointSlider.value * costPerView).rounded())
        
        pointCount.text = "\(pointNum)"
        viewSlider.setValue((pointSlider.value * costPerView), animated: true)
        viewCount.text = "\(viewNum)"
    }
    
    @IBAction func finished(_ sender: Any) {
        post.numViewsPaidFor = viewNum
        let input = linkText.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let link = (input.hasPrefix("https://") || input.hasPrefix("http://") ? linkText.text : "http://" + linkText.text)
        post.link = (link?.trimmingCharacters(in: .whitespacesAndNewlines))!
        print(post.numViewsPaidFor)
        donePostingPromoted()
       
        
    }
    
    func donePostingPromoted() {
        
        
            //add the document to "posts"
            postRef = db.collection("promotedPosts").addDocument(data: post.dictionary) {
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
            if image != nil {
                
                //post the image
                postImage(ID: postRef!.documentID) {
                    
                    //leave the page
                    self.performSegue(withIdentifier: "donePromotingSegue", sender: self)
                }
                
            } else {
                //leave the page
                performSegue(withIdentifier: "donePromotingSegue", sender: self)
            }
            
            //add post to "users" database
            usersRef?.updateData([
                "posts": FieldValue.arrayUnion([db.collection("promotedPosts").document(postRef!.documentID)])
                ])
        
            usersRef?.updateData([
                "promotedPosts": FieldValue.arrayUnion([db.collection("promotedPosts").document(postRef!.documentID)])
                ])
            
            //update ref
            db.collection("promotedPosts").document(postRef!.documentID).updateData([
                "ref": db.collection("promotedPosts").document(postRef!.documentID)
                ])
            
            //leave the page
            // performSegue(withIdentifier: "doneComposingSegue", sender: self)
        }
    
    func postImage(ID: String, completion1: @escaping () -> ()){
        
        //get image name
        let imageName = NSUUID().uuidString
        
        //storage location
        let storedImage = storageRef.child("post_images").child(ID)
        if let uploadData = image!.pngData()
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
                        db.collection("promotedPosts").document(ID).updateData([
                            "imageString": urlText
                            ])
                        
                        //done
                        completion1()
                    }
                })
                
            })
        }
    }
    
}
