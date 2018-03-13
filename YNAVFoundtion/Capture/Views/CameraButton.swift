//
//  CameraButton.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/12.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit

class CameraButton: UIButton {

    private var _cameraMode: CameraMode?
    var cameraMode: CameraMode? {

        get{
            return _cameraMode;
        }
        set{
            _cameraMode = newValue;
            
            let color = _cameraMode == .video ? UIColor.red : UIColor.white
            addLayer(color)
        }
    }
    
    private func addLayer(_ color: UIColor) {
        
        
        self.layer.cornerRadius = self.bounds.size.width * 0.5
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 5.0
        
        let circleLayer = CALayer()
        circleLayer.backgroundColor = color.cgColor
        circleLayer.bounds = self.bounds.insetBy(dx: 8.0, dy: 8.0)
        circleLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleLayer.cornerRadius = circleLayer.bounds.size.width * 0.5
        self.layer.addSublayer(circleLayer)
    }
}
