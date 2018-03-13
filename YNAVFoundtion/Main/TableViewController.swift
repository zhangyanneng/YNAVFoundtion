//
//  TableViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/6.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    let dataSources:NSArray = ["文本转语音","语音文件播放","录音","元数据","视频","AVKit","媒体捕捉"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSources.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell_identifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell_identifier")
        }
        
        let text = self.dataSources[indexPath.row]
        
        cell?.textLabel?.text = text as? String;

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        switch indexPath.row {
        case 0:
            let vc = sb.instantiateViewController(withIdentifier: "SpeechViewController") as! SpeechViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = sb.instantiateViewController(withIdentifier: "AudioViewController") as! AudioViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = sb.instantiateViewController(withIdentifier: "RecordViewController") as! RecordViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = sb.instantiateViewController(withIdentifier: "MetaDataViewController") as! MetaDataViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = sb.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 5:
            let vc = AVKitViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 6:
            let vc = CaptureViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            self.navigationController?.pushViewController(SpeechViewController(), animated: true)
        }
        
    }
    
    
    
}
