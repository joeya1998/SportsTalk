//
//  post.swift
//  Sports Talk
//
//  Created by Joey Aberasturi on 5/12/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

let now = Date()
let formatter = DateFormatter()
var postRef:DocumentReference? = nil
//var usersRef:DocumentReference? = nil
var commentRef:DocumentReference? = nil
var db:Firestore = Firestore.firestore()
let storageRef = Storage.storage().reference()

protocol DocumentSerializable {
     init?(dictionary:[String:Any])
}

class Post : DocumentSerializable {
    
    var content:String = ""
    var user:DocumentReference = db.collection("posts").document("x")
    var score:Int = 0
    var timeStamp:Timestamp = Timestamp()
    var likes:[DocumentReference] = [DocumentReference]()
    var dislikes:[DocumentReference] = [DocumentReference]()
    var ID:String = ""
    var commentCount:Int = 0
    var isAnonymous: Bool = true
    var imageString:String = ""
    var ref:DocumentReference = db.collection("posts").document("x")
    var sport:String = ""

    
    var dictionary:[String:Any] {
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
            "sport": sport
        ]
        
    }
    
    init(content: String, user:DocumentReference, score:Int, timeStamp: Timestamp, likes:[DocumentReference], dislikes:[DocumentReference], ID:String, commentCount: Int, isAnonymous: Bool, imageString: String, ref: DocumentReference, sport:String){
        self.content = content
        self.user = user
        self.score = score
        self.timeStamp = timeStamp
        self.likes = likes
        self.dislikes = dislikes
        self.ID = ID
        self.commentCount = commentCount
        self.isAnonymous = isAnonymous
        self.imageString = imageString
        self.ref = ref
        self.sport = sport
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
            let timeStamp = dictionary["timeStamp"] as? Timestamp else {return nil}
        
         self.init(content: content, user:user, score:score, timeStamp: timeStamp, likes:likes, dislikes:dislikes, ID:ID, commentCount: commentCount, isAnonymous: isAnonymous, imageString: imageString, ref: ref, sport:sport)
            
        }
    
    
    func addComment(comment: String, isAnonymous: Bool, image: UIImage, completion: @escaping () -> ()) {
        //get references
        db = Firestore.firestore()
        usersRef = db.collection("users").document(myUser.UID)
        postRef = db.collection("posts").document(ID)
        
        //create comment object
        let newComment = Post(content: comment, user:usersRef!, score:0, timeStamp:Timestamp(), likes: [DocumentReference](), dislikes:[DocumentReference](), ID: "", commentCount: 0, isAnonymous: isAnonymous, imageString: "", ref: ref, sport: "")
        
        //add to posts comments
        commentRef = ref.collection("comments").addDocument(data: newComment.dictionary) {
            error in
            
            if let error = error {
                print("error adding: \(error.localizedDescription)")
            }
            else {
                print("document added")
            }
        }
        
        
        //update id for comment
        ref.collection("comments").document(commentRef!.documentID).updateData([
            "ID": commentRef!.documentID
            ])
        
        //if there is an image
        if image != nil {
            
            //post the image
            postImage(imageID: commentRef!.documentID, image: image) {
                completion()
            }
            
        }
        
        //add to users comments
        usersRef?.updateData([
            "comments": FieldValue.arrayUnion([ref.collection("comments").document(commentRef!.documentID)])
            ])
        
        //update commentCount
        ref.updateData(["commentCount": FieldValue.increment(1.0)])
        
        
        //update ref
        ref.collection("comments").document(commentRef!.documentID).updateData([
            "ref": ref.collection("comments").document(commentRef!.documentID)
            ])
        
    }
  
    func addComment(comment: String, isAnonymous: Bool) {
        //get references
        db = Firestore.firestore()
        usersRef = db.collection("users").document(myUser.UID)
        postRef = db.collection("posts").document(ID)
        
        //create comment object
        let newComment = Post(content: comment, user:usersRef!, score:0, timeStamp:Timestamp(), likes: [DocumentReference](), dislikes:[DocumentReference](), ID: "", commentCount: 0, isAnonymous: isAnonymous, imageString: "", ref: ref, sport: "")
    
        
        //add to posts comments
        commentRef = ref.collection("comments").addDocument(data: newComment.dictionary) {
            error in
            
            if let error = error {
                print("error adding: \(error.localizedDescription)")
            }
            else {
                print("document added")
            }
        }
        
        
        //update id for comment
        ref.collection("comments").document(commentRef!.documentID).updateData([
            "ID": commentRef!.documentID
            ])
        
        
        //add to users comments
        usersRef?.updateData([
            "comments": FieldValue.arrayUnion([ref.collection("comments").document(commentRef!.documentID)])
            ])
        
        
        //update commentCount
        ref.updateData(["commentCount": FieldValue.increment(1.0)])
        
        
        //update ref
        ref.collection("comments").document(commentRef!.documentID).updateData([
            "ref": ref.collection("comments").document(commentRef!.documentID)
            ])
        
    }
    
    
    func postImage(imageID: String, image: UIImage?, completion1: @escaping () -> ()){
        
        //get image name
        let imageName = NSUUID().uuidString
        
        //storage location
        let storedImage = storageRef.child("post_images").child(imageID)
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
                        //update imageString for comment
                        self.ref.collection("comments").document(commentRef!.documentID).updateData([
                            "imageString": urlText
                            ])
                    
                        //done
                        completion1()
                    }
                })
                
            })
        }
    }
    
    func deletePost() {
        //get references
        db = Firestore.firestore()
        usersRef = db.collection("users").document(myUser.UID)
        postRef = db.collection("posts").document(ID)
        
        //move to deletedPosts
        db.collection("deletedPosts").addDocument(data: dictionary)
        
        //delete the post from posts
        postRef?.delete()
        
        //delete from user posts
        usersRef.updateData(["posts": FieldValue.arrayRemove([postRef as Any])])
        
        
        
    }

    
    func likePost() {
        //add database reference
        db = Firestore.firestore()
        
        //add references
        usersRef = db.collection("users").document(myUser.UID)
        postRef = db.collection("posts").document(ID)
        
        //add user to post like list
        ref.updateData(["likes": FieldValue.arrayUnion([usersRef as Any])])
        
        
        //add post to user like list
        usersRef?.updateData(["likes": FieldValue.arrayUnion([ref as Any])])
        
        //update score for user
        ref.updateData(["score": FieldValue.increment(1.0)])
        
        
        //update score for post
        usersRef?.updateData(["score": FieldValue.increment(1.0)])
        
    }
    
    func dislikePost() {
        //add database reference
        db = Firestore.firestore()
        //add references
        usersRef = db.collection("users").document(myUser.UID)
        postRef = db.collection("posts").document(ID)
        
        //add user to post dislike list
        ref.updateData(["dislikes": FieldValue.arrayUnion([usersRef as Any])])
        
        
        //add post to user dislike list
        usersRef?.updateData(["dislikes": FieldValue.arrayUnion([ref as Any])])
        
        
        //update score for user
        ref.updateData(["score": FieldValue.increment(-1.0)])
        
        
        //update score for post
        usersRef?.updateData(["score": FieldValue.increment(-1.0)])
        
    }
    
}

//extension Post : DocumentSerializable {
//
//
//}
