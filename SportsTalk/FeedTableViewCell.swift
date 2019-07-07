//
//  FeedTableViewCell.swift
//  Sports Talk
//
//  Created by Joey Aberasturi on 5/12/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol FeedTableViewCellDelegate {
    func didTapOnImage(post: Post)
    func didTapOnLink(post: PromotedPost)
}

let postCache = NSCache<AnyObject, AnyObject>()
let cellCache = NSCache<AnyObject, AnyObject>()

class FeedTableViewCell: UITableViewCell {

    //connect the outlets
    
    
    @IBOutlet var imageButton: UIButton!
    @IBOutlet var fonts: [UILabel]!
    @IBOutlet var subFonts: [UILabel]!
    @IBOutlet weak var downButtonOutlet: UIButton!
    @IBOutlet weak var upButtonOutlet: UIButton!
    @IBOutlet weak var postMessage: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var usernameLabel
    : UILabel!
    
    @IBOutlet var userImage: UIImageView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
   
    @IBOutlet var postImage: UIImageView!
    
    
    //variables
    var postID = ""
    var post:Post? = nil
    var postRef:DocumentReference? = nil
    var usersRef:DocumentReference? = nil
    var delegate: FeedTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewHeightConstraint.constant = 0
        
        fonts.forEach { label in
            label.font = Fonts.font
            label.textColor = Colors.fontColor
        }
        
        subFonts.forEach { label in
            label.font = Fonts.subFont
            label.textColor = Colors.subFontColor
        }
        
