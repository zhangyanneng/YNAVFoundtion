//
//  MetaDataDetailViewController.swift
//  YNAVFoundtion
//
//  Created by 张艳能 on 2018/3/7.
//  Copyright © 2018年 张艳能. All rights reserved.
//

import UIKit
import AVFoundation

class MetaDataDetailViewController: UIViewController {
    
    var url: URL?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ArtistTextField: UITextField!
    @IBOutlet weak var AlbumArtistTextField: UITextField!
    @IBOutlet weak var AlbumTextField: UITextField!
    @IBOutlet weak var GroupingTextField: UITextField!
    @IBOutlet weak var ComposerTextField: UITextField!
    @IBOutlet weak var CommentsTextField: UITextField!
    @IBOutlet weak var GenreTextField: UITextField!
    @IBOutlet weak var YearTextField: UITextField!
    @IBOutlet weak var BPMTextField: UITextField!
    @IBOutlet weak var TrackBeginTextField: UITextField!
    @IBOutlet weak var TrackEndTextField: UITextField!
    @IBOutlet weak var DiscBeginTextField: UITextField!
    @IBOutlet weak var DiscEndTextField: UITextField!
    
    @IBOutlet weak var ArtworkImageView: UIImageView!
    
    var mediaItem:MediaItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        print("url:\(self.url)")
        
        self.mediaItem = MediaItem.init(self.url!)
        self.mediaItem?.prepareWithCompletionHandler()
        self.mediaItem?.comBlock = { pre in
            
            self.nameTextField.text =  self.mediaItem?.metadata?.name
            self.ArtistTextField.text = self.mediaItem?.metadata?.artist
            self.AlbumArtistTextField.text = self.mediaItem?.metadata?.albumArtist
            self.AlbumTextField.text = self.mediaItem?.metadata?.album
            
        }
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
