//
//  DetailedViewController.swift
//  Echowaves
//
//  Created by D on 10/23/17.
//  Copyright © 2017 EchoWaves. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import FontAwesome_swift
import Branch


class DetailedViewController:
    UIViewController,
    UIScrollViewDelegate
     {
    
//    var photos: [Any] = []
//    var pageIndex = 0
    
    var photoId: Int!
    var uuid: String!
    var photoJSON: [String: Any]!
    
    let viewControllerUtils = ViewControllerUtils()

    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var reportAbuseButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        cancelButton.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        reportAbuseButton.image = UIImage.fontAwesomeIcon(name: .ban, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        trashButton.image = UIImage.fontAwesomeIcon(name: .trash, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        shareButton.setImage( UIImage.fontAwesomeIcon(name: .share, textColor: UIColor.black, size: CGSize(width: 60, height: 60)), for: UIControlState.normal)

        viewControllerUtils.showActivityIndicator(uiView: self.view)
        
        
//        let photoJSON = self.photos[pageIndex] as! [String: Any]
        photoId = photoJSON["id"] as! Int
        uuid = photoJSON["uuid"] as! String

        
        
        
        let thumbNailJson = photoJSON["thumbNail"] as! [String: Any]
        let imageDataArray = thumbNailJson["data"] as! [UInt8]
        let imageData = Data(bytes: imageDataArray)
        self.imageView.image = UIImage(data:imageData as Data)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        if let image = appDelegate.imagesCache[photoId] { // get image from cache
            viewControllerUtils.hideActivityIndicator(uiView: self.view)
            self.imageView.image = image
        } else {
        
            Alamofire.request("https://www.wisaw.com/api/photos/\(photoId!)", method: .get, encoding: JSONEncoding.default)
                .responseJSON { response in
                    self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                    if let statusCode = response.response?.statusCode {
                        if(statusCode == 200) {
    //                    print("loaded detailed photo ----------------- \(self.photoId!)")
                            if let json = response.result.value as? [String: Any] {

                                let photoJson = json["photo"] as! [String: Any]
                                let imageDataJson = photoJson["imageData"] as! [String: Any]
                                let imageDataArray = imageDataJson["data"] as! [UInt8]
                                let imageData = Data(bytes: imageDataArray)
                                
                                self.imageView.image = UIImage(data:imageData as Data)
                                appDelegate.imagesCache[self.photoId] = self.imageView.image
                            }
                        }
                    }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true) {
            //refresh
        }
        
    }
    
    
    
 
    
    @IBAction func trashButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "This photo will be obliterated from the cloud.", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { (alert: UIAlertAction!) -> Void in
                
                self.viewControllerUtils.showActivityIndicator(uiView: self.view)
                Alamofire.request("https://www.wisaw.com/api/photos/\(self.photoId!)", method: .delete, encoding: JSONEncoding.default)
                    .responseJSON { response in
                        self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                        print("deleted detailed photo ----------------- \(self.photoId!)")
                        self.dismiss(animated: true) {
                        }
                }
        })
                
        alert.addAction(UIAlertAction(title: "No", style: .default) { (alert: UIAlertAction!) -> Void in
            //print("You pressed Cancel")
            
            self.dismiss(animated: true) {
            }
        })
            
        present(alert, animated: true, completion:nil)
    }
    

    @IBAction func reportAbuseButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "The user who posted this photo will be banned.", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: "Report", style: .destructive) { (alert: UIAlertAction!) -> Void in
                
        
                let parameters: [String: Any] = [
                    "uuid" : self.uuid!
                ]
                self.viewControllerUtils.showActivityIndicator(uiView: self.view)
                Alamofire.request("https://www.wisaw.com/api/abusereport", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .responseJSON { response in
                        self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                        if let statusCode = response.response?.statusCode {
                            if(statusCode == 201) {
                                self.viewControllerUtils.showActivityIndicator(uiView: self.view)
                                Alamofire.request("https://www.wisaw.com/api/photos/\(self.photoId!)", method: .delete, encoding: JSONEncoding.default)
                                    .responseJSON { response in
                                        self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                                        print("deleted detailed photo ----------------- \(self.photoId!)")
                                        self.dismiss(animated: true) {
                                        }
                                        
                                }
                            }
                            
                        }
                        
                }
            
                
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .default) { (alert: UIAlertAction!) -> Void in
            //print("You pressed Cancel")
            
            self.dismiss(animated: true) {
            }
        })
        
        present(alert, animated: true, completion:nil)
    }
    
    
//    UIScrollViewDelegate methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        DetailedViewController.share(photoId: photoId!, instance: self)
    }

    class func share(photoId: Int, instance: UIViewController) {
        let buo = BranchUniversalObject(canonicalIdentifier: "photo/\(photoId)")
        //        buo.canonicalUrl = "https://example.com/content/123"
        buo.title = "Photo \(photoId) shared"
        //        buo.contentDescription = "Content 123 Description \(Date())"
        //        buo.imageUrl = "http://lorempixel.com/400/400/"
        //        buo.price = 12.12
        //        buo.currency = "USD"
        
        buo.contentIndexMode = .private
        buo.automaticallyListOnSpotlight = false
        //        buo.addMetadataKey("photoId", value: "\(photoId!)")
        
        
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = "direct"
        lp.feature = "sharing"
        lp.campaign = "photo sharing"
        //        lp.stage = "new user"
        //        lp.tags = ["one", "two", "three"]
        
        //        lp.addControlParam("$desktop_url", withValue: "http://example.com/desktop")
        //        lp.addControlParam("$ios_url", withValue: "http://example.com/ios")
        //        lp.addControlParam("$ipad_url", withValue: "http://example.com/ios")
        //        lp.addControlParam("$android_url", withValue: "http://example.com/android")
        //        lp.addControlParam("$match_duration", withValue: "2000")
        //
        //        lp.addControlParam("custom_data", withValue: "yes")
        //        lp.addControlParam("look_at", withValue: "this")
        lp.addControlParam("$photo_id", withValue: "\(photoId)")
        //        lp.addControlParam("random", withValue: UUID.init().uuidString)
        
        let message = "Check out what I saw today:"
        buo.showShareSheet(with: lp, andShareText: message, from: instance) { (activityType, completed) in
            print("shared")
        }
        
    }
    
}



//http://artoftheapp.com/ios/zoom-uiscrollview-swift/
//https://www.raywenderlich.com/159481/uiscrollview-tutorial-getting-started

