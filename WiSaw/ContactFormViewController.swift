//
//  ContactFormController.swift
//  WiSaw
//
//  Created by D on 10/27/17.
//  Copyright © 2017 EchoWaves. All rights reserved.
//

import Foundation



//
//  DetailedViewController.swift
//  Echowaves
//
//  Created by D on 10/23/17.
//  Copyright © 2017 EchoWaves. All rights reserved.
//

import UIKit
import Alamofire
import FontAwesome_swift

class ContactFormViewController:
    UIViewController
{
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var descriptionField: UITextView!
    
    let viewControllerUtils = ViewControllerUtils()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cancelButton.image = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        cancelButton.title = "" // for compatibility with older devices

        doneButton.image = UIImage.fontAwesomeIcon(name: .send, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        doneButton.title = "" // for compatibility with older devices

    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.descriptionField.becomeFirstResponder()
        
        
    }
    
    
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        
        self.dismiss(animated: true) {
        }

    }
    
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let uuid = appDelegate.uuid

        
        let parameters: [String: Any] = [
            "uuid" : uuid!,
            "description" : descriptionField.text!
        ]
        
        viewControllerUtils.showActivityIndicator(uiView: self.view)
        Alamofire.request("\(appDelegate.host)/contactform", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                self.viewControllerUtils.hideActivityIndicator(uiView: self.view)

//                print(response)
//
//                let alert = UIAlertController(title: "Thank you for submitting a feedback.", message: "We will review every requiest in the order it was received.", preferredStyle: .alert)
//
//                alert.addAction(
//                    UIAlertAction(title: "OK", style: .destructive) { (alert: UIAlertAction!) -> Void in
//                })
//                self.present(alert, animated: true) {
//                }
        
        }
        
        self.dismiss(animated: true) {
            
        }
    }
    
    
}



