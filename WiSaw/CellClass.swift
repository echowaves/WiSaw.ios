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
    @IBOutlet weak var badgeView: BadgeSwift!
    
    var downloader: ImageDownloader? // This acts as the 'strong reference'.

    func configure(photoJSON:[String: Any]) {
        let thumbUrl = photoJSON["getThumbUrl"] as! String
        let likes = photoJSON["likes"] as! NSNumber

        downloader = ImageDownloader()
        let urlRequest = URLRequest(url: URL(string: thumbUrl)!)
        downloader!.download(urlRequest) { response in
            if let image = response.result.value {
                self.uiImage.image = image
            }
        }
        
        badgeView!.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        badgeView!.textColor = UIColor.white

        badgeView!.text = likes.stringValue
        if(likes == 0) {
            badgeView!.isHidden = true
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
    }
    
}
