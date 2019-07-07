//
//  FirstViewController.swift
//  Sports Talk
//
//  Created by Joey Aberasturi on 5/12/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FeedTableViewCellDelegate{

    //variables __________________________________________________________________________________________________________
    var array:[Post] = [Post]()
    var db:Firestore!
    var postArray:[Post] = [Post]()
    var promotedPostArray:[PromotedPost] = [PromotedPost]()
    var latestArray:[Post] = [Post]()
    var popularArray:[Post] = [Post]()
    var valueToPass:Post!
    var refresher: UIRefreshControl!
    var comments: [Post]!
    var refreshedPost: Post!
    var sortBy: String = "day"
    var latestOrHot: String = "latest"
    var sport: String = "ALL"
    var imageToPass: UIImage!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    //outlets  __________________________________________________________________________________________________________

    @IBOutlet var sportsButtons: [UIButton]!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet var fonts: [UILabel]!
    @IBOutlet var nhl: UIButton!
    @IBOutlet var mlb: UIButton!
    @IBOutlet var nfl: UIButton!
    @IBOutlet var nba: UIButton!
    @IBOutlet var all: UIButton!
    @IBOutlet var hot: UIButton!
    @IBOutlet var latest: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sortDay: UIButton!
    @IBOutlet var sortWeek: UIButton!
    @IBOutlet var sortMonth: UIButton!
    @IBOutlet var sortByText: UILabel!
    @IBOutlet var segmentControlSport: UISegmentedControl!
    @IBOutlet var backGroundView: UIView!
    @IBOutlet var sortbyView: UIView!
    @IBOutlet var imageButton: UIButton!
    
    
    //main   __________________________________________________________________________________________________________
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(myUser)
        
        //tableview attributes
        tableView.delegate = self
        tableView.dataSource = self
        
        //refresh control
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(FirstViewController.loadData), for: UIControl.Event.valueChanged)
        tableView.addSubview(refresher)
        
        //listen for taps
        hideSortByWhenTapped()
        
        //initialize firestore
        db = Firestore.firestore()
        
        //initialize reference for user
        usersRef = db.collection("users").document(myUser.UID)
        
        //load the feed
        loadData()
        loadPromotedData()
        
       // checkForUpdates()
        
        //make things look nice
        backGroundView.setGradientBackground(colorOne: Colors.gradientGreen, colorTwo: Colors.gradientBlue)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        var titleView = UIImageView(image: Images.icon)
        titleView.frame = CGRect(x: 0.0, y: 0.0, width: (navigationController?.navigationBar.frame.width)!/2, height: (navigationController?.navigationBar.frame.height)!)
        titleView.contentMode = .scaleToFill
        
        navigationItem.titleView = titleView
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        
        
        latest.setUp()
        hot.setUp()
        for button in sportsButtons {
            button.setUp()
        }
        nba.setImage(Images.basketball, for: .normal) 
        nfl.setImage(Images.football, for: .normal)
        nhl.setImage(Images.hockey, for: .normal)
        mlb.setImage(Images.baseball, for: .normal)
        
        sortbyView.backgroundColor = Colors.selectedColor
        sortbyView.layer.cornerRadius = 2
        sortbyView.layer.masksToBounds = true
        sortDay.setUp()
        sortWeek.setUp()
        sortMonth.setUp()
        sortByText.text = "Sort by: \(sortBy)"
        
        fonts.forEach { label in
            label.font = Fonts.font
            label.textColor = Colors.fontColor
        }
        
