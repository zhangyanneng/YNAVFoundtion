//
//  AVKitViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/12.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class AVKitViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        let button = UIButton()
        button.setTitle("使用AVKit播放视频", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(playAVKitVideo), for: UIControlEvents.touchUpInside)
        button.sizeToFit()
        button.center = self.view.center
        
        self.view.addSubview(button)
        
    }
    
    @objc
    func playAVKitVideo() {
        
        //AVPlayerViewController是 iOS 8以后苹果提供的封装好的视频播放器，基于AVFoundation框架
        let url = Bundle.main.url(forResource: "hubblecast", withExtension: "m4v")
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: url!)
        playerVC.showsPlaybackControls = true //显示控件
        playerVC.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
        if #available(iOS 11.0, *) {
            playerVC.entersFullScreenWhenPlaybackBegins = true //全屏播放
        } else {
            // Fallback on earlier versions
        }
        
        
        self.navigationController?.pushViewController(playerVC, animated: true)
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
