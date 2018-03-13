//
//  OverlayView.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/12.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit

class OverlayView: UIView {
    
    var topView: UIView?
    var bottomView: UIView?
    
    //将点击事件传递给previewView
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        if self.topView == nil || self.bottomView == nil {
            return false
        }
        
        //顶部和底部区域响应事件传递
        if self.topView!.point(inside: self.convert(point, to: self.topView), with: event) ||
            self.bottomView!.point(inside: self.convert(point, to: self.bottomView), with: event) {
            return true
        }
        return false
    }
    
    
    
    

}
