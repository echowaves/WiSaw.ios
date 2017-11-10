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


class DetailedViewController:
    UIViewController
     {
    
    var photoId: String!
    
    var uuid: String!
    let viewControllerUtils = ViewControllerUtils()

    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var reportAbuseButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cancelButton.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        reportAbuseButton.image = UIImage.fontAwesomeIcon(name: .ban, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        trashButton.image = UIImage.fontAwesomeIcon(name: .trash, textColor: UIColor.black, size: CGSize(width: 30, height: 30))

        viewControllerUtils.showActivityIndicator(uiView: self.view)
        Alamofire.request("https://www.wisaw.com/api/photos/\(photoId!)", method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                self.viewControllerUtils.hideActivityIndicator(uiView: self.view)

                print("loaded detailed photo ----------------- \(self.photoId!)")
                if let json = response.result.value as? [String: Any] {

                    let photoJson = json["photo"] as! [String: Any]
                    let imageDataJson = photoJson["imageData"] as! [String: Any]                    
                    let imageDataArray = imageDataJson["data"] as! [UInt8]
                    let imageData = Data(bytes: imageDataArray)
                    
                    self.imageView.image = UIImage(data:imageData as Data)
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
        let alert = UIAlertController(title: "The user who posted this photo wlll be baned.", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: "Report", style: .destructive) { (alert: UIAlertAction!) -> Void in
                
        
                let parameters: [String: Any] = [
                    "uuid" : self.uuid!
                ]
                self.viewControllerUtils.showActivityIndicator(uiView: self.view)
                Alamofire.request("https://www.wisaw.com/api/abusereport", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .responseJSON { response in
                        self.viewControllerUtils.hideActivityIndicator(uiView: self.view)

                        print(response)
                        
                        self.viewControllerUtils.showActivityIndicator(uiView: self.view)
                        Alamofire.request("https://www.wisaw.com/api/photos/\(self.photoId!)", method: .delete, encoding: JSONEncoding.default)
                            .responseJSON { response in
                                self.viewControllerUtils.hideActivityIndicator(uiView: self.view)

                                print("deleted detailed photo ----------------- \(self.photoId!)")
                                self.dismiss(animated: true) {
                                    
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
    
}

