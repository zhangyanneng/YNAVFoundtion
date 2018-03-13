//
//  VideoViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/9.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation


class VideoViewController: UIViewController {
    
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    var playerItem: AVPlayerItem?
    
    var content = 0  //作用是监听kvo变化
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置屏幕横屏播放
//        let value = UIInterfaceOrientation.landscapeLeft.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
        
        _initUI()
        loadLocalVideo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: content)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.playerItem?.removeObserver(self, forKeyPath: "status")
        
    }

    func _initUI() {

        self.navBarView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        self.tabBarView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        
        self.navBarView.addLine(.bottom, color: UIColor.lightGray)
        self.tabBarView.addLine(.top, color: UIColor.lightGray)
       
    }
    

    func loadLocalVideo() {
        
        /*
         AVAsset: 是一个抽象和不可变类，定义了媒体资源数据
         AVPlayerItem: 建立媒体资源动态数据模型，保存AVPlayer在播放资源时的呈现状态
         AVPlayer:  用于控制播放的视频媒体
         AVPlayerLayer: 基于Core Animation渲染图像和动画的框架，显示视频内容
         */
        
         //加载本地的视频资源
        let path = Bundle.main.url(forResource: "hubblecast", withExtension: "m4v")
        let asset = AVAsset(url: path!)
        self.playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer!.frame = CGRect(x: 0, y: 44, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 44 - 49)
        
        self.view.layer.addSublayer(self.playerLayer!)
        
        //KVO  监听播放条目的状态
        self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }
    
    @objc
    func deviceOrientationDidChange(_ notifiction: NSNotification) {
        
        
        var margin: CGFloat = 20.0
        
        if UIDevice.current.orientation.isLandscape {
            margin = 0.0
        }
        
        
        let sWidth = self.view.bounds.size.width
        let sHeight = self.view.bounds.size.height
        
        self.navBarView.frame = CGRect(x: CGFloat(0), y: margin, width: sWidth, height: CGFloat(44))
        
        self.tabBarView.frame = CGRect(x: CGFloat(0), y: sHeight - 44 - 49 - margin, width: sWidth, height: CGFloat(49))
        
        self.playerLayer!.frame = CGRect(x: 0, y: 44 + margin, width: sWidth, height: sHeight - 44 - 49 - margin)
        
    }
    
    
    @IBAction func closeBtnClick(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player?.play()
            //            self.playBtn.isHidden = true
        } else {
            
            self.player?.pause()
        }
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if content == self.content {
            
            if self.playerItem?.status == AVPlayerItemStatus.readyToPlay {
                 print("self.player.status== readyToPlay")
            } else {
                 print("self.player.status=\(self.player?.status)")
            }
            
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
