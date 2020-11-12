//
//  UIView+GradientLayer.swift
//  SwiftProjectStructure
//
//  Created by Krishna Patel on 28/06/18.
//  Copyright © 2018 Krishna. All rights reserved.
//

import Foundation
import UIKit

enum GradientDirection : Int {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
    case TopLeftToBottomRight
    case TopRightToBottomLeft
    case BottomLeftToTopRight
    case BottomRightToTopLeft
}
 let gradientLayer = CAGradientLayer()

extension UIView {
   
    func gradientBackground(ColorSet arrColor : [UIColor], direction : GradientDirection) {
        var arrCGColors : [CGColor] = [CGColor]()
        for color: UIColor? in arrColor {
            arrCGColors.append(color?.cgColor ?? UIColor.black as! CGColor)
        }
        
        
        gradientLayer.colors = arrCGColors
        self.layoutIfNeeded()
        gradientLayer.frame = self.bounds
        
        switch direction {
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            break;
            
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
            break;
            
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            break;
            
        case .TopLeftToBottomRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            break;
            
        case .TopRightToBottomLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
            break;
            
        case .BottomLeftToTopRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
            break;
            
        case .BottomRightToTopLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
            break;
            
        default: //Default Case is Top To Bottom
            break;
        }
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.clipsToBounds = true
        
    }

    
}
