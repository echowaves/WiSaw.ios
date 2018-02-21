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

    func configure(url: String) {
        downloader = ImageDownloader()
        let urlRequest = URLRequest(url: URL(string: url)!)
        downloader!.download(urlRequest) { response in
            if let image = response.result.value {
                self.uiImage.image = image
            }
        }
        
        badgeView!.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        badgeView!.textColor = UIColor.white

        badgeView!.text = " "
        
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
