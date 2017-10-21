//
//  ViewController.swift
//  Echowaves
//
//  Created by D on 10/18/17.
//  Copyright © 2017 EchoWaves. All rights reserved.
//

import UIKit

class HomeViewController:
    UIViewController,
//    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
         picker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
    @IBOutlet weak var collectionview: UICollectionView!

    
    
    
    
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//
    
    let picker = UIImagePickerController()
    
    @IBAction func openCameraButtonClicked(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            picker.delegate = self
            picker.sourceType = .camera;
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    //MARK: - Delegates
    private func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        //this is where we have to store locally and upload the photo
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

