//
//  CellClassCollectionViewCell.swift
//  Echowaves
//
//  Created by D on 10/20/17.
//  Copyright © 2017 EchoWaves. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import BadgeSwift

class CellClass: UICollectionViewCell {
    @IBOutlet weak var uiImage: UIImageView!
    @IBOutlet weak var likesView: BadgeSwift!
    
    var downloader: ImageDownloader? // This acts as the 'strong reference'.

    func configure(photoJSON:[String: Any]) {
        let thumbUrl = photoJSON["getThumbUrl"] as! String
        let likes = photoJSON["likes"] as! Int
        let photoId = photoJSON["id"] as! Int

        downloader = ImageDownloader()
        let urlRequest = URLRequest(url: URL(string: thumbUrl)!)
        downloader!.download(urlRequest) { response in
            if let image = response.result.value {
                self.uiImage.image = image
            }
        }
        
        likesView!.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        likesView!.textColor = UIColor.white
        likesView!.isHidden = false
        
        if(!AppDelegate.isPhotoViewed(photoId: photoId)) {
            likesView!.badgeColor = UIColor.red
            if(likes == 0) {
                likesView!.text = ""
            } else {
                 likesView!.text = "\(likes)"
            }
        } else {
            likesView!.badgeColor = UIColor(red: 0.1412, green: 0.6078, blue: 0, alpha: 1.0) /* #249b00 */
            if(likes == 0) {
                likesView!.isHidden = true
            } else {
                likesView!.text = "\(likes)"
            }
        }
    }
    
    
    // MARK: - View Lifecycle
//    override func awakeFromNib() {
//        super.awakeFromNib()
////        styleSetup()
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        uiImage.af_cancelImageRequest() // NOTE: - Using AlamofireImage
        uiImage.image = nil
        likesView!.isHidden = true
    }
    
}
