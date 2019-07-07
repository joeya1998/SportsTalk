//
//  PromotionTableViewController.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 7/3/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class PromotionTableViewController: UITableViewController, FeedTableViewCellDelegate {
    func didTapOnLink(post: PromotedPost) {
        
    }
    

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var array = [PromotedPost]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        
     //get the promoted posts
        loadData()
        
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return array.count
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionInfo") as! PromotionInfoTableViewCell
        let post = array[indexPath.row]
        
        //conform to protocol
        cell.delegate = self
        
        //set up cell
        cell.postID = post.ID
        cell.post = post
        
        cell.content.text = post.content
        cell.numViews.text = "\(post.numViews)"
        cell.viewsPaidFor.text = "\(post.numViewsPaidFor)"
        cell.score.text = "Score: \(post.score)"
        cell.comments.text = "Comments: \(post.commentCount)"
        cell.postClicks.text = "\(post.numClicks)"
        cell.linkClicks.text = "\(post.numLinkClicks)"
        
        //timestamp
        var formatter = DateFormatter()
        formatter.dateFormat = "h:mm a | M/d/y"
        
        cell.timeStamp.text = "\(formatter.string(from: post.timeStamp.dateValue()))"
        
        //handle image
        print("image string")
        print(post.imageString)
        if post.imageString != "" {
            //expand post
            cell.viewHeightConstraint.constant = 150.0
            
            cell.postImage.loadImageUsingCacheWithUrlString(urlString: post.imageString) {}
            cell.postImage.layer.cornerRadius = 10
            cell.postImage.layer.masksToBounds = true
            
        } else {
            cell.viewHeightConstraint.constant = 0.0
        }
        
        return cell
    }
 

    func loadData() {
        activityIndicator.startAnimating()
        
        var array = myUser.promotedPosts
        var postArray = [PromotedPost]()
        
        for x in 0...array.count - 1{
            array[x].getDocument { (document, error) in
                //capture the document
                if let document = document, document.exists {
                    //make the post object
                    let post = PromotedPost(dictionary: document.data()!)
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
    
    
    func didTapOnImage(post: Post) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController
        vc?.post = post
        present(vc!, animated: true, completion: nil)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
