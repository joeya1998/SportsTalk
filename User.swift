//
//  User.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 5/21/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import Foundation
import FirebaseFirestore


protocol DocumentSerializableUser {
    init?(dictionary:[String:Any])
}

struct User {
    
    var UID:String
    var username:String
    var score:Int = 0
    var imageString:String
    var posts:[DocumentReference] = [DocumentReference]()
    var likes:[DocumentReference] = [DocumentReference]()
    var promotedPosts:[DocumentReference] = [DocumentReference]()
    var dislikes:[DocumentReference] = [DocumentReference]()
    var ref:DocumentReference = db.collection("users").document("x")
    var comments:[DocumentReference] = [DocumentReference]()
    
    var dictionary:[String:Any] {
        return [
            "UID": UID,
            "username": username,
            "score":score,
            "posts": posts,
            "promotedPosts": promotedPosts,
            "imageString":imageString,
            "likes":likes,
            "dislikes":dislikes,
            "ref": ref,
            "comments": comments
        ]
        
    }
 
    
    
    func changeSetting() {
        
        
    }
    
    func changeUsername(newUsername: String) {
        var oldUsername = myUser.username
        db.collection("usernames").document("usernames").updateData([
            "username": FieldValue.arrayRemove([oldUsername])
            ])
        
        ref.updateData([
            "username": newUsername
            ])
        myUser.username = newUsername
        
        
    }
    
    func changeImageString(urlText: String) {
        ref.updateData([
            "imageString": urlText
            ])
        myUser.imageString = urlText
    }
    
}

extension User : DocumentSerializableUser {
    init?(dictionary: [String : Any]) {
        guard let UID = dictionary["UID"] as? String,
            let username = dictionary["username"] as? String,
            let score = dictionary["score"] as? Int,
            let likes = dictionary["likes"] as? [DocumentReference],
            let posts = dictionary["posts"] as? [DocumentReference],
            let promotedPosts = dictionary["promotedPosts"] as? [DocumentReference],
            let dislikes = dictionary["dislikes"] as? [DocumentReference],
            let imageString = dictionary["imageString"] as? String,
            let comments = dictionary["comments"] as? [DocumentReference],
            let ref = dictionary["ref"] as? DocumentReference else {return nil}
        
        
        self.init(UID: UID, username:username, score:score, imageString:imageString, posts:posts, likes: likes, promotedPosts:promotedPosts, dislikes:dislikes, ref:ref, comments: comments)
    }
}
