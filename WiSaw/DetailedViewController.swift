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
import BadgeSwift

class DetailedViewController:
    UIViewController,
    UIScrollViewDelegate
     {
    
//    var photos: [Any] = []
//    var pageIndex = 0
    
    var photoId: Int!
    var uuid: String!
    var photoJSON: [String: Any]!
    var imgUrl: String!
    var thumbUrl: String!
    var likes: Int!
    
    var downloader: ImageDownloader? // This acts as the 'strong reference'.

    let viewControllerUtils = ViewControllerUtils()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var reportAbuseButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var badgeCounter: BadgeSwift!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        photoId = photoJSON["id"] as! Int
        uuid = photoJSON["uuid"] as! String
        thumbUrl = photoJSON["getThumbUrl"] as! String
        imgUrl = photoJSON["getImgUrl"] as! String
        likes = photoJSON["likes"] as! Int
        
        AppDelegate.photoViewed(photoId: photoId)

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        cancelButton.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        cancelButton.title = "" // for compatibility with older devices
        reportAbuseButton.image = UIImage.fontAwesomeIcon(name: .ban, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        reportAbuseButton.title = "" // for compatibility with older devices

        trashButton.image = UIImage.fontAwesomeIcon(name: .trash, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        trashButton.title = "" // for compatibility with older devices
        shareButton.setImage( UIImage.fontAwesomeIcon(name: .share, textColor: UIColor.black, size: CGSize(width: 60, height: 60)), for: UIControlState.normal)
        likeButton.setImage( UIImage.fontAwesomeIcon(name: .thumbsUp, textColor: UIColor.black, size: CGSize(width: 60, height: 60)), for: UIControlState.normal)
        
        likeButton.isEnabled = !AppDelegate.isPhotoLiked(photoId: photoId)
        

        badgeCounter!.text = "\(likes!)"
        badgeCounter!.textColor = UIColor.white
            
        viewControllerUtils.showActivityIndicator(uiView: self.view)
        

        downloader = ImageDownloader()
        let urlRequest = URLRequest(url: URL(string: thumbUrl)!)
        downloader!.download(urlRequest) { response in
            if let image = response.result.value {
                self.imageView.image = image
                let urlRequest = URLRequest(url: URL(string: self.imgUrl)!)
                self.downloader!.download(urlRequest) { response in
                    if let image = response.result.value {
                        self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                        self.imageView.image = image
                    }
                }

            }
        }

//            Alamofire.request("\(appDelegate.host)/photos/\(photoId!)", method: .get, encoding: JSONEncoding.default)
//                .responseJSON { response in
//                    self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
//                    if let statusCode = response.response?.statusCode {
//                        if(statusCode == 200) {
//    //                    print("loaded detailed photo ----------------- \(self.photoId!)")
//                            if let json = response.result.value as? [String: Any] {
//
//                                let photoJson = json["photo"] as! [String: Any]
//                                let imageDataJson = photoJson["imageData"] as! [String: Any]
//                                let imageDataArray = imageDataJson["data"] as! [UInt8]
//                                let imageData = Data(bytes: imageDataArray)
//
//                                self.imageView.image = UIImage(data:imageData as Data)
//                                self.appDelegate.saveImageToCache(id: self.photoId, image: self.imageView.image!)
//                            }
//                        }
//                    }
//            }
//        }
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
                Alamofire.request("\(AppDelegate.HOST)/photos/\(self.photoId!)", method: .delete, encoding: JSONEncoding.default)
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
                    "uuid" : self.uuid!,
                    "photoId" : self.photoId!
                ]
                self.viewControllerUtils.showActivityIndicator(uiView: self.view)
                Alamofire.request("\(AppDelegate.HOST)/abusereport", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .responseJSON { response in
                        self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                        if let statusCode = response.response?.statusCode {
                            if(statusCode == 201) {
//                                self.viewControllerUtils.showActivityIndicator(uiView: self.view)
//                                Alamofire.request("\(AppDelegate.HOST)/photos/\(self.photoId!)", method: .delete, encoding: JSONEncoding.default)
//                                    .responseJSON { response in
                                        self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                                        print("deleted detailed photo ----------------- \(self.photoId!)")
                                        self.dismiss(animated: true) {
//                                        }
                                        
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
        DetailedViewController.share(photoJSON: photoJSON, instance: self)
    }

    
    class func share(photoJSON: [String: Any], instance: UIViewController) {
        let photoId = photoJSON["id"] as! Int
//        let uuid = photoJSON["uuid"] as! String
        let thumbUrl = photoJSON["getThumbUrl"] as! String
//        let imgUrl = photoJSON["getImgUrl"] as! String
        
        let buo = BranchUniversalObject(canonicalIdentifier: "photo/\(photoId)")
        buo.canonicalUrl = thumbUrl
        buo.title = "What I saw today:"
        buo.contentDescription = "Photo \(photoId) shared"
        buo.imageUrl = thumbUrl
        //        buo.price = 12.12
        //        buo.currency = "USD"
        
        buo.publiclyIndex = true
        buo.locallyIndex = true
        
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = "direct"
        lp.feature = "sharing"
        lp.campaign = "photo sharing"
        //        lp.stage = "new user"
        //        lp.tags = ["one", "two", "three"]
        
        //                lp.addControlParam("$desktop_url", withValue: "https://www.wisaw.com/api/photos/\(photoId)/thumb")
        //                lp.addControlParam("$ios_url", withValue: "https://www.wisaw.com/api/photos/\(photoId)/thumb")
        //                lp.addControlParam("$ipad_url", withValue: "https://www.wisaw.com/api/photos/\(photoId)/thumb")
        //                lp.addControlParam("$android_url", withValue: "https://www.wisaw.com/api/photos/\(photoId)/thumb")
        //                lp.addControlParam("$match_duration", withValue: "2000")
        
        //
        //        lp.addControlParam("custom_data", withValue: "yes")
        //        lp.addControlParam("look_at", withValue: "this")
        lp.addControlParam("$photo_id", withValue: "\(photoId)")
        //        lp.addControlParam("random", withValue: UUID.init().uuidString)
        
        let message = "Check out what I saw today:"
        buo.showShareSheet(with: lp, andShareText: message, from: instance) { (activityType, completed) in
            print("shared")
//            Alamofire.request("\(AppDelegate.HOST)/photos/\(photoId)/like", method: .put, encoding: JSONEncoding.default)
//                .responseJSON { response in
//                    if let statusCode = response.response?.statusCode {
//                        if(statusCode == 200) {
//                            instance.viewDidLoad()
//                        }
//                    }
//            }

        }

    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        DetailedViewController.like(photoJSON: photoJSON, instance: self)
    }
    
    class func like(photoJSON: [String: Any], instance: UIViewController) {
        if let detailedViewContoller = instance as? DetailedViewController {
            detailedViewContoller.likeButton!.isEnabled = false
        }
        if let sharingViewController = instance as? SharingViewController {
            sharingViewController.likeButton!.isEnabled = false
        }

        let photoId = photoJSON["id"] as! Int
        Alamofire.request("\(AppDelegate.HOST)/photos/\(photoId)/like", method: .put, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let statusCode = response.response?.statusCode {
                    if(statusCode == 200) {
                        AppDelegate.photoLiked(photoId: photoId)
//                        badgeCounter!.text = "110" //"\(Int(badgeCounter!.text!)! + 1)"
                        if let detailedViewContoller = instance as? DetailedViewController {
                            detailedViewContoller.badgeCounter!.text = "\(Int(detailedViewContoller.badgeCounter!.text!)! + 1)"
                        } else {
                            instance.viewDidLoad()
                        }
                    }                    
                }
        }
        
    }

}



//http://artoftheapp.com/ios/zoom-uiscrollview-swift/
//https://www.raywenderlich.com/159481/uiscrollview-tutorial-getting-started

