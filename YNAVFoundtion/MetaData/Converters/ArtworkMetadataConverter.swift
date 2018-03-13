//
//  ArtworkMetadataConverter.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/8.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class ArtworkMetadataConverter: NSObject,ConverterProtocol {
    
    
    func displayValueFromMetadataItem(_ item: AVMetadataItem) -> AnyObject {
        
        var image: UIImage = UIImage()
        
        guard let value = item.value else {return "" as AnyObject}
        
        if value is Data {
            image = UIImage.init(data: item.value as! Data)!
        } else if value is Dictionary<String, Any> {
            let dict: Dictionary<String, Any> = value as! Dictionary<String, Any>
            image = UIImage.init(data: dict["data"] as! Data)!
        }
        
        return image
    }
    
    func metadataItemFromDisplayValue(_ value: AnyObject, metadataItem item: AVMetadataItem) -> AVMetadataItem {
        
        let newItem:AVMutableMetadataItem = item.mutableCopy() as! AVMutableMetadataItem
        
        let  image:UIImage = value as! UIImage
        newItem.value = image as? NSCopying & NSObjectProtocol

        return newItem
    }
    
}
