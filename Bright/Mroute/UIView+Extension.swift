//
//  UIView + Extension.swift
//  Mroute
//
//  Created by Zhongheng Hu on 8/5/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setGradientBackgroundColor(colorOne: UIColor, colorTwo: UIColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.8, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.2, y: 0.3)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
