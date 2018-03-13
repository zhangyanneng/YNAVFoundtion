//
//  MediaItem.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/8.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

typealias complateBlock = (_ prepared: Bool) -> Void

class MediaItem: NSObject {

    var filename: String?
    var filetype: String?
    var metadata: MetaData?
    var editable: Bool
    
    var prepared: Bool
    
    var url: URL
    var asset: AVAsset
    
    var comBlock: complateBlock?
    
    
    let acceptedFormats = [AVMetadataFormat.quickTimeMetadata,AVMetadataFormat.iTunesMetadata,AVMetadataFormat.id3Metadata]
    
    init(_ url: URL) {
        
        self.url = url
        self.asset = AVAsset(url: url)
        editable = false
        self.prepared = false
        super.init()
        
        //方法调用需要在super.init()之后
        self.filename = url.lastPathComponent
        self.filetype = self.fileTypeForURL(url)
    }
    
    
    func prepareWithCompletionHandler() {
        
        if self.prepared {
            self.comBlock!(self.prepared)
            return
        }
        
        self.metadata = MetaData();                              // 2
        
        let keys = ["commonMetadata", "availableMetadataFormats"];
        
        self.asset.loadValuesAsynchronously(forKeys: keys) {
            
            
            let commonStatus: AVKeyValueStatus  = self.asset.statusOfValue(forKey: "commonMetadata", error: nil)
            let formatsStatus: AVKeyValueStatus = self.asset.statusOfValue(forKey: "availableMetadataFormats", error: nil)
            
            self.prepared = commonStatus == AVKeyValueStatus.loaded && formatsStatus == .loaded
            
            if self.prepared {
                
                for item in self.asset.commonMetadata{       // 4
                    
                    self.metadata!.addMetadataItem(item, withKey: item.commonKey!.rawValue)
                }
                
                for format in self.asset.availableMetadataFormats {
        
                    if self.acceptedFormats.contains(format) {
                        let items:[AVMetadataItem] = self.asset.metadata(forFormat: format)
                        for item in items {
                            
                            self.metadata!.addMetadataItem(item, withKey: "\(item.key)")
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.comBlock!(self.prepared)
            }
            
        }
    }
    
    
    
    
    private func fileTypeForURL(_ url: URL) -> String {
        
        let ext: String = url.pathExtension
        var type = AVFileType.mp3
        if ext == "m4a" {
            type = AVFileType.m4a
        } else if ext == "m4v" {
            type = AVFileType.m4v
        } else if ext == "mov" {
            type = AVFileType.mov
        } else if ext == "mp4" {
            type = AVFileType.mp4
        } else {
            type = AVFileType.mp3
        }
        
        return type.rawValue
    }
    
    
    
}
