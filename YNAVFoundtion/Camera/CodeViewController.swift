//
//  CodeViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/21.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class CodeViewController: BaseCameraViewController,AVCaptureMetadataOutputObjectsDelegate {

    var metadataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.captureSession!.sessionPreset = .vga640x480
        
        if self.activeInput!.device.isAutoFocusRangeRestrictionSupported {
            
            do {
                try self.activeInput!.device.lockForConfiguration()
                self.activeInput!.device.autoFocusRangeRestriction = .near
                self.activeInput!.device.unlockForConfiguration()
            } catch {
                YNLog(error)
            }
        }
        
        self.setupSessionOutputs()
    }
    
    
    
    
    private func setupSessionOutputs() {
        
        self.metadataOutput = AVCaptureMetadataOutput()
        
        if self.captureSession!.canAddOutput(self.metadataOutput) {
            self.captureSession!.addOutput(self.metadataOutput)
            self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            self.metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,AVMetadataObject.ObjectType.aztec]
        } else {
            YNLog("failed to add metadataOuput")
        }
        
    }
    
    

    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        self.previewView.didDetectCodes(metadataObjects)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
