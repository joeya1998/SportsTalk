//
//  DetailViewViewController.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 5/15/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class DetailViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FeedTableViewCellDelegate {
    func didTapOnLink(post: PromotedPost) {
        
    }
    
    
    //outlets__________________________________________________________________________________________________________
    
    @IBOutlet var backGroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet weak var downButtonOutlet: UIButton!
    @IBOutlet weak var upButtonOutlet: UIButton!
    @IBOutlet weak var postMessage: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewOutlet: UITextView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var switchOutlet: UISwitch!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var imageView: UIImageView!

    @IBOutlet var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet var fonts: [UILabel]!
    @IBOutlet var subFonts: [UILabel]!
    @IBOutlet var aboveKeyBoardView: UIView!
    //@IBOutlet var postView: UIStackView!
    @IBOutlet var commentViewHeightConstraint: NSLayoutConstraint!
    
    //variables__________________________________________________________________________________________________________
    var comments: [Post]! = [Post]()
    var bottomConstraintConstant:CGFloat = 0.0
    var characterCount = 0
    var db:Firestore!
    var postRef:DocumentReference? = nil
    var usersRef:DocumentReference? = nil
   // var username = "joeyabers"
    var refreshedPost: Post!
    var ref:DocumentReference? = nil
    var post: Post!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
     //main ____________________________________________________________________________________________________________
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        tableView.keyboardDismissMode = .onDrag
        
        //add database reference
        db = Firestore.firestore()
        
        //add references
        usersRef = db.collection("users").document(myUser.UID)
        
        //initialize post
        post = Post(content: "", user:usersRef!, score:0, timeStamp:Timestamp(), likes: [DocumentReference](), dislikes:[DocumentReference](), ID: "", commentCount: 0, isAnonymous: true, imageString: "", ref: db.collection("posts").document("x"), sport: "")
        
        //tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        //textView
        textViewOutlet.delegate = self
        
        
        //set bottom constraint
        self.bottomConstraintConstant = self.bottomConstraint.constant
        
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        
        //keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        
        upButtonOutlet.setImage(Images.up, for: .normal)
        downButtonOutlet.setImage(Images.down, for: .normal)
        downButtonOutlet.imageView?.contentMode = .scaleAspectFill
        downButtonOutlet.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        upButtonOutlet.imageView?.contentMode = .scaleAspectFill
        upButtonOutlet.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        
        
        //load the post
        loadPost {
            
        //load the comments
        self.loadComments {
            self.tableView.reloadData()
            }
            
        //when it's done...make it look nice
            self.backGroundView.setGradientBackground(colorOne: Colors.gradientGreen, colorTwo: Colors.gradientBlue)
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.fonts.forEach { label in
                label.font = Fonts.font
                label.textColor = Colors.fontColor
            }
            
            self.subFonts.forEach { label in
                label.font = Fonts.subFont
                label.textColor = Colors.subFontColor
            }
            
            self.textViewOutlet.layer.cornerRadius = 10
            self.textViewOutlet.layer.masksToBounds = true
            self.characterCountLabel.text = "\(self.characterCount)/150"
            self.postButton.setUp()
            self.textViewOutlet.text = "Reply"
            self.textViewOutlet.textColor = UIColor.gray
            self.viewHeightConstraint.constant = 0
            self.commentViewHeightConstraint.constant = 0
            self.userImage.layer.cornerRadius = self.userImage.frame.height/2
            self.userImage.clipsToBounds = true
            //post attributes
            var nameTag = ""
            var userImageString = ""
            if self.post.isAnonymous != true {
                self.userImage.loadImageUsingCacheWithReference(reference: self.post) {}
                
                self.post.user.getDocument { (document, error) in
                    if let document = document {
                        nameTag = document["username"] as? String ?? ""

                        
                        self.textViewOutlet.text = "Reply to \(nameTag)..."
                        self.usernameLabel.text = nameTag
                        
                    } else {
                        print("Document does not exist")
                    }
                    
                }
            } else {
                //default image
                self.userImage.image = Images.logo
                //anonymous
                self.usernameLabel.text = "Anonymous"
            }
            
            self.postView.layer.cornerRadius = 10
            self.postView.layer.masksToBounds = true
            self.postMessage.text = self.post.content
            self.scoreLabel.text = String(self.post.score)
            //self.timeStamp.text = self.getTimeElapsed(timeStamp: self.post.timeself.Stamp)
            var formatter = DateFormatter()
            formatter.dateFormat = "h:mm a | M/d/y"
            
            self.timeStamp.text = "\(formatter.string(from: self.post.timeStamp.dateValue())) | \(self.post.commentCount) comments"
            
            //handle image
            if self.post.imageString != "" {
                //expand post
                self.viewHeightConstraint.constant = 150.0
                
                self.postImage.loadImageUsingCacheWithUrlString(urlString: self.post.imageString) {}
                self.postImage.layer.cornerRadius = 10
                self.postImage.layer.masksToBounds = true
                
            } else {
                self.viewHeightConstraint.constant = 0.0
            }
            
        //lock buttons if like/disliked already
            if self.post.likes.contains(myUser.ref) || self.post.dislikes.contains(myUser.ref) {
                 self.upButtonOutlet.isEnabled = false
                 self.downButtonOutlet.isEnabled = false
                 self.upButtonOutlet.setTitleColor(.red, for: .disabled)
                 self.downButtonOutlet.setTitleColor(.red, for: .disabled)
            } else {
                 self.upButtonOutlet.isEnabled = true
                 self.downButtonOutlet.isEnabled = true
                 self.upButtonOutlet.setTitleColor(.blue, for: .normal)
                 self.downButtonOutlet.setTitleColor(.blue, for: .normal)
            }
        }
    }
    
    //functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Post Cell") as! FeedTableViewCell
        let comment = comments[indexPath.row]
      
        //conform to protocol
        cell.delegate = self
        
        //cell attributes
        var nameTag = ""
        var userImage = ""
        cell.postID = comment.ID
        cell.post = comment
        cell.loadImageUsingCacheWithPost(post: comment) {}
        /*
        if comment.isAnonymous != true {
            cell.userImage.loadImageUsingCacheWithReference(reference: comment) {}
            
            //load user
            comment.user.getDocument { (document, error) in
                if let document = document {
                    
                    var loadedUser = User(dictionary: document.data()!)
                    cell.usernameLabel.text = loadedUser!.username
                } else {
                    print("Document does not exist")
                }
            }
            
        } else if comment.isAnonymous == true {
            //default image
            cell.userImage.image = Images.logo
            //anonymous
            cell.usernameLabel.text = "Anonymous"
        }
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height/2
        cell.userImage.clipsToBounds = true
        
       
        cell.postMessage.text = comment.content
        cell.scoreLabel.text = String(comment.score)
        cell.timeStamp.text = "\(self.getTimeElapsed(timeStamp: comment.timeStamp)) | \(comment.commentCount) comments"
       // cell.timeStamp.text = getTimeElapsed(timeStamp: comment.timeStamp)
        

        
        //handle image
        if comment.imageString != "" {
            //expand post
            cell.viewHeightConstraint.constant = 150.0
            
            cell.postImage.loadImageUsingCacheWithUrlString(urlString: comment.imageString) {}
            cell.postImage.layer.cornerRadius = 10
            cell.postImage.layer.masksToBounds = true
        } else {
            cell.viewHeightConstraint.constant = 0.0
        }
        
        //lock buttons if like/disliked already
        if comment.likes.contains(myUser.ref) || comment.dislikes.contains(myUser.ref) {
            cell.upButtonOutlet.isEnabled = false
            cell.downButtonOutlet.isEnabled = false
            cell.upButtonOutlet.setTitleColor(.red, for: .disabled)
            cell.downButtonOutlet.setTitleColor(.red, for: .disabled)
        } else {
            cell.upButtonOutlet.isEnabled = true
            cell.downButtonOutlet.isEnabled = true
            cell.upButtonOutlet.setTitleColor(.blue, for: .normal)
            cell.downButtonOutlet.setTitleColor(.blue, for: .normal)
        }
        */
        return cell
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! FeedTableViewCell
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewViewController
       
        vc?.ref = currentCell.post!.ref
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func didTapOnImage(post: Post) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController
        vc?.post = post
        present(vc!, animated: true, completion: nil)
    }
    
    @objc private func keyboardWillShow(notification:Notification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            self.bottomConstraint.constant = keyboardSize.cgRectValue.height - 49
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
    
    
    func getTimeElapsed(timeStamp: Timestamp) -> String {
        
        var timeElapsed = round(-timeStamp.dateValue().timeIntervalSinceNow)
        var units = "seconds"
        if timeElapsed < 60 { //seconds
            timeElapsed = timeElapsed / 1
            timeElapsed.round(.down)
            if timeElapsed > 1 || timeElapsed == 0 {
                units = "seconds"
            } else {
                units = "second"
            }
        } else if timeElapsed < 3600 { //minutes
            timeElapsed = timeElapsed / 60
            timeElapsed.round(.down)
            if timeElapsed > 1 {
                units = "minutes"
            } else {
                units = "minute"
            }
        } else if timeElapsed < 86400 { //hours
            timeElapsed = timeElapsed / 3600
            timeElapsed.round(.down)
            if timeElapsed > 1 {
                units = "hours"
            } else {
                units = "hour"
            }
        } else {//days
            timeElapsed = timeElapsed / 86400
            timeElapsed.round(.down)
            if timeElapsed > 1 {
                units = "days"
            } else {
                units = "day"
            }
        }
        timeElapsed.round(.down)
        return "\(String(format: "%.0f", timeElapsed)) \(units) ago"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        characterCount = textView.text.count
        characterCountLabel.text = "\(characterCount)/150"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textViewOutlet.textColor != UIColor.black {
            textViewOutlet.text = ""
            textViewOutlet.textColor = UIColor.black
        }
    }
    
   
    
    func loadPost(completion: @escaping () -> ()) {
        ref?.getDocument { (document, error) in
            if let document = document, document.exists {
                self.post = Post(dictionary: document.data()!)
            } else {
                print("Document does not exist")
            }
            
            completion()
        }
    }
    
    func loadComments(completion: @escaping () -> Void){
        activityIndicator.startAnimating()
        
        //add database reference
        db = Firestore.firestore()
        //add references
        //usersRef = db.collection("users").document(username)
        postRef = db.collection("posts").document(post.ID)
        
        post.ref.collection("comments").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                self.comments = querySnapshot!.documents.compactMap({Post(dictionary: $0.data())})
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
            }
            completion()
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
                self.commentViewHeightConstraint.constant = 250
                self.imageView.image = selectedImage
                var aspectRatio = selectedImage.size.width / selectedImage.size.height
                print(aspectRatio)
                self.imageWidthConstraint.constant = 250 * aspectRatio
            }
            
        }
        dismiss(animated: true, completion: nil)
    }
  
    func addComment(completion : @escaping () -> ()) {
        
        //there is an image
        if imageView.image != nil {
            post.addComment(comment: textViewOutlet.text, isAnonymous: switchOutlet.isOn, image: imageView.image!) {
                completion()
            }
        }
            
        //there is no image
        else {
        post.addComment(comment: textViewOutlet.text, isAnonymous: switchOutlet.isOn)
            completion()
        }
        
        
    }
    
    func hideKeyboardWhenTappedAround() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        postView.addGestureRecognizer(tap)
        
        
        let scroll: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        scroll.direction = UISwipeGestureRecognizer.Direction.down
        scroll.cancelsTouchesInView = false
        aboveKeyBoardView.addGestureRecognizer(scroll)
        postView.addGestureRecognizer(scroll)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        if textViewOutlet.text == "" {
            textViewOutlet.text = "Type your thoughts..."
            textViewOutlet.textColor = UIColor.gray
        }
        
    }
    
    //actions
    @IBAction func deleteButton(_ sender: Any) {
        //delete
        post.deletePost()
        
        //segue
        self.performSegue(withIdentifier: "deleteSegue", sender: self)
        
    }
    
    
    @IBAction func anonymousSwitch(_ sender: Any) {
        if switchOutlet.isOn == true {
            userNameLabel.text = ""
        } else {
            userNameLabel.text = "-\(myUser.username)"
        }
    }
    
    @IBAction func postButton(_ sender: Any) {
        
        //make sure comment is safe
        if characterCount < 151 && (characterCount > 0 || imageView.image != nil){
            
        //add comment.. handle completion
            addComment {
                self.textViewOutlet.text = ""
                self.imageView.image = nil
                self.commentViewHeightConstraint.constant = 0
                
                self.loadComments() {
                    self.tableView.reloadData()
                }
            }
        }
    }
   
    @IBAction func upButton(_ sender: Any) {
        //like the post
        post!.likePost()
        
        //lock button
        upButtonOutlet.isEnabled = false
        downButtonOutlet.isEnabled = false
        upButtonOutlet.setTitleColor(.red, for: .disabled)
        downButtonOutlet.setTitleColor(.red, for: .disabled)
        
        //change score
        var currentScore = Int(scoreLabel.text!)
        scoreLabel.text = String(currentScore! + 1)
        
        
    }
    @IBAction func downButton(_ sender: Any) {
        //dislike the post
        post!.dislikePost()
        
        //lock button
        upButtonOutlet.isEnabled = false
        downButtonOutlet.isEnabled = false
        upButtonOutlet.setTitleColor(.red, for: .disabled)
        downButtonOutlet.setTitleColor(.red, for: .disabled)
        
        //change score
        var currentScore = Int(scoreLabel.text!)
        scoreLabel.text = String(currentScore! - 1)
    }
    
    @IBAction func removeButton(_ sender: Any) {
        imageView.image = nil
        commentViewHeightConstraint.constant = 0
        
    }
    
    @IBAction func imagePicker(_ sender: Any) {
        if textViewOutlet.textColor != UIColor.black {
            textViewOutlet.text = ""
            textViewOutlet.textColor = UIColor.black
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
       // picker.allowsEditing = true
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func imageButton(_ sender: Any) {
        didTapOnImage(post: post!)
    }
}
