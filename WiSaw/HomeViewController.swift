//
//  ViewController.swift
//  Echowaves
//
//  Created by D on 10/18/17.
//  Copyright © 2017 EchoWaves. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import AlamofireImage

class HomeViewController:
    UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
CLLocationManagerDelegate {
    var refreshControl: UIRefreshControl!

    let picker = UIImagePickerController()

    @IBOutlet weak var collectionView: UICollectionView!
    
    var locationManager:CLLocationManager!
    
    var lattitude: String!
    var longitude: String!
    
    var uuid: String!
    
    var photos: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        uuid = appDelegate.uuid
        

        picker.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view        
        loadImages()
        self.refreshControl?.endRefreshing()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        determineMyCurrentLocation()
        
    }
    
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers // we do not need the best possibble location accuracy, we need to preserve the battery as a priority
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        manager.stopUpdatingLocation()
        
        lattitude = userLocation.coordinate.latitude.description
        longitude = userLocation.coordinate.longitude.description
        
        print("------------------------------")
        print("user latitude = \(lattitude!)")
        print("user longitude = \(longitude!)")
        
        loadImages()
        
    }
    
    
    func loadImages() {
        // load images here, can only do it after the gps data is obtained
        let parameters: [String: Any] = [
            "location" : [
                "type": "Point",
                "coordinates": [ lattitude!, longitude!]
            ]
            
        ]
        Alamofire.request("https://www.echowaves.com/api/photos/feed", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                print("response------------------------------")
                if let json = response.result.value as? [String: Any] {
                    
                    self.photos = json["photos"] as! [Any]
                    print("photos length: \(self.photos.count)")
                    
                    
                    self.collectionView.reloadData()
                    
                }
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CellClass = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CellClass
        
        let photoJSON = self.photos[indexPath.row] as! [String: Any]
        let thumbNailJson = photoJSON["thumbNail"] as! [String: Any]
        
        let thumbData = thumbNailJson["data"] as! [UInt8]
        let imageData = Data(bytes: thumbData)
        
        
        cell.uiImage.image = UIImage(data:imageData as Data)
        
        return cell
    }
    
    
   
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item clicked: \(indexPath.row)")

        let photoJSON = self.photos[indexPath.row] as! [String: Any]
        let photoId = photoJSON["id"]
        
        print("photoId selected: \(photoId!)")
        
        

        
        
        let detailedViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController
        detailedViewController.photoId = (photoId as! Int).description
        
        present(detailedViewController, animated: true) {
            print("showing detailed image")
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    @IBAction func openCameraButtonClicked(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                picker.delegate = self
                picker.sourceType = .camera;
                picker.allowsEditing = false
                self.present(picker, animated: true, completion: nil)
            } else {
                noCamera()
            }
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        //this is where we have to store locally and upload the photo
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2        
        chosenImage = self.imageOrientation(chosenImage)
        
        
        // save to photo albom
        UIImageWriteToSavedPhotosAlbum(chosenImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        // send over to the API
        let size = CGSize(width: 500.0, height: 500.0)
        let aspectScaledToFitImage = chosenImage.af_imageAspectScaled(toFit: size)
        
        let imageData:Data! = UIImageJPEGRepresentation(aspectScaledToFitImage, 0.7)
        let imageBytes:[UInt8] = Array(imageData)
        
        let parameters: [String: Any] = [
            "uuid" : uuid,
            "location" : [
                "type": "Point",
                "coordinates": [ lattitude!, longitude!]
            ],
            "imageData": imageBytes
        ]
        
        Alamofire.request("https://www.echowaves.com/api/photos", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                self.loadImages()
        }
        
        
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        loadImages()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        dismiss(animated: true, completion: nil)
        
//        if let error = error {
//            // we got back an error!
//            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        } else {
//            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        }
        
        loadImages()
    }
    
    
    
    func imageOrientation(_ src:UIImage)->UIImage {
        if src.imageOrientation == UIImageOrientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch src.imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }
        
        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)
        
        return img
    }
    
    
}
