//
//  MetaData.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/8.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class MetaData: NSObject {
    
    @objc var name: String?  // swift 4 以后使用kvc 需要加个 @objc
    @objc var artist: String?
    @objc var albumArtist: String?
    @objc var album: String?
    var grouping: String?
    var composer: String?
    var comments: String?
    var artwork: String?
    var genre: Genre?
    var year: String?
    var bpm: Float  = 0.0
    var trackNumber:Float = 0.0
    var trackCount: Int = 0
    var discNumber:Float = 0.0
    var discCount:Int = 0
    
    var metadata: NSMutableDictionary?
    var converterFactory:MetadataConverterFactory = MetadataConverterFactory()
    
    
    let keyMapping: Dictionary<String, Any> = [
        // Name Mapping
        AVMetadataKey.commonKeyTitle.rawValue : MetadataKeyName,
        
        // Artist Mapping
        AVMetadataKey.commonKeyArtist.rawValue : MetadataKeyArtist,
        AVMetadataKey.quickTimeMetadataKeyProducer.rawValue : MetadataKeyArtist,
        
        // Album Artist Mapping
        AVMetadataKey.id3MetadataKeyBand.rawValue : MetadataKeyAlbumArtist,
        AVMetadataKey.iTunesMetadataKeyAlbumArtist.rawValue : MetadataKeyAlbumArtist,
        "TP2" : MetadataKeyAlbumArtist,
        
        // Album Mapping
        AVMetadataKey.commonKeyAlbumName.rawValue : MetadataKeyAlbum,
        
        // Artwork Mapping
        AVMetadataKey.commonKeyArtwork.rawValue : MetadataKeyArtwork,
        
        // Year Mapping
        AVMetadataKey.commonKeyCreationDate.rawValue : MetadataKeyYear,
        AVMetadataKey.id3MetadataKeyYear.rawValue : MetadataKeyYear,
        "TYE" : MetadataKeyYear,
        AVMetadataKey.quickTimeMetadataKeyYear.rawValue : MetadataKeyYear,
        AVMetadataKey.id3MetadataKeyRecordingTime.rawValue : MetadataKeyYear,
        
        // BPM Mapping
        AVMetadataKey.iTunesMetadataKeyBeatsPerMin.rawValue : MetadataKeyBPM,
        AVMetadataKey.id3MetadataKeyBeatsPerMinute.rawValue : MetadataKeyBPM,
        "TBP" : MetadataKeyBPM,
        
        // Grouping Mapping
        AVMetadataKey.iTunesMetadataKeyGrouping.rawValue : MetadataKeyGrouping,
        "@grp" : MetadataKeyGrouping,
        AVMetadataKey.commonKeySubject.rawValue : MetadataKeyGrouping,
        
        // Track Number Mapping
        AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue : MetadataKeyTrackNumber,
        AVMetadataKey.id3MetadataKeyTrackNumber.rawValue : MetadataKeyTrackNumber,
        "TRK" : MetadataKeyTrackNumber,
        
        // Composer Mapping
        AVMetadataKey.quickTimeMetadataKeyDirector.rawValue : MetadataKeyComposer,
        AVMetadataKey.iTunesMetadataKeyComposer.rawValue : MetadataKeyComposer,
        AVMetadataKey.commonKeyCreator.rawValue : MetadataKeyComposer,
        
        // Disc Number Mapping
        AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue : MetadataKeyDiscNumber,
        AVMetadataKey.id3MetadataKeyPartOfASet.rawValue : MetadataKeyDiscNumber,
        "TPA" : MetadataKeyDiscNumber,
        
        // Comments Mapping
        "ldes" : MetadataKeyComments,
        AVMetadataKey.commonKeyDescription.rawValue : MetadataKeyComments,
        AVMetadataKey.iTunesMetadataKeyUserComment.rawValue : MetadataKeyComments,
        AVMetadataKey.id3MetadataKeyComments.rawValue : MetadataKeyComments,
        "COM" : MetadataKeyComments,
        
        // Genre Mapping
        AVMetadataKey.quickTimeMetadataKeyGenre.rawValue : MetadataKeyGenre,
        AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue : MetadataKeyGenre,
        AVMetadataKey.commonKeyType.rawValue : MetadataKeyGenre
    ]
    
    
    public func addMetadataItem(_ item: AVMetadataItem,withKey key:String) {

        
        guard let normalizedKey = self.keyMapping[key] else {return}
        
        
        let converter: ConverterProtocol =  self.converterFactory.converterForKey(normalizedKey as! String) as! ConverterProtocol
        
        let value = converter.displayValueFromMetadataItem(item)
        
        if value is Dictionary<String, AnyObject> {                   // 3
            
            for currentKey in (value as! Dictionary<String, String>).keys {
                
                if value[currentKey] != nil {
                    
                    self.setValue(value[currentKey]!, forKey: currentKey)
                }
                
            }
            
        } else {
            self.setValue(value, forKey: normalizedKey as! String)
        }

    }

    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    
    
//    func metadataItems() -> NSArray {
//
//
//    }

}
