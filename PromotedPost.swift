//
//  PromotedPost.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 6/23/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage


class PromotedPost : Post {
    var numViews = 0
    var numViewsPaidFor = 0
    var numClicks = 0
    var numLinkClicks = 0
    var link = ""
    
    init(content: String, user: DocumentReference, score: Int, timeStamp: Timestamp, likes: [DocumentReference], dislikes: [DocumentReference], ID: String, commentCount: Int, isAnonymous: Bool, imageString: String, ref: DocumentReference, sport: String, numViews: Int, numViewsPaidFor: Int, numClicks: Int, numLinkClicks: Int, link: String) {
        
        
        super.init(content: content, user: user, score: score, timeStamp: timeStamp, likes: likes, dislikes: dislikes, ID: ID, commentCount: commentCount, isAnonymous: isAnonymous, imageString: imageString, ref: ref, sport: sport)
        
        
        self.numViewsPaidFor = numViewsPaidFor
        self.numViews = numViews
        self.numClicks = numClicks
        self.numLinkClicks = numLinkClicks
        self.link = link
    }
    
    override var dictionary:[String:Any] {
        return [
            "content": content,
            "user": user,
            "score":score,
            "timeStamp":timeStamp,
            "likes":likes,
            "dislikes":dislikes,
            "ID":ID,
            "ref": ref,
            "isAnonymous": isAnonymous,
            "imageString": imageString,
            "commentCount": commentCount,
            "sport": sport,
            "numViews": numViews,
            "numViewsPaidFor": numViewsPaidFor,
            "numClicks": numClicks,
            "numLinkClicks": numLinkClicks,
            "link" : link
        ]
        
    }

    
    required convenience init?(dictionary: [String : Any]) {
        
        guard let content = dictionary["content"] as? String,
            let user = dictionary["user"] as? DocumentReference,
            let score = dictionary["score"] as? Int,
            let likes = dictionary["likes"] as? [DocumentReference],
            let dislikes = dictionary["dislikes"] as? [DocumentReference],
            let ID = dictionary["ID"] as? String,
            let commentCount = dictionary["commentCount"] as? Int,
            let ref = dictionary["ref"] as? DocumentReference,
            let isAnonymous = dictionary["isAnonymous"] as? Bool,
            let imageString = dictionary["imageString"] as? String,
            let sport = dictionary["sport"] as? String,
            let numViewsPaidFor = dictionary["numViewsPaidFor"] as? Int,
            let numViews = dictionary["numViews"] as? Int,
            let numClicks = dictionary["numClicks"] as? Int,
            let numLinkClicks = dictionary["numLinkClicks"] as? Int,
            let link = dictionary["link"] as? String,
            let timeStamp = dictionary["timeStamp"] as? Timestamp else {return nil}
        
        self.init(content: content, user:user, score:score, timeStamp: timeStamp, likes:likes, dislikes:dislikes, ID:ID, commentCount: commentCount, isAnonymous: isAnonymous, imageString: imageString, ref: ref, sport:sport, numViews: numViews, numViewsPaidFor: numViewsPaidFor, numClicks: numClicks, numLinkClicks: numLinkClicks, link: link)
        
    }
    
    func incrementViews() {
        //update numViews
        ref.updateData(["numViews" : FieldValue.increment(1.0)])
    }
    
    func incrementClicks() {
        //update numViews
        ref.updateData(["numClicks" : FieldValue.increment(1.0)])
    }
    
    func incrementLinkClicks() {
        //update numViews
        ref.updateData(["numLinkClicks" : FieldValue.increment(1.0)])
    }
    
}

