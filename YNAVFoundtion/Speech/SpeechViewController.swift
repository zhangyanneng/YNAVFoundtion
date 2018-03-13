//
//  SpeechViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/6.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class SpeechViewController: UIViewController {

    let speech = AVSpeechSynthesizer()
    
    @IBOutlet weak var textView: UITextView!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //停止
        speech.stopSpeaking(at: .immediate)
    }

    @IBAction func speechAction(_ sender: Any) {
        
        
        let string = self.textView.text
        
        guard string != nil else {return}
        
        let utterance = AVSpeechUtterance(string: string!)
        //        utterance.voice =   //moren
        utterance.rate = 0.4; //语音速度
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.1
        
        speech.speak(utterance)
        
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
