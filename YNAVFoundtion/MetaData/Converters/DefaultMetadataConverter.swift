//
//  DefaultMetadataConverter.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/8.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class DefaultMetadataConverter: NSObject,ConverterProtocol {
    
    //简单方式处理元数据
    
    func displayValueFromMetadataItem(_ item: AVMetadataItem) -> AnyObject {
        return item.value!
    }
    
    func metadataItemFromDisplayValue(_ value: AnyObject, metadataItem item: AVMetadataItem) -> AVMetadataItem {
        
        let newItem:AVMutableMetadataItem = item.mutableCopy() as! AVMutableMetadataItem
        newItem.value = value as? NSCopying & NSObjectProtocol
        return newItem
    }
}
