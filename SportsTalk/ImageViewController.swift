//
//  ImageViewController.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 5/30/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, //UIScrollViewDelegate,
UIGestureRecognizerDelegate {

    //variables
    var post: Post!
    var startPositionY:CGFloat! = 0.0
    var startPositionX:CGFloat! = 0.0
    var topBarrier: CGFloat!
    var bottomBarrier: CGFloat!
    var viewHeight: CGFloat!
    var viewWidth: CGFloat!
    var centerY: CGFloat!
    var centerX: CGFloat!
    var imageHeight:CGFloat! = 0.0
    var imageWidth:CGFloat!
    var aspectRatio: CGFloat!
    var cumulativeScale:CGFloat = 1.0
    var maxScale:CGFloat = 3.5
    var minScale:CGFloat = 1.0
    
    //outlets
    @IBOutlet var backGroundView: UIView!
    @IBOutlet var secondView: UIView!
    @IBOutlet var viewConstraint: NSLayoutConstraint!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var viewO: UIView!
    
    //main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewHeight = self.backGroundView.frame.height
        viewWidth = self.backGroundView.frame.width
        centerY = viewHeight/2
        centerX = viewWidth/2
        imageView.center = CGPoint(x: centerX, y: centerY)
        
        topBarrier = viewHeight * 0.25
        bottomBarrier = viewHeight * 0.75

        backGroundView.backgroundColor = UIColor(white: 0, alpha: 1)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        
        imageView.loadImageUsingCacheWithUrlString(urlString: post.imageString) {
            
            self.imageHeight = self.imageView.image?.size.height
            self.imageWidth = self.imageView.image?.size.width
            self.aspectRatio = self.imageWidth / self.imageHeight
            self.imageHeight = self.viewWidth/self.aspectRatio
            self.viewConstraint.constant = self.imageHeight
        }
    }

    @IBAction func pinchGesture(_ gesture: UIPinchGestureRecognizer) {

        guard secondView != nil else {return}
        let pinchCenter = CGPoint(x: gesture.location(in: secondView).x - secondView.bounds.midX, y: gesture.location(in: secondView).y - secondView.bounds.midY)
        
        secondView?.transform = (secondView?.transform)!.translatedBy(x: pinchCenter.x, y: pinchCenter.y).scaledBy(x: gesture.scale, y: gesture.scale).translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
        
        cumulativeScale *= gesture.scale
        gesture.scale = 1.0

        if gesture.state == .ended {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.secondView?.transform = CGAffineTransform.identity
            })
            cumulativeScale = 1.0
        }
    }
    
    
    @IBAction func panGestureRec(_ sender: UIPanGestureRecognizer) {
        
            let image = sender.view!
            let point = sender.translation(in: view)
            image.center = CGPoint(x: centerX, y: view.center.y + point.y)
            
            backGroundView.backgroundColor = UIColor(white: 0, alpha: (centerY - abs(centerY - image.center.y)) / centerY)
            
            if sender.state == UIGestureRecognizer.State.ended {
                if image.center.y < topBarrier {
                    UIView.animate(withDuration: 0.2, animations:  {
                        
                        image.center = CGPoint(x: self.centerX, y: -700.0)
                        
                    }){ (finished) in
                        if finished {
                            
                            self.dismiss(animated: false, completion: nil)
                            
                        }
                    }
                } else if image.center.y > bottomBarrier {
                    UIView.animate(withDuration: 0.2, animations:  {
                        
                        image.center = CGPoint(x: self.centerX, y: 1000.0)
                        
                    }){ (finished) in
                        if finished {
                            
                            self.dismiss(animated: false, completion: nil)
                            
                        }
                    }
                    
                } else {
                    
                    UIView.animate(withDuration: 0.2){
                        image.center = CGPoint(x: self.centerX, y: self.centerY)
                    }
                    backGroundView.backgroundColor = UIColor(white: 0, alpha: 1)

                }
        }
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        let tap = CGPoint(x: sender.location(in: secondView).x - secondView.bounds.midX, y: sender.location(in: secondView).y - secondView.bounds.midY)
        
        //if zoomed in all the way
        if cumulativeScale == maxScale {
            UIView.animate(withDuration: 0.2, animations:  {
                self.secondView.transform = CGAffineTransform.identity
            })
            cumulativeScale = minScale
        }
        
//        //if zoomed in somewhat
//        else if cumulativeScale > minScale && cumulativeScale < maxScale {
//            UIView.animate(withDuration: 0.2, animations:  {
//                self.secondView.transform = CGAffineTransform(scaleX: 3.5/self.cumulativeScale, y: 3.5/self.cumulativeScale)
//            })
//            cumulativeScale = maxScale
//        }
        
        //if zoomed out
        else if cumulativeScale == 1.0 {
            UIView.animate(withDuration: 0.2, animations:  {
                self.secondView.transform = CGAffineTransform(scaleX: 3.5, y: 3.5).translatedBy(x: -tap.x, y: -tap.y)
            })
            cumulativeScale = maxScale
        }

    }

}
