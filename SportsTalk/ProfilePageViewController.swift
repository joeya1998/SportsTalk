//
//  SecondViewController.swift
//  Sports Talk
//
//  Created by Joey Aberasturi on 5/12/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfilePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FeedTableViewCellDelegate {
    func didTapOnLink(post: PromotedPost) {
        
    }
    
   
    //outlets
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var dislikesOutlet: UIButton!
    @IBOutlet var likesOutlet: UIButton!
    @IBOutlet var promotionsOutlet: UIButton!
    @IBOutlet var postOutlet: UIButton!
    
    //variables
    var selected = "posts"
    var array: [Post] = [Post]()
    let databaseRef = db.collection("users")
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    //main
    override func viewDidLoad() {
        super.viewDidLoad()
        //get data
        loadData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //load the profile
        profileImage.loadImageUsingCacheWithUrlString(urlString: myUser.imageString, completion: {})
        usernameLabel.text = myUser.username
        scoreLabel.text = "\(myUser.score)"
        
        //make things look nice
        for button in buttons {
            button.setUp()
        }
        
        postOutlet.selected()
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.layer.masksToBounds = true
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        
        
    }
    
    //functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Post Cell") as! FeedTableViewCell
        let post = array[indexPath.row]
        

        
        //conform to protocol
        cell.delegate = self
        
        //set up cell
        cell.postID = post.ID
        cell.post = post
        cell.loadImageUsingCacheWithPost(post: post) {}
        cell.upButtonOutlet.isHidden = true
        cell.downButtonOutlet.isHidden = true

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! FeedTableViewCell
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewViewController
        
        vc?.ref = currentCell.post?.ref
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func loadData() {
        activityIndicator.startAnimating()
        
        getMyData(id: myUser.UID)
        var array = [DocumentReference]()
        var postArray = [Post]()
        
        switch(selected){
        case "posts": array = myUser.posts
        case "promotions": array = myUser.promotedPosts
        case "likes": array = myUser.likes
        case "dislikes": array = myUser.dislikes
        default: array = myUser.posts
        }
        
//        for ref in array {
//            ref.getDocument { (document, error) in
//                //capture the document
//                if let document = document, document.exists {
//                    //make the post object
//                    let post = Post(dictionary: document.data()!)
//                    if post != nil {
//                       postArray.append(post!)
//                    }
//                }
//                self.array = postArray.sorted(by: {$0.timeStamp.dateValue() > $1.timeStamp.dateValue() })
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }
        for x in 0...array.count - 1{
            array[x].getDocument { (document, error) in
                //capture the document
                if let document = document, document.exists {
                    //make the post object
                    let post = Post(dictionary: document.data()!)
                    if post != nil {
                        postArray.append(post!)
                    }
                }
                self.array = postArray.sorted(by: {$0.timeStamp.dateValue() > $1.timeStamp.dateValue() })
                if x == array.count - 1{
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            }
        }
       
       
    }
    
    func signOutFunction(completion: @escaping () -> Void) {
        
        do
        {
            try Auth.auth().signOut()
            completion()
        } catch let signOutError as NSError
        {
            print ("Error signing out: %@", signOutError)
        }
    }

    
    func getMyData(id: String){
        
        //get document
        db.collection("users").document(id).getDocument { (document, error) in
            
            //capture the document
            if let document = document, document.exists {
                
                //make the user object
                myUser = User(dictionary: document.data()!)
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func didTapOnImage(post: Post) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController
        vc?.post = post
        present(vc!, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            profileImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func saveChanges(completion: () -> () ){
       
            //get image name
            let imageName = NSUUID().uuidString
            
            //storage location
            storageRef.child("profile_images").child(myUser.username).delete(completion: nil)
            let storedImage = storageRef.child("profile_images").child(myUser.username)
            if let uploadData = self.profileImage.image!.pngData()
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
                            myUser.changeImageString(urlText: urlText)
                        }
                    })
                    
                })
                completion()
            }
        
    }
    
    //actions
    @IBAction func signOut(_ sender: Any) {
        signOutFunction {
            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        }
    }
   
    @IBAction func openSettings(_ sender: Any) {
    }
    @IBAction func changeImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    @IBAction func postsButton(_ sender: Any) {
        selected = "posts"
        loadData()
        
        //change other buttons
        for button in buttons {
            button.setUp()
        }
        //change this button
        postOutlet.selected()
    }
    @IBAction func promotionsButton(_ sender: Any) {
        selected = "promotions"
        loadData()
        
        //change other buttons
        for button in buttons {
            button.setUp()
        }
        //change this button
        promotionsOutlet.selected()
    }
    @IBAction func likesButton(_ sender: Any) {
        selected = "likes"
        loadData()
        
        //change other buttons
        for button in buttons {
            button.setUp()
        }
        //change this button
        likesOutlet.selected()
    }
    @IBAction func dislikesButton(_ sender: Any) {
        selected = "dislikes"
        loadData()
        
        //change other buttons
        for button in buttons {
            button.setUp()
        }
        //change this button
        dislikesOutlet.selected()
    }
    
}

