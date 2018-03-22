



//
//  BaseCameraViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/21.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos
import MobileCoreServices

class BaseCameraViewController: UIViewController {

    var previewView: PreviewView = PreviewView()
    var captureSession: AVCaptureSession?
    var activeInput: AVCaptureDeviceInput?
    // 创建会话队列
    private var videoQuene: DispatchQueue?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSubviews()
        
        self.setupSession()
        
        if self.captureSession != nil {
            self.previewView.setupSession(self.captureSession!)
            self.startSession()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.stopSession()
    }
    
    

    //MARK: UI 布局
    private func initSubviews() {
        
        self.view.backgroundColor = .white
        
        self.previewView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        self.view.addSubview(self.previewView)
    }
    
    
    //MARK: 设置会话
    private func setupSession () {
        
        self.captureSession = AVCaptureSession()
        self.captureSession!.sessionPreset = AVCaptureSession.Preset.high
        
        //设置视频输入设备
        let videoDevice: AVCaptureDevice = AVCaptureDevice.default(for: .video)!
        
        do {
            try self.activeInput = AVCaptureDeviceInput(device: videoDevice)
        } catch {
            YNLog("error: \(error)")
            return  //报错直接返回，不继续
        }
        
        if self.captureSession!.canAddInput(self.activeInput!) {
            self.captureSession!.addInput(self.activeInput!)
        }
        
        //创建会话队列
        self.videoQuene = DispatchQueue(label: "com.xxx.videoQuene")
    }
    
    //MARK: 会话启动
    private func startSession () {
        
        if !self.captureSession!.isRunning {
            
            self.videoQuene!.async {
                self.captureSession!.startRunning()
            }
        }
    }
    
    //MARK: 会话停止
    private func stopSession () {
        if self.captureSession!.isRunning {
            
            self.videoQuene!.async {
                self.captureSession!.stopRunning()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
