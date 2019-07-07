//
//  PromotedPostTableViewCell.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 6/23/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit



class PromotedPostTableViewCell: FeedTableViewCell {
    
    var promotedPost:PromotedPost? = nil

    
    @IBOutlet var linkHeight: NSLayoutConstraint!
    @IBOutlet var linkView: UIView!
    @IBOutlet var linkButton: UIButton!
    override func awakeFromNib() {
        UITableViewCell.awakeFromNib()
        // Initialization code
        
        viewHeightConstraint.constant = 0
        fonts.forEach { label in
            label.font = Fonts.font
            label.textColor = Colors.fontColor
        }
        
        subFonts.forEach { label in
            label.font = Fonts.subFont
            label.textColor = Colors.subFontColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadPromotedCellUsingCacheWithPost(post: PromotedPost, completion: @escaping () -> ()) {
        
        userImage.image = Images.nilImage
        
        var urlString = ""
        var postID = post.ID
        
        //check cache for image and user first
        if let cachedImage = imageCache.object(forKey: postID as AnyObject) as? UIImage {
            userImage.image = cachedImage
            //return
        }
        
        if post.link != "" {
            setUpLink()
        } else {
            hideLink()
        }
        
        //check cache for image and user first
        if let cachedDictionary = postCache.object(forKey: postID as AnyObject) as? [String: Any] {
            usernameLabel.text = (cachedDictionary["username"] as! String)
            postMessage.text = (cachedDictionary["content"] as! String)
            //scoreLabel.text = (cachedDictionary["scoreLabel"] as! String)
            timeStamp.text = "\(self.getTimeElapsed(timeStamp: post.timeStamp)) | \(post.commentCount) comments"
            //upButtonOutlet.isEnabled = (cachedDictionary["buttonEnabled"] as! Bool)
            //downButtonOutlet.isEnabled = (cachedDictionary["buttonEnabled"] as! Bool)
            
            //anonymous
            if post.isAnonymous == true {
                //default image
                self.userImage.image = Images.logo
                //anonymous
                self.usernameLabel.text = "Sponsored"
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
            return
        }

        //update numViews
        post.incrementViews()
        
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
                    dictionary["username"] = "Sponsored"
                    dictionary["scoreLabel"] = String(post.score)
                    dictionary["timeStamp"] = "\(self.getTimeElapsed(timeStamp: post.timeStamp)) | \(post.commentCount) comments"
                    dictionary["buttonEnabled"] = false
                    
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
                     //   self.scoreLabel.text = (dictionary["scoreLabel"] as! String)
                        self.timeStamp.text = (dictionary["timeStamp"] as! String)
//                        self.upButtonOutlet.isEnabled = (dictionary["buttonEnabled"] as! Bool)
//                        self.downButtonOutlet.isEnabled = (dictionary["buttonEnabled"] as! Bool)
//
                        
                        //anonymous
                        if post.isAnonymous == true {
                            //default image
                            self.userImage.image = Images.logo
                            //anonymous
                            self.usernameLabel.text = "Sponsored"
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
                        completion()
                    }
                }
        }
        
    }
    
    func setUpLink() {
        linkButton.setUp()
        linkHeight.constant = 50.0
        linkButton.setTitle(promotedPost?.link, for: .normal)
    }
    
    func hideLink() {
        linkHeight.constant = 0.0
    }
    @IBAction func linkButton(_ sender: Any) {
        delegate?.didTapOnLink(post: promotedPost!)
    }
}
