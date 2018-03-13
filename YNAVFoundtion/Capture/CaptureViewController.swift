
//
//  CaptureViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/12.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit

class CaptureViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSubViews()
        
    }
    
    
    func initSubViews() {
        
        self.view.backgroundColor = UIColor.white
        
        let buttonV = UIButton()
        buttonV.setTitle("视频", for: .normal)
        buttonV.setTitleColor(UIColor.blue, for: .normal)
        buttonV.addTarget(self, action: #selector(buttonVideoClick), for: UIControlEvents.touchUpInside)
        buttonV.sizeToFit()
        buttonV.center = self.view.center
        
        self.view.addSubview(buttonV)
        
        let buttonP = UIButton()
        buttonP.setTitle("照片", for: .normal)
        buttonP.setTitleColor(UIColor.blue, for: .normal)
        buttonP.addTarget(self, action: #selector(buttonPhotoClick), for: UIControlEvents.touchUpInside)
        buttonP.sizeToFit()
        
        buttonP.left = buttonV.left
        buttonP.top = buttonV.bottom + 10
        
        self.view.addSubview(buttonP)
    }
    
    
    
    @objc
    func buttonVideoClick() {
        
        let cameraVC =  CameraViewController()
        cameraVC.mediaType = .video
//        self.navigationController?.pushViewController(cameraVC, animated: true)
        self.present(cameraVC, animated: true, completion: nil)
        
    }
    
    @objc
    func buttonPhotoClick() {
        
        let cameraVC =  CameraViewController()
        cameraVC.mediaType = .photo
        self.present(cameraVC, animated: true, completion: nil)
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
