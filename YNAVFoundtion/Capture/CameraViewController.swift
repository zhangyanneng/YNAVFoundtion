//
//  CameraViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/12.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos
import MobileCoreServices

enum CameraMode {
    case video
    case photo
}

fileprivate var kContent_for_kvo = "adjustingExposure_flag"
fileprivate let kExposure_KeyPath = "adjustingExposure"

class CameraViewController: UIViewController,AVCaptureFileOutputRecordingDelegate {
    
    var mediaType: CameraMode = .photo
    
    var overlayView: OverlayView = OverlayView()
    var previewView: PreviewView = PreviewView()
//    var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer() //
    
    var captureSession: AVCaptureSession?
    var videoInput: AVCaptureDeviceInput?
    var audioInput: AVCaptureDeviceInput?
    var imageOutput: AVCaptureStillImageOutput?
    var movieOutput: AVCaptureMovieFileOutput?
    var outputURL: URL?
    private var outImage: UIImage? //保存拍照的照片
    var thumbImgBtn:UIButton?
    var timer: Timer?
    
    // 创建会话队列
    private var videoQuene: DispatchQueue?
    
    // 检查相机设备数量
    private var cameraCount = AVCaptureDevice.devices(for: .video).count
    
    var titleLabel: UILabel?
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSubviews()
        
        self.setupSession()
        
        if self.captureSession != nil {
            self.previewView.setupSession(self.captureSession!)
            self.startSession()
        }
        
        //videoZoomFactor设备的缩放因子，最大值为videoMaxZoomFactor，最小值为1.0 videoMaxZoomFactor由设备去决定
        if self.videoInput!.device.activeFormat.videoMaxZoomFactor > CGFloat(1.0) {
            YNLog("支持视频缩放")
//            self.videoInput!.device.videoZoomFactor  //可以设置缩放比例
//            self.videoInput!.device.ramp(toVideoZoomFactor: <#T##CGFloat#>, withRate: 1.0)
        }
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
            YNLog("error: \(error)")
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
            YNLog("error: \(error)")
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
            YNLog("error: \(error)")
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

