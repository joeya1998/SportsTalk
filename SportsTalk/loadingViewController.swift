//
//  loadingViewController.swift
//  SportsTalk
//
//  Created by Joey Aberasturi on 6/17/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit

class loadingViewController: UIViewController {

    //outlets
    @IBOutlet var logo: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var background: UIView!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        background.setGradientBackground(colorOne: Colors.gradientGreen, colorTwo: Colors.gradientBlue)
        logo.image = Images.logo
        progressView.progress = 0.0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(loadingViewController.update), userInfo: nil, repeats: true)
       
    }
    
    @objc func update() {
        progressView.progress = progressFloat
    }
    

 

}
