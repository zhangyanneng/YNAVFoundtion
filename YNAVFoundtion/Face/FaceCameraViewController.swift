//
//  FaceCameraViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/16.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation

class FaceCameraViewController: CameraViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    var metadataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //人脸检测， 在CoreImage框架中 CIDetector CIFaceFeature
     
        self.addMetadataOutput() 
    }
    
    func addMetadataOutput() {
        
        if self.captureSession!.canAddOutput(self.metadataOutput) {
            self.captureSession?.addOutput(self.metadataOutput)
            self.metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
            self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
        } else {
            YNLog("Faild to still image oupt")
        }
    }
    
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for face:AVMetadataFaceObject in metadataObjects as! [AVMetadataFaceObject] {
            YNLog("face detected ID: \(face.faceID)")
            YNLog("face bounds: \(face.bounds)")
        }
        
        
        
    }
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
