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


class DetailedViewController:
    UIViewController
     {
    
    var photoId: String!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Alamofire.request("https://www.echowaves.com/api/photos/\(photoId!)", method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
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
        
        
        let alert = UIAlertController(title: "This photo will be obliterated for everyone for ever", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { (alert: UIAlertAction!) -> Void in
                
                    
                Alamofire.request("https://www.echowaves.com/api/photos/\(self.photoId!)", method: .delete, encoding: JSONEncoding.default)
                    .responseJSON { response in
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

        
        
        

        
        
        
        
            //refresh
        
    }
    
}