        upButtonOutlet.setImage(Images.up, for: .normal)
        downButtonOutlet.setImage(Images.down, for: .normal)
        downButtonOutlet.imageView?.contentMode = .scaleAspectFill
        downButtonOutlet.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        upButtonOutlet.imageView?.contentMode = .scaleAspectFill
        upButtonOutlet.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func loadImageUsingCacheWithReference(reference: Post, completion: @escaping () -> ()) {
        
        userImage.image = Images.nilImage
        
        var urlString = ""
        var postID = reference.ID
        
        //check cache for image and user first
        if let cachedImage = imageCache.object(forKey: postID as AnyObject) as? UIImage {
            userImage.image = cachedImage
            return
        }
        
        //get the post user
        reference.user.getDocument
            { (document, error) in
                if let document = document
                {
                    let postUser = User(dictionary: document.data()!)
                    urlString = postUser!.imageString
                    self.usernameLabel.text = postUser?.username
                    
                    //check if image is avatar
                    switch (urlString) {
                    case "user", "user1", "user2", "user3", "user4": DispatchQueue.main.async {
                        self.userImage.image = UIImage(named: urlString)
                        imageCache.setObject(UIImage(named: urlString)! as UIImage, forKey: postID as AnyObject)
                        completion()
                        }
                        
                    case "" : DispatchQueue.main.async {
                        self.userImage.image = Images.user
                        imageCache.setObject(Images.user!, forKey: postID as AnyObject)
                        completion()
                        }
                    default:
                        let url = URL(string: urlString)!
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            
                            if error != nil {
                                print(error)
                                return
                            }
                            
                            DispatchQueue.main.async {
                                if let downloadedImage = UIImage(data: data!) {
                                    imageCache.setObject(downloadedImage, forKey: postID as AnyObject)
                                    self.userImage.image =  downloadedImage
                                    completion()
                                }
                            }
                            }.resume()
                    }
                }
        }
    }
    
    func loadImageUsingCacheWithPost(post: Post, completion: @escaping () -> ()) {

        userImage.image = Images.nilImage
        
        var urlString = ""
        var postID = post.ID
        
        //check cache for image and user first
        if post.isAnonymous == true {
            //default image
            self.userImage.image = Images.logo
        } else if let cachedImage = imageCache.object(forKey: postID as AnyObject) as? UIImage {
            userImage.image = cachedImage
            //return
        }
        
        //check cache for image and user first
        if let cachedDictionary = postCache.object(forKey: postID as AnyObject) as? [String: Any] {
            usernameLabel.text = (cachedDictionary["username"] as! String)
            postMessage.text = (cachedDictionary["content"] as! String)
            scoreLabel.text = (cachedDictionary["scoreLabel"] as! String)
            timeStamp.text = "\(self.getTimeElapsed(timeStamp: post.timeStamp)) | \(post.commentCount) comments"
            upButtonOutlet.isEnabled = (cachedDictionary["buttonEnabled"] as! Bool)
            downButtonOutlet.isEnabled = (cachedDictionary["buttonEnabled"] as! Bool)
            
            //handle image
            if post.imageString != "" {
                //expand post
                self.viewHeightConstraint.constant = 150.0
                self.postImage.loadImageUsingCacheWithUrlString(urlString: post.imageString) {}
                self.postImage.layer.cornerRadius = 10
                self.postImage.layer.masksToBounds = true
                
            } else {
                self.viewHeightConstraint.constant = 0.0
            }

            self.userImage.layer.cornerRadius = self.userImage.frame.height/2
            self.userImage.clipsToBounds = true
            return
        }

        //do things for both----------------------------------------------------------------------------
        
        //lock buttons if like/disliked already
        if post.likes.contains(myUser.ref) || post.dislikes.contains(myUser.ref)  {
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
        //handle image
        if post.imageString != "" {
            //expand post
            self.viewHeightConstraint.constant = 150.0
            self.postImage.loadImageUsingCacheWithUrlString(urlString: post.imageString) {}
            self.postImage.layer.cornerRadius = 10
            self.postImage.layer.masksToBounds = true
            
        } else {
            self.viewHeightConstraint.constant = 0.0
        }
        
        self.userImage.layer.cornerRadius = self.userImage.frame.height/2
        self.userImage.clipsToBounds = true
        
        //do things for anonymous----------------------------------------------------------------------------
        if post.isAnonymous == true {
            //default image
            self.userImage.image = Images.logo
            //anonymous
            self.usernameLabel.text = "Anonymous"
            
            var dictionary = [String: Any]()
            
            //get the post info
            dictionary["content"] = post.content
            dictionary["username"] = "Anonymous"
            dictionary["scoreLabel"] = String(post.score)
            dictionary["timeStamp"] = "\(self.getTimeElapsed(timeStamp: post.timeStamp)) | \(post.commentCount) comments"
            dictionary["buttonEnabled"] = (self.upButtonOutlet.isEnabled ? true : false)
            
            postCache.setObject(dictionary as AnyObject, forKey: postID as AnyObject)
            
            DispatchQueue.main.async {
                self.usernameLabel.text = (dictionary["username"] as! String)
                self.postMessage.text = (dictionary["content"] as! String)
                self.scoreLabel.text = (dictionary["scoreLabel"] as! String)
                self.timeStamp.text = (dictionary["timeStamp"] as! String)
                self.upButtonOutlet.isEnabled = (dictionary["buttonEnabled"] as! Bool)
                self.downButtonOutlet.isEnabled = (dictionary["buttonEnabled"] as! Bool)
                
                completion()
            }
            
        } else {
        //do things for not anonymous----------------------------------------------------------------------------
            //get the post user
            post.user.getDocument
                { (document, error) in
                    if let document = document
                    {
                        let postUser = User(dictionary: document.data()!)
                        var dictionary = [String: Any]()
                        urlString = postUser!.imageString
                        
                        //get the post info
                        dictionary["content"] = post.content
                        dictionary["username"] = postUser!.username
                        dictionary["scoreLabel"] = String(post.score)
                        dictionary["timeStamp"] = "\(self.getTimeElapsed(timeStamp: post.timeStamp)) | \(post.commentCount) comments"
                        dictionary["buttonEnabled"] = (self.upButtonOutlet.isEnabled ? true : false)
                        
                        postCache.setObject(dictionary as AnyObject, forKey: postID as AnyObject)
                        
                        
                        //check if image is avatar
                        switch (urlString) {
                        case "user", "user1", "user2", "user3", "user4":
                            DispatchQueue.main.async {
                                self.userImage.image = UIImage(named: urlString)
                                //self.usernameLabel.text = dictionary["username"] as! String
                                imageCache.setObject(UIImage(named: urlString)! as UIImage, forKey: post.ID as AnyObject)
                                print("SUBMITTED")
                                completion()
                            }
                            //dictionary["image"] = UIImage(named:urlString)
                            
                        case "" : DispatchQueue.main.async {
                            self.userImage.image = Images.user
                            imageCache.setObject(Images.user!, forKey: post.ID as AnyObject)
                            // self.usernameLabel.text = dictionary["username"] as! String
                            completion()
                            }
                        default:
                            let url = URL(string: urlString)!
                            URLSession.shared.dataTask(with: url) { (data, response, error) in
                                
                                if error != nil {
                                    print(error as Any)
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    if let downloadedImage = UIImage(data: data!) {
                                        self.userImage.image =  downloadedImage
                                        imageCache.setObject(downloadedImage, forKey: post.ID as AnyObject)
                                        //  self.usernameLabel.text = dictionary["username"] as! String
                                        completion()
                                    }
                                }
                                }.resume()
                        }
                        
                        //end of switch
                        DispatchQueue.main.async {
                            self.usernameLabel.text = (dictionary["username"] as! String)
                            self.postMessage.text = (dictionary["content"] as! String)
                            self.scoreLabel.text = (dictionary["scoreLabel"] as! String)
                            self.timeStamp.text = (dictionary["timeStamp"] as! String)
                            self.upButtonOutlet.isEnabled = (dictionary["buttonEnabled"] as! Bool)
                            self.downButtonOutlet.isEnabled = (dictionary["buttonEnabled"] as! Bool)
                            
                           
                            completion()
                        }
                    }
            }
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
    
    
    //actions
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
       
        //update cache
        var dictionary = [String: Any]()
        dictionary["content"] = postMessage.text
        dictionary["username"] = usernameLabel.text
        dictionary["scoreLabel"] = scoreLabel.text
        dictionary["timeStamp"] = timeStamp.text
        dictionary["buttonEnabled"] = (self.upButtonOutlet.isEnabled ? true : false)
        
        postCache.setObject(dictionary as AnyObject, forKey: postID as AnyObject)
        
        
        
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
        
        
        //update cache
        var dictionary = [String: Any]()
        dictionary["content"] = postMessage.text
        dictionary["username"] = usernameLabel.text
        dictionary["scoreLabel"] = scoreLabel.text
        dictionary["timeStamp"] = timeStamp.text
        dictionary["buttonEnabled"] = (self.upButtonOutlet.isEnabled ? true : false)
        
        postCache.setObject(dictionary as AnyObject, forKey: postID as AnyObject)
    
    }
   
    @IBAction func detailUpButton(_ sender: Any) {
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
    
    @IBAction func detailDownButton(_ sender: Any) {
        
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

    
    @IBAction func imageButton(_sender: Any) {
        delegate?.didTapOnImage(post: post!)
    }
    
}
