//
//  CommentMetadataConverter.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/8.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class CommentMetadataConverter: NSObject,ConverterProtocol {
    
    func displayValueFromMetadataItem(_ item: AVMetadataItem) -> AnyObject {
        var value: String = ""
        if item.value is String {
            value = item.stringValue!
        } else if item.value is Dictionary<String,Any> {
            let dict : Dictionary<String,Any> = item.value as! Dictionary<String, Any>
            let idf:String = dict["identifier"] as! String
            if idf.isEmpty {
                value = dict["text"] as! String
            }
        }
        return value as AnyObject;
    }
    
    func metadataItemFromDisplayValue(_ value: AnyObject, metadataItem item: AVMetadataItem) -> AVMetadataItem {
        let newItem:AVMutableMetadataItem = item.mutableCopy() as! AVMutableMetadataItem
        newItem.value = value as? NSCopying & NSObjectProtocol
        return newItem
    }
    

    
}
