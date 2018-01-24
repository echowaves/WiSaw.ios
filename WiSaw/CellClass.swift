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

class CellClass: UICollectionViewCell {
    @IBOutlet weak var uiImage: UIImageView!
    var downloader: ImageDownloader? // This acts as the 'strong reference'.

    func configure(url: String) {
        downloader = ImageDownloader()
        let urlRequest = URLRequest(url: URL(string: url)!)
        downloader!.download(urlRequest) { response in
            if let image = response.result.value {
                self.uiImage.image = image
            }
        }

    }

}
