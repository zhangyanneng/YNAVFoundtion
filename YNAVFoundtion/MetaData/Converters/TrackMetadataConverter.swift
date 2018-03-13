//
//  TrackMetadataConverter.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/8.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class TrackMetadataConverter: NSObject,ConverterProtocol {
    
    func displayValueFromMetadataItem(_ item: AVMetadataItem) -> AnyObject {
        var number: Int = 0
        var count: Int = 0
        
        if item.value is String {
            let components:Array = (item.stringValue?.components(separatedBy: "/"))!
            number = Int(components[0])!
            count = Int(components[1])!
        } else if item.value is Data {
            let data: Data = item.dataValue!
            if data.count == 8 {
                if data[1] > 0 {
                    number = Int(CFSwapInt16BigToHost(UInt16(data[1])))
                }
                
                if data[2] > 0 {
                    count = Int(CFSwapInt16BigToHost(UInt16(data[2])))
                }
            }
        }
        
        let dict = ["trackNumber":number,"trackCount":count]
        return dict as AnyObject

    }
    
    func metadataItemFromDisplayValue(_ value: AnyObject, metadataItem item: AVMetadataItem) -> AVMetadataItem {
        
        let newItem:AVMutableMetadataItem = item.mutableCopy() as! AVMutableMetadataItem
        var trackData:Dictionary<String,Any> = value as! Dictionary<String,Any>
        let trackNumber: Int = trackData["trackNumber"] as! Int
        let trackCount: Int = trackData["trackCount"] as! Int
        let values = [CFSwapInt16BigToHost(UInt16(trackNumber)),CFSwapInt16BigToHost(UInt16(trackCount))]
        newItem.value = Data.init(bytes: values, count: values.count) as NSCopying & NSObjectProtocol
        
        return newItem
    }
    

    
    
}
