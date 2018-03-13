//
//  UIView+AddLine.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/9.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit


extension UIView {
    
    enum ADDLINEPosition {
        case top
        case left
        case bottom
        case right
    }
    
    func addLine(_ position: ADDLINEPosition, color: UIColor) {
        self.addLine(position, color: color, width: CGFloat(0.5))
    }
    
    func addLine(_ position: ADDLINEPosition, color: UIColor, width: CGFloat) {
        
        let layer = CALayer()
        layer.backgroundColor = color.cgColor
        
        switch position {
        case .left:
            layer.frame = CGRect(x: CGFloat(0.0), y:CGFloat(0.0), width: width, height: self.bounds.size.height)
        case .right:
            layer.frame = CGRect(x: self.bounds.size.width - width, y: CGFloat(0.0), width: width, height: self.bounds.size.height)
        case .top:
            layer.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: self.bounds.size.width, height: width)
        case .bottom:
            layer.frame = CGRect(x: CGFloat(0.0),  y:self.bounds.size.height - width, width:self.bounds.size.width, height: width)
        }
        
        self.layer .addSublayer(layer)
    }
    
    
    
    
    
    
    
    
    
    
    
}
