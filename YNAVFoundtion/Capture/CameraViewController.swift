//
//  CameraViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/12.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

enum CameraMode {
    case video
    case photo
}


class CameraViewController: UIViewController {
    
    var mediaType: CameraMode = .photo
    
    var overlayView: OverlayView = OverlayView()
    var previewView: UIView = UIView()
    var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer() //
    
    var captureSession: AVCaptureSession?
    var videoInput: AVCaptureDeviceInput?
    var audioInput: AVCaptureDeviceInput?
    var imageOutput: AVCaptureStillImageOutput?
    var movieOutput: AVCaptureMovieFileOutput?
    var outputURL: NSURL?
    
    // 创建会话队列
    private var videoQuene: DispatchQueue?
    
    // 检查相机设备数量
    private var cameraCount = AVCaptureDevice.devices(for: .video).count
    
    let viewW = UIScreen.main.bounds.size.width
    let viewH = UIScreen.main.bounds.size.height
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSubviews()
        
        self.setupSession()
        
        self.previewLayer.session = self.captureSession
        
        self.startSession()
    }
    
    //MARK: 设置会话
    private func setupSession () {
        
        self.captureSession = AVCaptureSession()
        self.captureSession!.sessionPreset = AVCaptureSession.Preset.high
        
        //设置视频输入设备
        let videoDevice: AVCaptureDevice = AVCaptureDevice.default(for: .video)!
        
        do {
            try self.videoInput = AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print(error)
            return  //报错直接返回，不继续
        }
        
        if self.captureSession!.canAddInput(self.videoInput!) {
            self.captureSession!.addInput(self.videoInput!)
        }
        
        //添加音频输入设备
        let audioDevice: AVCaptureDevice = AVCaptureDevice.default(for: .audio)!
        
        do {
            try self.audioInput = AVCaptureDeviceInput(device: audioDevice)
        } catch {
            print(error)
            return  //报错直接返回，不继续
        }
        
        if self.captureSession!.canAddInput(self.audioInput!) {
            self.captureSession!.addInput(self.audioInput!)
        }
        
        self.imageOutput = AVCaptureStillImageOutput()
        self.imageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG] //输出JPEG格式图片
        
        if self.captureSession!.canAddOutput(self.imageOutput!) {
            self.captureSession!.addOutput(self.imageOutput!)
        }
        
        self.movieOutput = AVCaptureMovieFileOutput()
        
        if self.captureSession!.canAddOutput(self.movieOutput!) {
            self.captureSession!.addOutput(self.movieOutput!)
        }
        
        //创建会话队列
        self.videoQuene = DispatchQueue(label: "com.xxx.videoQuene")
    }
    
    
    //MARK: 会话启动
    private func startSession () {
        
        if !self.captureSession!.isRunning {
            
            self.videoQuene!.async {
                self.captureSession?.startRunning()
            }
        }
    }
    
    //MARK: 会话停止
    private func stopSession () {
        if self.captureSession!.isRunning {
            
            self.videoQuene!.async {
                self.captureSession?.stopRunning()
            }
        }
    }
    
    //MARK: 切换摄像头
    private func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice {
        
        let devices = AVCaptureDevice.devices(for: .video)
        
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return devices.first!
    }
    
    private func switchCameras() {
        
        if self.cameraCount <= 1 {
            //没有设备或只有一个，直接返回
            return
        }
        
        //获取未使用的摄像头
        var inactiveDevice: AVCaptureDevice
        if self.videoInput!.device.position == .back {
            inactiveDevice = self.cameraWithPosition(.front)
        } else {
            inactiveDevice = self.cameraWithPosition(.back)
        }
        
        var newVideoInput:AVCaptureDeviceInput
        do {
            newVideoInput = try AVCaptureDeviceInput(device: inactiveDevice)
        } catch {
            print(error)
            return
        }
        
        self.captureSession!.beginConfiguration()
        
        self.captureSession!.removeInput(self.videoInput!)
        
        if self.captureSession!.canAddInput(newVideoInput) {
            self.captureSession!.addInput(newVideoInput)
            self.videoInput = newVideoInput
        } else {
            self.captureSession!.addInput(self.videoInput!)
        }

        //提交修改的配置，否则不会生效
        self.captureSession!.commitConfiguration()
    }

    //对焦和曝光
    private func focusAtPoint(_ point: CGPoint) {
        
        let device = self.videoInput!.device
        
        //查询设备是否支持对焦 ，自动对焦模式
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
            
            do {
                //锁定设备进行配置
                try device.lockForConfiguration()
            } catch {
                
                print(error)
                return
            }
    
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus
            
            //解除设备锁定
            device.unlockForConfiguration()
            
        }
        
    }
    
    
    //UI 布局
    private func initSubviews() {
        
        self.previewView.frame = CGRect(x: 0, y: 0, width: viewW, height: viewH)
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: viewW, height: viewH)
        self.previewView.layer.addSublayer(self.previewLayer)
        self.previewView.backgroundColor = UIColor.white
        
        self.overlayView.frame = self.view.bounds
        self.overlayView.backgroundColor = UIColor.clear
        self.initOverlaySubviews()
        
       
        self.view.addSubview(self.previewView)
        self.view.addSubview(self.overlayView)
        
        self.previewLayer.videoGravity = .resizeAspectFill
        
        //添加手势
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        self.previewView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    //布局遮盖层
    private func initOverlaySubviews() {
        
        //顶部
        let topView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: viewW, height: 44))
        topView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        self.overlayView.addSubview(topView)
        self.overlayView.topView = topView
        //闪光灯
        let flashBtn = UIButton()
        flashBtn.frame = CGRect(x: 20, y: 0, width: 44, height: 44)
        flashBtn.setImage(UIImage(named:"flash_open"), for: .normal)
        flashBtn.setImage(UIImage(named:"flash_close"), for: .selected)
        topView.addSubview(flashBtn)
        flashBtn.addTarget(self, action: #selector(flashBtnClick), for: .touchUpInside)
        //标题 --用于显示视频时间
        let titleLabel = UILabel()
        titleLabel.text = "00:00:00"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: topView.bounds.midX, y: topView.bounds.midY)
        topView.addSubview(titleLabel)
        titleLabel.isHidden = self.mediaType == .video ? false : true
        
        //切换摄像头
        let cameraChangeBtn = UIButton()
        cameraChangeBtn.frame = CGRect(x: viewW - 44 - 20, y: 0, width: 44, height: 44)
        cameraChangeBtn.setImage(UIImage(named:"camera_change"), for: .normal)
        topView.addSubview(cameraChangeBtn)
        cameraChangeBtn.addTarget(self, action: #selector(cameraChangeBtnClick), for: .touchUpInside)
        
        //底部
        let bottomView = UIView(frame: CGRect(x: 0.0, y: viewH - 100, width: viewW, height: 100))
        bottomView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        self.overlayView.addSubview(bottomView)
        self.overlayView.bottomView = bottomView
        
        //拍照按钮
        let takeBtn = CameraButton()
        takeBtn.size = CGSize(width: 68.0, height: 68.0)
        takeBtn.center = CGPoint(x: bottomView.width * 0.5, y: bottomView.height * 0.5)
        takeBtn.backgroundColor = UIColor.clear
        takeBtn.cameraMode = self.mediaType
        bottomView.addSubview(takeBtn)
        takeBtn.addTarget(self, action: #selector(takeBtnClick), for: .touchUpInside)
        
        //缩略图按钮
        let thumbnailBtn = UIButton()
        thumbnailBtn.size = CGSize(width: 50, height: 50)
        thumbnailBtn.center = CGPoint(x: takeBtn.x * 0.5, y: bottomView.height * 0.5)
        thumbnailBtn.backgroundColor = UIColor.black
        bottomView.addSubview(thumbnailBtn)
        thumbnailBtn.addTarget(self, action: #selector(thumbnailBtnClick), for: .touchUpInside)
        
        //取消按钮
        let cancelBtn = UIButton()
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.sizeToFit()
        cancelBtn.center = CGPoint(x: takeBtn.right + (bottomView.width - takeBtn.right) * 0.5, y: bottomView.height * 0.5)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        bottomView.addSubview(cancelBtn)
        
    }
    
    //MARK: 手势点击方法
    @objc
    private func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        
        print("点击了手势")
    }
    
    //MARK: 点击事件
    @objc
    private func flashBtnClick() {
        
    }
    
    @objc
    private func cameraChangeBtnClick() {
        
        self.switchCameras()
    }
    
    @objc
    private func takeBtnClick() {
        
    }
    
    @objc
    private func thumbnailBtnClick() {
        
    }
    
    @objc
    private func cancelBtnClick() {
        self.dismiss(animated: true, completion: nil)
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
