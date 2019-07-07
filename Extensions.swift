//
//  Extensions.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 5/23/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String, completion: @escaping () -> ()) {
        self.image = Images.nilImage
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        
        //check if image is avatar
        switch (urlString) {
        case "user", "user1", "user2", "user3", "user4": self.image = UIImage(named: urlString)
    
        case "" : self.image = Images.logo
            
        default:   //otherwise download
            let url = URL(string: urlString)!
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!) {
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        
                        self.image =  downloadedImage
                        completion()
                    }
                }
                }.resume()
            break
        }
        
    }
    
    func loadImageUsingCacheWithReference(reference: Post, completion: @escaping () -> ()) {
        
        self.image = Images.nilImage
        
        var urlString = ""
        var postID = reference.ID
        
        //check cache for image and user first
        if let cachedImage = imageCache.object(forKey: postID as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //get the post user
        reference.user.getDocument
        { (document, error) in
            if let document = document
            {
                let postUser = User(dictionary: document.data()!)
                urlString = postUser!.imageString

                //check if image is avatar
                switch (urlString) {
                case "user", "user1", "user2", "user3", "user4": DispatchQueue.main.async {
                        self.image = UIImage(named: urlString)
                        imageCache.setObject(UIImage(named: urlString)! as UIImage, forKey: postID as AnyObject)
                        completion()
                    }
                    
                case "" : DispatchQueue.main.async {
                        self.image = Images.user
                        imageCache.setObject(Images.user!, forKey: reference as AnyObject)
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
                                    self.image =  downloadedImage
                                    completion()
                                }
                            }
                            }.resume()
                    }
            }
        }
    }
    
    func makeCircle(image: UIImage) {
        layer.cornerRadius = frame.size.width/2
        clipsToBounds = true
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
        contentMode = .scaleToFill
        self.image = image
    }
}

extension UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        layer.masksToBounds = true
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UINavigationBar {
    
    func setNavColor(colorOne: UIColor, colorTwo: UIColor) {
    setBackgroundImage(UIImage(), for: .default)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        // gradientLayer.colors = [colorOne.CGColor, colorTwo.CGColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        layer.masksToBounds = true
        
        layer.insertSublayer(gradientLayer, at: 0)
    }

}

extension UIButton {
    

    func setUp() {
        
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - 2.0, width: self.frame.width, height: 2.0)
        self.layer.addSublayer(border)
        
        border.backgroundColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.white.cgColor
        tintColor = Colors.unselectedColor
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func selected() {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - 2.0, width: self.frame.width, height: 2.0)
        self.layer.addSublayer(border)
        
        border.backgroundColor = Colors.selectedColor.cgColor
        layer.backgroundColor = UIColor.white.cgColor
        tintColor = Colors.selectedColor
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
    }
}

extension UILabel {
    func setUpLinks() {
        var content = self.text!
        var contentAS: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
        var link: String
        
        if (content.contains(".com")) {
            // there is a link!!!!
            
            var words = content.split(separator: " ")
            for wordSplit in words {
                let word = String(wordSplit)
                //check each word for link
                if word.contains(".com") {
                    link = String(word)
                    
                    let location = content.distance(from: content.startIndex, to: (content.range(of: word)?.lowerBound)!)
                    let length = word.count
                    
                    let attributedString = NSMutableAttributedString(attributedString: contentAS)
                    attributedString.addAttribute(.link, value: link, range: NSRange(location: location, length: length))
                    
                    contentAS = attributedString
                }
            }
            self.attributedText = contentAS
            self.isUserInteractionEnabled = true
        } else {
            // there is no link
        }
        
        
        
    }
}

