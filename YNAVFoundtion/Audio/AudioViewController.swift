//
//  AudioViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/6.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer? //必须设置私有属性接受，否则音频播放不了
    var playing: Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _initPlayer() // 初始化配置
        //监听音频中断会话通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        
        //线路改变的监听，比如耳机插入，拔出
        NotificationCenter.default.addObserver(self, selector: #selector(changeRouteNotification(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    
    fileprivate func _initPlayer() {
        
        let url = Bundle.main.url(forResource: "sound", withExtension: "caf")
        do {
            let player = try AVAudioPlayer(contentsOf: url!)
            player.volume = 0.8 //音量 0.0 to 1.0.
            player.rate = 0.4 
            player.numberOfLoops = -1  //循环次数，-1是无限循环
            player.enableRate = true
            audioPlayer = player
        } catch {
            print(error)
        }
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        
        if !self.playing {
            self.audioPlayer?.prepareToPlay();
            self.audioPlayer?.play()
            self.playing = true
        }
        
    }

    @IBAction func pauseAction(_ sender: UIButton) {
        
        if self.playing {
            self.audioPlayer?.pause()
            self.playing = false
        }
        
    }
    
    @IBAction func stopAction(_ sender: UIButton) {
        
        if self.playing {
            self.audioPlayer?.stop()
            self.playing = false
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc
    func handleNotification(_ notification: Notification) {
        
        let info: Dictionary? = notification.userInfo
        
        guard info != nil else {return}
        
        let typeKey:NSNumber = info![AVAudioSessionInterruptionTypeKey] as! NSNumber
        
        if  typeKey.intValue == Int32(AVAudioSessionInterruptionType.began.rawValue) {
            //开始中断
        } else {
            //结束中断
        }
    }
    
    @objc
    func changeRouteNotification(_ notification: Notification) {
        
        let info = notification.userInfo
        
        guard info != nil else {return}
        
        let typeKey:NSNumber = info![AVAudioSessionRouteChangeReasonKey] as! NSNumber
        
        if typeKey.intValue == AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue {
            
            let previousRoute:AVAudioSessionRouteDescription = info![AVAudioSessionRouteChangePreviousRouteKey] as! AVAudioSessionRouteDescription
            let preOutput = previousRoute.outputs.first
            let portType = preOutput?.portType
            
            if portType == AVAudioSessionPortHeadphones {
                //TODO:耳机接口断开
                self.stopAction(UIButton.init());
                
            }
        }
    }

}