    //MARK: 对焦
    private func focusAtPoint(_ point: CGPoint) {
        
        let device = self.videoInput!.device
        
        //查询设备是否支持对焦 ，自动对焦模式
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
            
            do {
                //锁定设备进行配置
                try device.lockForConfiguration()
            } catch {
                
                YNLog("error: \(error)")
                return
            }
    
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus
            
            //解除设备锁定
            device.unlockForConfiguration()
            
        }
    }
    
    //MARK: 曝光
    private func exposeAtPoint(_ point: CGPoint) {
        
        let device = self.videoInput!.device
        //检查设备是否支持曝光
        if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose) {
            
            do {
                try device.lockForConfiguration()
            } catch {
                
                YNLog("error: \(error)")
                return
            }
            
            device.exposurePointOfInterest = point
            device.exposureMode = .autoExpose
//            device.exposureDuration = 0.5 //曝光时间
            
            //KVO监听是否支持锁定曝光模式
            if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.locked) {
                
                device.addObserver(self, forKeyPath: kExposure_KeyPath, options: NSKeyValueObservingOptions.new, context: &kContent_for_kvo)
            }
            
            //解除设备锁定
            device.unlockForConfiguration()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &kContent_for_kvo {
        
            let device:AVCaptureDevice = object as! AVCaptureDevice
            
            device.removeObserver(self, forKeyPath: kExposure_KeyPath)
            
            if !device.isAdjustingExposure && device.isExposureModeSupported(AVCaptureDevice.ExposureMode.locked) {
                
                DispatchQueue.main.async {
                
                    do {
                        try device.lockForConfiguration()
                    } catch {
                        
                        YNLog("error: \(error)")
                        return
                    }
                    
                    device.exposureMode = .locked
                    device.unlockForConfiguration()
                    
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    //MARK:重置对焦和曝光
    private func resetFocusAndExposure(_ point: CGPoint) {
        
        let device = self.videoInput!.device
        
        do {
            try device.lockForConfiguration()
        } catch {
            
            YNLog("error: \(error)")
            return
        }
        
        //查询设备是否支持对焦 ，自动对焦模式
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
            
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus
            
        }
        
        //检查设备是否支持曝光
        if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose) {
            
            device.exposurePointOfInterest = point
            device.exposureMode = .autoExpose
        }
        
        device.unlockForConfiguration()
        
    }
    
    //MARK:闪光灯
    private func setCameraFlash(_ model: AVCaptureDevice.FlashMode) {
        
        let device = self.videoInput!.device
        
        if device.isFlashModeSupported(model) {
            
            do {
                try device.lockForConfiguration()
            } catch {
                
                YNLog("error: \(error)")
                return
            }
            
            device.flashMode = model
            device.unlockForConfiguration()
        }
    }
    
    //MARK: 手电筒
    private func setCameraTorch(_ model: AVCaptureDevice.TorchMode) {
        let device = self.videoInput!.device
        
        if device.isTorchModeSupported(model) {
            
            do {
                try device.lockForConfiguration()
            } catch {
                
                YNLog("error: \(error)")
                return
            }
            
            device.torchMode = model
            device.unlockForConfiguration()
        }
    }
    
    //MARK: 拍摄照片
    private func cameraStillImage () {
        
        let connection:AVCaptureConnection = self.imageOutput!.connection(with: .video)!
        //调整图片的方向
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = self.currentVideoOrientation()
        }
        
        self.imageOutput!.captureStillImageAsynchronously(from: connection) { (sampleBuffer, error) in
            
            if sampleBuffer != nil {
                //读取图片数据
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
                let image = UIImage(data: imageData!)
                self.thumbImgBtn!.setImage(image, for: .normal)
                
                //保存图片
                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
                
            } else {
                YNLog("error: \(String(describing: error))")
            }
        }
        
    }
    
    private func currentVideoOrientation () -> AVCaptureVideoOrientation {
        
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
            break
        case .landscapeRight:
             orientation = AVCaptureVideoOrientation.landscapeLeft
            break
        case .portraitUpsideDown:
             orientation = AVCaptureVideoOrientation.portraitUpsideDown
            break
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
            break
        }
        
        return orientation
    }
    
    @objc
    private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            YNLog("save image failed. error: \(String(describing: error))")
        }
    }
    
    //MARK: 拍摄视频
    private func startRecordingVideo() {
        
        if self.movieOutput!.isRecording {
            return
        }
        
        let connection:AVCaptureConnection = self.movieOutput!.connection(with: .video)!
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = self.currentVideoOrientation()
        }
        
        if connection.isVideoStabilizationSupported {
            //设置视频稳定模式
            connection.preferredVideoStabilizationMode = .auto
        }
        
        let device:AVCaptureDevice = self.videoInput!.device
        
        //摄像头平滑对焦模式
        if device.isSmoothAutoFocusEnabled {
            
            do {
                try device.lockForConfiguration()
            } catch {
                
                YNLog("error: \(error)")
                return
            }
            
            device.isSmoothAutoFocusEnabled = true
            
            device.unlockForConfiguration()
        }
        
        self.outputURL = self.uniqueURL()
        //开启录制
        self.movieOutput!.startRecording(to: self.outputURL!, recordingDelegate: self)
    }
    
    //录像开始录制的代理方法
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
    
        //设置定时器，显示录播时间
        self.startTimer()
    }
    
    //录像结束的代理方法
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        //结束定时器
        self.stopTimer()
        
        if error != nil {
            YNLog("error: \(String(describing: error))")
        } else {
            //保存到相册
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }, completionHandler: { (success, error) in
                
                if success {
                    //获取缩率图
                    let asset = AVAsset(url: outputFileURL)
                    let imageGenerator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                    imageGenerator.maximumSize = CGSize(width: 100.0, height: 0.0)
                    imageGenerator.appliesPreferredTrackTransform = true
                    
                    do {
                        let imageRef = try imageGenerator.copyCGImage(at: kCMTimeZero, actualTime: nil)
                        let image = UIImage(cgImage: imageRef)
                        DispatchQueue.main.async{
                            self.thumbImgBtn!.setImage(image, for: .normal)
                        }
                    } catch {
                        YNLog(error)
                    }
                    
                    YNLog("保存视频成功")
                } else {
                    YNLog("保存视频失败")
                }
                
            })
            
        }
        
        //移除视频的临时地址
         self.outputURL = nil
        
    }
    
    
    private func stopRecrdingVideo() {
        if self.movieOutput!.isRecording {
            self.movieOutput!.stopRecording()
        }
    }
    
    private func startTimer() {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
        //添加一个定时器
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateRecordTime), userInfo: nil, repeats: true)
        
    }
    //更新时间
    @objc
    private func updateRecordTime() {
        
        guard let time:CMTime = self.movieOutput?.recordedDuration else {return}
        
        let interval = CMTimeGetSeconds(time)
        
        let hours: Int = Int(interval / 3600)
        let minutes: Int = Int(Int(interval / 60) % 60)
        let seconds: Int = Int(Int(interval) % 60)
        
        self.titleLabel!.text  = String(format: "%02d:%02d:%02d", hours,minutes,seconds)
        
    }
    
    private func stopTimer() {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
    }
    
    private func uniqueURL()->URL? {
        
        let fileManager: FileManager = FileManager.default
        
        let timestamp = Date().timeIntervalSince1970
        
        
        let dirPath = "\(Int64(timestamp) * 1000 + Int64(arc4random_uniform(100)))".tmpDir()
        
        do {
            try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            YNLog("error:\(error)")
            return nil
        }
        
        let filePath: String = dirPath + "/"+"_video.mov"
        
        return URL(fileURLWithPath: filePath)
    }
    
    
    //MARK: UI 布局
    private func initSubviews() {
        
        self.previewView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        self.overlayView.frame = self.view.bounds
        self.overlayView.backgroundColor = UIColor.clear
        self.initOverlaySubviews()
        
       
        self.view.addSubview(self.previewView)
        self.view.addSubview(self.overlayView)
        
        
        //添加手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        self.previewView.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.previewView.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
        
        //双指双击
        let doubleDoubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleDoubleTap(_:)))
        doubleDoubleTap.numberOfTapsRequired = 2
        doubleDoubleTap.numberOfTouchesRequired = 2
        self.previewView.addGestureRecognizer(doubleDoubleTap)
    }
    
    //布局遮盖层
    private func initOverlaySubviews() {
        
        //顶部
        let topView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44))
        topView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        self.overlayView.addSubview(topView)
        self.overlayView.topView = topView
        //闪光灯
        let flashBtn = UIButton()
        flashBtn.frame = CGRect(x: 20, y: 0, width: 44, height: 44)
        flashBtn.setImage(UIImage(named:"flash_open"), for: .normal)
        flashBtn.setImage(UIImage(named:"flash_close"), for: .selected)
        topView.addSubview(flashBtn)
        flashBtn.addTarget(self, action: #selector(flashBtnClick(_:)), for: .touchUpInside)
        //标题 --用于显示视频时间
        let titleLabel = UILabel()
        titleLabel.text = "00:00:00"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.size = CGSize(width: 100, height: 21)
        titleLabel.center = CGPoint(x: topView.bounds.midX, y: topView.bounds.midY)
        topView.addSubview(titleLabel)
        titleLabel.isHidden = self.mediaType == .video ? false : true
        self.titleLabel = titleLabel
        
        //切换摄像头
        let cameraChangeBtn = UIButton()
        cameraChangeBtn.frame = CGRect(x: screenWidth - 44 - 20, y: 0, width: 44, height: 44)
        cameraChangeBtn.setImage(UIImage(named:"camera_change"), for: .normal)
        topView.addSubview(cameraChangeBtn)
        cameraChangeBtn.addTarget(self, action: #selector(cameraChangeBtnClick), for: .touchUpInside)
        
        //底部
        let bottomView = UIView(frame: CGRect(x: 0.0, y: screenHeight - 100, width: screenWidth, height: 100))
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
        self.thumbImgBtn = thumbnailBtn;
        
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
        
        let point = recognizer.location(in: self.previewView)
        
        self.focusAtPoint(self.previewView.captureDevicePointConverted(point))
        
        self.previewView.focusViewAnimation(point)
        
    }
    
    @objc
    private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        
        let point = recognizer.location(in: self.previewView)
        
        self.exposeAtPoint(self.previewView.captureDevicePointConverted(point))
        
        self.previewView.exposeViewAnimation(point)
        
    }
    
    @objc
    private func handleDoubleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        
        let point = CGPoint(x: 0.5, y: 0.5)
        
        self.resetFocusAndExposure(point)
        
        if  self.videoInput!.device.isAutoFocusRangeRestrictionSupported &&
            self.videoInput!.device.isExposurePointOfInterestSupported {
            self.previewView.resetFocusAndExposeViewAnimation()
        }
        
    }
    
    //MARK: 点击事件
    @objc
    private func flashBtnClick(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected { //关闭闪光灯
            self.setCameraFlash(.on)
        } else {
            self.setCameraFlash(.off)
        }
        
    }
    
    @objc
    private func cameraChangeBtnClick() {
        
        self.switchCameras()
    }
    
    @objc
    private func takeBtnClick() {
        
        if self.mediaType == .photo {
            self.cameraStillImage()
        } else {
            if self.movieOutput!.isRecording {
                self.stopRecrdingVideo()
            } else {
                self.startRecordingVideo()
            }
        }
    }
    
    @objc
    private func thumbnailBtnClick() {
        
        let imageController = UIImagePickerController()
        imageController.sourceType = .photoLibrary
        if self.mediaType == .video {
            imageController.mediaTypes = [kUTTypeMovie as String]
        } else {
            imageController.mediaTypes = [kUTTypeImage as String]

        }
        self.present(imageController, animated: true, completion: nil)
    }
    
    @objc
    private func cancelBtnClick() {
        
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
        
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
