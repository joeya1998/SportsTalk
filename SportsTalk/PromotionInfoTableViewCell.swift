//
//  PromotionInfoTableViewCell.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 7/3/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit

class PromotionInfoTableViewCell: UITableViewCell {

    @IBOutlet var content: UILabel!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var viewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var timeStamp: UILabel!
    @IBOutlet var score: UILabel!
    @IBOutlet var comments: UILabel!
    @IBOutlet var viewsPaidFor: UILabel!
    @IBOutlet var numViews: UILabel!
    @IBOutlet var postClicks: UILabel!
    @IBOutlet var linkClicks: UILabel!
    
    
    //variables
    var postID = ""
    var post:PromotedPost! = nil
    var delegate: FeedTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func imageClicked(_ sender: Any) {
        delegate?.didTapOnImage(post: post!)
    }
}
