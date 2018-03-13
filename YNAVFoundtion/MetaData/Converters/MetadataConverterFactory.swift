//
//  MetadataConverterFactory.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/8.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit

let MetadataKeyName = "name"
let MetadataKeyArtist = "artist"
let MetadataKeyAlbumArtist = "albumArtist"
let MetadataKeyArtwork = "artwork"
let MetadataKeyAlbum = "album"
let MetadataKeyYear = "year"
let MetadataKeyBPM = "bpm"
let MetadataKeyGrouping = "grouping"
let MetadataKeyTrackNumber = "trackNumber"
let MetadataKeyTrackCount = "trackCount"
let MetadataKeyComposer = "composer"
let MetadataKeyDiscNumber = "discNumber"
let MetadataKeyDiscCount = "discCount"
let MetadataKeyComments = "comments"
let MetadataKeyGenre = "genre"


class MetadataConverterFactory: DefaultMetadataConverter {
    
    
    func converterForKey(_ key: String) -> AnyObject {
     
        var converter:ConverterProtocol = DefaultMetadataConverter()
        
        if key == MetadataKeyArtwork {
            converter = ArtworkMetadataConverter()
        }
        else if key == MetadataKeyTrackNumber {
            converter = TrackMetadataConverter()
        }
        else if key == MetadataKeyDiscNumber {
            converter = DiscMetadataConverter()
        }
        else if key == MetadataKeyComments {
            converter = CommentMetadataConverter()
        } else {
            converter = DefaultMetadataConverter()
        }
        return converter as! AnyObject
    }

}
