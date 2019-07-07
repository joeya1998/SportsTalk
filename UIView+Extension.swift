//
//  UIView+Extension.swift
//  tabbedTest
//
//  Created by Joey Aberasturi on 1/8/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import Foundation
import UIKit

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

