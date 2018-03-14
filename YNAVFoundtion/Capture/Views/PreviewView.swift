//
//  PreviewView.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/13.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {

    private var focusView: UIView = UIView()
    private var exposeView: UIView = UIView()
    private var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.layer.addSublayer(self.previewLayer)
        self.previewLayer.videoGravity = .resizeAspectFill
        
        self.focusView.frame = CGRect(x: 0.0, y: 0.0, width: 150.0, height: 150.0)
        self.focusView.backgroundColor = UIColor.clear
        self.focusView.layer.borderWidth = 5.0
        self.focusView.layer.borderColor = RGB(r: 255.0, g: 230.0, b: 100.0).cgColor
        self.focusView.isHidden = true
        
        
        self.exposeView.frame = CGRect(x: 0.0, y: 0.0, width: 150.0, height: 150.0)
        self.exposeView.backgroundColor =  UIColor.clear
        self.exposeView.layer.borderWidth = 5.0
        self.exposeView.layer.borderColor = RGB(r: 80.0, g: 148.0, b: 255.0).cgColor
        self.exposeView.isHidden = true
        
        self.addSubview(self.focusView)
        self.addSubview(self.exposeView)
    }
    
    func setupSession(_ session: AVCaptureSession) {
        self.previewLayer.session = session
    }
    
    //屏幕和设备坐标转换
    func captureDevicePointConverted(_ fromPoint: CGPoint) -> CGPoint {
        return self.previewLayer.captureDevicePointConverted(fromLayerPoint: fromPoint)
    }
    
    //对焦动画显示
    func focusViewAnimation(_ point: CGPoint) {
       self.viewAniamtion(self.focusView, point: point)
    }
    
    //曝光动画显示
    func exposeViewAnimation(_ point: CGPoint) {
       self.viewAniamtion(self.exposeView, point: point)
    }
    //重置对焦和曝光动画 --在最中间弹窗
    func resetFocusAndExposeViewAnimation(){
        
        let centerPoint = self.previewLayer.layerPointConverted(fromCaptureDevicePoint: CGPoint(x: 0.5, y: 0.5))
        
        self.focusView.isHidden = false
        self.exposeView.isHidden = false
        self.focusView.center = centerPoint
        self.exposeView.center = centerPoint
        self.exposeView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            
            self.focusView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
            self.exposeView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0)
            
        }) { (complate) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                
                self.focusView.isHidden = true
                self.exposeView.isHidden = true
                self.focusView.transform = CGAffineTransform.identity
                self.exposeView.transform = CGAffineTransform.identity
            })
        }
        
    }
    
    private func viewAniamtion(_ view:UIView, point: CGPoint) {
        
        view.isHidden = false
        view.center = point
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            
            view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0)
            
        }) { (complate) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                
                view.isHidden = true
                view.transform = CGAffineTransform.identity
            })
        }
    }
    
    
}