//        subfonts.forEach { label in
//            label.font = Fonts.subFont
//            label.textColor = Colors.subFontColor
//        }
        
        latest.selected()
        all.selected()
    
        
        
    }
    
    //tableView NumRows__________________________________________________________________________________________________________
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows = postArray.count
        
        return numRows
    }
    
    //tableView Cells__________________________________________________________________________________________________________
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        //handle sponsored post
        if indexPath.row == 2 && promotedPostArray.count > 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Promoted Post Cell") as! PromotedPostTableViewCell
            cell.delegate = self
            
            //let post = Post(content: "sponsored", user: usersRef, score: 123, timeStamp: Timestamp(), likes: [DocumentReference](), dislikes: [DocumentReference](), ID: "hshwhi", commentCount: 12, isAnonymous: true, imageString: "user1", ref: usersRef, sport: "nba")
            let post = promotedPostArray[Int.random(in: 0...promotedPostArray.count)]
            
  
            
            cell.postID = post.ID
            cell.promotedPost = post
            cell.post = post
            cell.loadPromotedCellUsingCacheWithPost(post: post) {}
            
            return cell
           
        //other posts
        } else {
          
            let cell = tableView.dequeueReusableCell(withIdentifier: "Post Cell") as! FeedTableViewCell
            
            let post = postArray[indexPath.row]
            
            //conform to protocol
            cell.delegate = self
            
            //        if let cachedCell = cellCache.object(forKey: post.ID as AnyObject) as? FeedTableViewCell {
            //
            //
            //            return cachedCell as! FeedTableViewCell
            //        }
            //cell attributes
            var nameTag = ""
            var userImage = ""
            
            cell.postID = post.ID
            cell.post = post
            cell.loadImageUsingCacheWithPost(post: post) {}
            
            
            // cellCache.setObject(cell, forKey: post.ID as AnyObject)
            return cell
          
        }
    }

  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        
        
        
        if indexPath.row == 2 {
            let currentCell = tableView.cellForRow(at: indexPath)! as! PromotedPostTableViewCell
            currentCell.promotedPost?.incrementClicks()
            
        } else {
            let currentCell = tableView.cellForRow(at: indexPath)! as! FeedTableViewCell
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewViewController
            
            vc?.ref = currentCell.post?.ref
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
    
    //functions __________________________________________________________________________________________________________

    @objc func loadData() {
        activityIndicator.startAnimating()
        
        var timeStampQuery:Date
        let minute:TimeInterval = 60.0
        let hour:TimeInterval = minute * 60.0
        let day:TimeInterval = hour * 24.0
        let week:TimeInterval = day * 7.0
        let month:TimeInterval = day * 30.0
        
        switch(sortBy) {
            
        case "day": timeStampQuery = Date().addingTimeInterval(-day)
            break
        case "week": timeStampQuery = Date().addingTimeInterval(-week)
            break
        case "month": timeStampQuery = Date().addingTimeInterval(-month)
            break
        default: timeStampQuery = Date().addingTimeInterval(-day)
            break
        }
        
        
        var query = db.collection("posts").whereField("timeStamp", isGreaterThanOrEqualTo: timeStampQuery).whereField("sport", isEqualTo: sport)
        
        if sport == "ALL" {
            query = db.collection("posts").whereField("timeStamp", isGreaterThanOrEqualTo: timeStampQuery)
        } else {
            
        }
        
        query.getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
//
                self.postArray = querySnapshot!.documents.compactMap({Post(dictionary: $0.data())})
                
                //sort arrays
                if self.latestOrHot == "latest" {
                    self.postArray = self.postArray.sorted(by: {$0.timeStamp.dateValue() > $1.timeStamp.dateValue() })
                    
                } else if self.latestOrHot == "hot"{
                    self.postArray = self.postArray.sorted(by: {$0.score > $1.score })
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
                
            }
        }
        refresher.endRefreshing()
    }
    
    func loadPromotedData() {
        
        var timeStampQuery:Date
        let minute:TimeInterval = 60.0
        let hour:TimeInterval = minute * 60.0
        let day:TimeInterval = hour * 24.0
        let week:TimeInterval = day * 7.0
        let month:TimeInterval = day * 30.0
        
        switch(sortBy) {
            
        case "day": timeStampQuery = Date().addingTimeInterval(-day)
            break
        case "week": timeStampQuery = Date().addingTimeInterval(-week)
            break
        case "month": timeStampQuery = Date().addingTimeInterval(-month)
            break
        default: timeStampQuery = Date().addingTimeInterval(-day)
            break
        }
        
        
        var query = db.collection("promotedPosts").whereField("timeStamp", isGreaterThanOrEqualTo: timeStampQuery).whereField("sport", isEqualTo: sport)
        
        if sport == "ALL" {
            query = db.collection("promotedPosts").whereField("timeStamp", isGreaterThanOrEqualTo: timeStampQuery)
        } else {
            
        }
        
        query.getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                //
                self.promotedPostArray = querySnapshot!.documents.compactMap({PromotedPost(dictionary: $0.data())})
                
//                //sort arrays
//                if self.latestOrHot == "latest" {
//                    self.promotedPostArray = self.postArray.sorted(by: {$0.timeStamp.dateValue() > $1.timeStamp.dateValue() })
//
//                } else if self.latestOrHot == "hot"{
//                    self.postArray = self.postArray.sorted(by: {$0.score > $1.score })
//                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
        refresher.endRefreshing()
    }
    
    
    func getImage(image: UIImage) {
        imageToPass = image
    }
    
    func didTapOnImage(post: Post) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController
        vc?.post = post
        present(vc!, animated: true, completion: nil)
    }
    
    func didTapOnLink(post: PromotedPost) {
        post.incrementLinkClicks()
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController
        vc?.link = post.link
        self.navigationController?.pushViewController(vc!, animated: true)
    }
 
    
    func checkForUpdates() {
        db.collection("posts").whereField("timeStamp", isLessThan: Date())
            .addSnapshotListener {
                querySnapshot, error in
                guard let snapshot = querySnapshot else {return}
                
                snapshot.documentChanges.forEach {
                    diff in
                    if diff.type == .added{
                        self.postArray.append(Post(dictionary: diff.document.data())!)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
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
    
    func hideSortByWhenTapped() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissSortBy))
        tap.cancelsTouchesInView = false
        backGroundView.addGestureRecognizer(tap)
    }
    
 
    
    @objc func dismissSortBy() {
        
        if sortDay.isHidden == false {
        UIView.animate(withDuration: 0.3, animations: {
            self.sortDay.isHidden = true
            self.sortWeek.isHidden = true
            self.sortMonth.isHidden = true
            
        })
        }
    }
    
    @IBAction func sort(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Sort by:", message: nil, preferredStyle: .actionSheet)
        //day
        alertController.addAction(UIAlertAction(title: "Day", style: .default, handler: self.sortDayAlert))
        //week
        alertController.addAction(UIAlertAction(title: "Week", style: .default, handler: self.sortWeekAlert))
        //month
        alertController.addAction(UIAlertAction(title: "Month", style: .default, handler: self.sortMonthAlert))
        //cancel
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func sortDayAlert(alert: UIAlertAction!) {

        //change sortBy
        sortBy = "day"
        sortByText.text = "Sort by: \(sortBy)"
       
        //reload the data
        loadData()
    }
    
    func sortWeekAlert(alert: UIAlertAction!) {

        //change sortBy
        sortBy = "week"
        sortByText.text = "Sort by: \(sortBy)"
        
        //reload the data
        loadData()
    }
    
    func sortMonthAlert(alert: UIAlertAction!) {

        //change sortBy
        sortBy = "month"
        sortByText.text = "Sort by: \(sortBy)"
        
        //reload the data
        loadData()
    }
    
    @IBAction func changeSort(_ sender: Any) {
        if sortDay.isHidden == false {
            dismissSortBy()
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.sortDay.isHidden = false
                self.sortWeek.isHidden = false
                self.sortMonth.isHidden = false
                
            })
        }
    }
    
    @IBAction func latest(_ sender: Any) {
        latestOrHot = "latest"
      
        latest.selected()
        hot.setUp()
        
        //reload the data
        loadData()
        
    }
    @IBAction func hot(_ sender: Any) {
        latestOrHot = "hot"
        
        latest.setUp()
        hot.selected()
        
        //reload the data
        loadData()
    }
    
    @IBAction func all(_ sender: Any) {
        sport = "ALL"
        
        for button in sportsButtons {
            button.setUp()
        }
        
        all.selected()
        
        //reload the data
        loadData()
        
    }
    
    
    @IBAction func nba(_ sender: Any) {
        sport = "NBA"
        
        for button in sportsButtons {
            button.setUp()
        }
        
        nba.selected()
        
        //reload the data
        loadData()
    }
    
    
    @IBAction func nfl(_ sender: Any) {
        sport = "NFL"
      
        for button in sportsButtons {
            button.setUp()
        }
        
        nfl.selected()
        
        //reload the data
        loadData()
    }
    
    
    @IBAction func mlb(_ sender: Any) {
        sport = "MLB"
   
        for button in sportsButtons {
            button.setUp()
        }
        
        mlb.selected()
        
        //reload the data
        loadData()
    }
    
    
    @IBAction func nhl(_ sender: Any) {
        sport = "NHL"
 
        for button in sportsButtons {
            button.setUp()
        }
        
        nhl.selected()
        
        //reload the data
        loadData()
    }
   
}
