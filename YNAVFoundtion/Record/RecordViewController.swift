
//
//  RecordViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/6.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController,AVAudioRecorderDelegate {
    
    var audioPlayer: AVAudioPlayer?
    var recorder:AVAudioRecorder?
    var timer: Timer?
    var sourURL: URL!
    var saveURL: URL?
    
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupOAuthStatus()
        
        _initRecorder()
        
        //添加一个定时器
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateRecordTime), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.timer?.invalidate()
        self.timer = nil;
    }
    
    private func setupOAuthStatus () {
        //请求麦克风授权
        let audioAuthStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        if audioAuthStatus == AVAuthorizationStatus.notDetermined {
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                
                if granted {
                    print("麦克风授权成功")
                } else {
                    print("麦克风授权失败")
                }
            })
        } else if audioAuthStatus == .restricted || audioAuthStatus == .denied {
            
            print("未授权")
        } else {
            print("已经授权")
        }
    }
    
    
    private func _initRecorder() {
        
        //临时存放目录
        let path = "record.caf".tmpDir()
        let url = NSURL.fileURL(withPath: path)
        
        /**
         LPCM数据是最原始的音频数据完全无损，但是他的体积非常大，比如一个44.1kHz，16bit，双音道的音频文件，每分钟的数据量为44.1*16*2*60kbit=10.3M。一个普通5分钟的音乐就得50M
         
         AVFormatIDKey: 音频格式  有无损压缩（ALAC、APE、FLAC）和有损压缩（MP3、AAC、OGG、WMA）两种
         AVSampleRateKey： 采样率，一般是这几种，8000，16000，22050，44100
         AVNumberOfChannelsKey：音频通道，1是单声通道，2是立体通道，除非接入外部硬件，否则通常是单声通道
         AVEncoderBitDepthHintKey : 比特率 8 16 24 32
         AVEncoderAudioQualityKey ： 声音质量
         AVEncoderBitRateKey ： 音频编码的比特率 BPS传输速率 一般设置128000bps 也就是128kbps
         
         */
        
        //需要注意录音的格式和AVFormatIDKey格式需要进行对应，否则有时候会失败
        let settingDic:[String : Any] = [
                                AVFormatIDKey: kAudioFormatAppleIMA4,
                                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
                                AVEncoderBitRateKey: 128000,
                                AVNumberOfChannelsKey: 1,
                                AVEncoderBitDepthHintKey : 16,
                                AVSampleRateKey: 44100.0]
        do {
            self.recorder = try AVAudioRecorder.init(url: url, settings: settingDic)
            self.recorder?.isMeteringEnabled = true
            self.recorder?.delegate = self
            self.recorder?.prepareToRecord()
        } catch {
            self.recorder = nil
            print(error)
        }
    }
    
    

    @IBAction func startRecord(_ sender: UIButton) {
        
        guard let recorder = self.recorder else {return}
        recorder.record()
        if recorder.isRecording {
            print("开始录音")
        }
        
    }
    @IBAction func pauseRecord(_ sender: UIButton) {
        
        self.recorder?.pause()
        
        print("暂停录音")
    }
    @IBAction func stopRecord(_ sender: UIButton) {
        
        self.recorder?.stop()
        
        print("结束录音")
        
    }
    @IBAction func playRecord(_ sender: Any) {
        
        guard let url = self.saveURL else {return}
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.8 //音量 0.0 to 1.0.
            player.rate = 0.4
            player.numberOfLoops = 1  //循环次数，-1是无限循环
            player.enableRate = true
            audioPlayer = player
            player.prepareToPlay()
            player.play()
        } catch {
            print(error)
        }
        
    }
    
    //MARK: 录音结束
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    
        if flag {
            //录音成功，将文件复制到doc目录下
            let fileName = "\(Date().timeIntervalSince1970).caf"
            let savePath = fileName.docDir()
            let srcUrl = self.recorder?.url
            let destURL = NSURL.fileURL(withPath: savePath)
            
            guard let surl = srcUrl else {return}
    
            do {
                
                try FileManager.default.copyItem(at: surl, to: destURL)
                
                self.recorder?.prepareToRecord()
                self.saveURL = destURL
                
            } catch {
                
                print(error)
            }
        }
        
    }

    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        
        print("BeginInterruption")
    }
    
    //更新录音时间
    @objc
    private func updateRecordTime() {
        
        guard let time = self.recorder?.currentTime else {return}
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        self.dateLabel.text = formatter.string(from: Date.init(timeIntervalSince1970: time))
        
        //self.recorder?.updateMeters() //读取音频的分贝数据,
        //self.recorder?.peakPower(forChannel: 0) //峰值分贝值
        //self.recorder?.averagePower(forChannel: 0) //平均分贝值
        
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
