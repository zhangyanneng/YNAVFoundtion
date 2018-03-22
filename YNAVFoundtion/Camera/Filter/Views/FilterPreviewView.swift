//
//  FilterPreviewView.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/22.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import GLKit

class FilterPreviewView: GLKView {
    
    var filter: CIFilter?
    var coreImageContext: CIContext?
    var drawableBounds: CGRect?
    
    override init(frame: CGRect, context: EAGLContext) {
        super.init(frame: frame, context: context)
        
        self.enableSetNeedsDisplay = false
        self.backgroundColor = UIColor.black
        self.isOpaque = true
        self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))
        
        self.bindDrawable()
        self.drawableBounds = self.bounds
        self.drawableBounds!.size.width = CGFloat(self.drawableWidth)
        self.drawableBounds!.size.height = CGFloat(self.drawableHeight)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ sourceImage:CIImage) {
        
        //定义绘制区域
        self.bindDrawable()
        
        guard self.filter != nil else { return }
        
        self.filter!.setValue(sourceImage, forKey: kCIInputImageKey)
        
        guard let filteredImage:CIImage = self.filter!.outputImage else { return }
        
        let cropRect = self.centerCropImageRect(sourceImage.extent, previewRect: self.drawableBounds!)
        self.coreImageContext!.draw(filteredImage, in: self.drawableBounds!, from: cropRect)
        
        self.display()
        
        self.filter!.setValue(nil, forKey: kCIInputImageKey)
        
    }
    
    //剪辑视频图像，保持屏幕宽高比
    func centerCropImageRect(_ sourceRect: CGRect, previewRect: CGRect) -> CGRect {
        
        let sourceAspectRatio = sourceRect.size.width / sourceRect.size.height
        let previewAspectRatio = previewRect.size.width / previewRect.size.height
        
        var drawRect = sourceRect
        
        if sourceAspectRatio > previewAspectRatio {
            let scaledHeight = drawRect.size.height * previewAspectRatio
            drawRect.origin.x += (drawRect.size.width - scaledHeight) * 0.5
            drawRect.size.width = scaledHeight
        } else {
            drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspectRatio) * 0.5
            drawRect.size.height = drawRect.size.width / previewAspectRatio
        }
        
        return drawRect
    }
    
}
