//
//  ConverterProtocol.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/8.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import Foundation
import AVFoundation

protocol ConverterProtocol {
    
    //转换协议
    
    func displayValueFromMetadataItem(_ item: AVMetadataItem) -> AnyObject
    
    func metadataItemFromDisplayValue(_ value: AnyObject,metadataItem item:AVMetadataItem) -> AVMetadataItem
    
}
