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

class ContactFormViewController:
    UIViewController
{
    
    
    @IBOutlet weak var descriptionField: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
        Alamofire.request("https://www.wisaw.com/api/contactform", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
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



