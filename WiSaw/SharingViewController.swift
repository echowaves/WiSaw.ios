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


class SharingViewController:
    UIViewController,
    UIScrollViewDelegate
{
    
    
    var photoId: Int!
    var uuid: String!
    var photoJSON: [String: Any]!
    
    let viewControllerUtils = ViewControllerUtils()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var downloader: ImageDownloader? // This acts as the 'strong reference'.

    
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
    
        reportAbuseButton.isEnabled = false
        trashButton.isEnabled = false
        shareButton.isHidden = true
        
        viewControllerUtils.showActivityIndicator(uiView: self.view)

        
        
        Alamofire.request("\(appDelegate.HOST)/photos/\(photoId!)", method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                if let statusCode = response.response?.statusCode {
                    if(statusCode == 200) {
                        //                    print("loaded detailed photo ----------------- \(self.photoId!)")
                        if let json = response.result.value as? [String: Any] {
                            
                            self.photoJSON = json["photo"] as! [String: Any]
                            self.uuid = self.photoJSON["uuid"] as! String
                            let imgUrl = self.photoJSON["getImgUrl"] as! String
                            let photoId = self.photoJSON["id"] as! Int

                            if(AppDelegate.isPhotoLiked(photoId: "\(photoId)")) {
                                self.likeButton.isEnabled = false
                            }

                            self.badgeCounter!.text = (self.photoJSON["likes"] as! NSNumber).stringValue
                            self.badgeCounter!.textColor = UIColor.white

                            self.downloader = ImageDownloader()
                            let urlRequest = URLRequest(url: URL(string: imgUrl)!)
                            self.downloader!.download(urlRequest) { response in
                                if let image = response.result.value {
                                    self.imageView.image = image
                                    
                                    self.reportAbuseButton.isEnabled = true
                                    self.trashButton.isEnabled = true
                                    self.shareButton.isHidden = false
                                    
                                }
                            }

                        }
                    } else {
                        let alert = UIAlertController(title: "Looks like this short lived photo has expired.", message: nil, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { (alert: UIAlertAction!) -> Void in
                            //print("You pressed Cancel")
                            self.dismiss(animated: true) {
                            }
                        })
                        
                        self.present(alert, animated: true, completion:nil)                        }
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
                Alamofire.request("\(self.appDelegate.HOST)/photos/\(self.photoId!)", method: .delete, encoding: JSONEncoding.default)
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
                Alamofire.request("\(self.appDelegate.HOST)/abusereport", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .responseJSON { response in
                        self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                        if let statusCode = response.response?.statusCode {
                            if(statusCode == 201) {
                                self.viewControllerUtils.showActivityIndicator(uiView: self.view)
                                Alamofire.request("\(self.appDelegate.HOST)/photos/\(self.photoId!)", method: .delete, encoding: JSONEncoding.default)
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
        DetailedViewController.share(photoJSON: photoJSON, instance: self)
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
    }

}

//http://artoftheapp.com/ios/zoom-uiscrollview-swift/
//https://www.raywenderlich.com/159481/uiscrollview-tutorial-getting-started

