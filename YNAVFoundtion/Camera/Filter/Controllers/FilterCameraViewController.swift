



//
//  FilterCameraViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/22.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit

class FilterCameraViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate {

    //视频过滤处理,当前使用的是
    private var previewView: FilterPreviewView?
    private var captureSession: AVCaptureSession?
    private var activeInput: AVCaptureDeviceInput?
    private var videoQuene: DispatchQueue?
    
    //使用系统coreImage自带的40多种滤镜样式，对摄像头捕获的图片进行过滤
    let photoFilter = ["CIPhotoEffectChrome","CIPhotoEffectFade","CIPhotoEffectInstant","CIPhotoEffectMono","CIPhotoEffectNoir","CIPhotoEffectProcess","CIPhotoEffectTonal","CIPhotoEffectTransfer"]
    
    var videoDataOutput: AVCaptureVideoDataOutput?
    var audioDataOutput: AVCaptureAudioDataOutput?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initSubviews()
        
        self.setupSession()

        self.startSession()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.stopSession()
    }
    
    
    func initSubviews() {
        
        self.view.backgroundColor = .white

        /*
         openGLES2 渲染上下文提供的 OpenGL ES 的版本
         */
        let eaglContent: EAGLContext = EAGLContext(api: EAGLRenderingAPI.openGLES2)!
        let ciContent: CIContext = CIContext(eaglContext: eaglContent, options: nil)
        self.previewView = FilterPreviewView(frame: self.view.bounds, context: eaglContent)
        self.view.addSubview(self.previewView!)
        //设置滤镜模式，
        self.previewView!.filter = CIFilter(name: photoFilter[3])
        self.previewView!.coreImageContext = ciContent
        
        //底部
        let bottomView = UIView(frame: CGRect(x: 0.0, y:screenHeight - 100, width: screenWidth, height: 100))
        bottomView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        self.view.addSubview(bottomView)
        
        //拍照按钮
        let takeBtn = CameraButton()
        takeBtn.size = CGSize(width: 68.0, height: 68.0)
        takeBtn.center = CGPoint(x: bottomView.width * 0.5, y: bottomView.height * 0.5)
        takeBtn.backgroundColor = UIColor.clear
        takeBtn.cameraMode = CameraMode.video
        bottomView.addSubview(takeBtn)
        takeBtn.addTarget(self, action: #selector(takeBtnClick(_:)), for: .touchUpInside)
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
        
        self.videoDataOutput = AVCaptureVideoDataOutput()
        self.videoDataOutput!.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey):kCVPixelFormatType_32BGRA]
        self.videoDataOutput!.alwaysDiscardsLateVideoFrames = false
        self.videoDataOutput!.setSampleBufferDelegate(self, queue: self.videoQuene)
        
        if self.captureSession!.canAddOutput(self.videoDataOutput!) {
            self.captureSession!.addOutput(self.videoDataOutput!)
        }
        
        self.audioDataOutput = AVCaptureAudioDataOutput()
        self.audioDataOutput!.setSampleBufferDelegate(self, queue: self.videoQuene)
        
        if self.captureSession!.canAddOutput(self.audioDataOutput!) {
            self.captureSession!.addOutput(self.audioDataOutput!)
        }
        
        self.videoDataOutput!.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
        
        self.audioDataOutput?.recommendedAudioSettingsForAssetWriter(writingTo: .mov)
        
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
    
    //音视频都调用改方法
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //如果是视频
        if output == self.videoDataOutput {
            //将视频输出对象渲染到previewView上
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            let sourceImage = CIImage(cvPixelBuffer: imageBuffer!)
            
            self.previewView!.setImage(sourceImage)
        }
        
    }
    
    @objc
    private func takeBtnClick(_ sender: UIButton) {
        
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
