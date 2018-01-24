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
import SwiftKeychainWrapper
import FontAwesome_swift

class HomeViewController:
    UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
CLLocationManagerDelegate {
    @IBOutlet weak var contactUsButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var uploadCounterButton: UIButton!
    
    private var urlSessionConfiguration: URLSessionConfiguration!
    private var uploadSessionManager:SessionManager!
    
    var refreshControl: UIRefreshControl!
    
    let picker = UIImagePickerController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var locationManager:CLLocationManager!
    
    var lattitude: String!
    var longitude: String!
    
    var uuid: String!
    
    var appDelegate:AppDelegate!
    
    var photos: [Any] = []
    
    
    let viewControllerUtils = ViewControllerUtils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        urlSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "upload-session")
        urlSessionConfiguration!.httpMaximumConnectionsPerHost = 1
        uploadSessionManager = Alamofire.SessionManager(configuration: urlSessionConfiguration!)
        
        contactUsButton.image = UIImage.fontAwesomeIcon(name: .lifeSaver, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        contactUsButton.title = "" // for compatibility with older devices
        cameraButton.setImage( UIImage.fontAwesomeIcon(name: .camera, textColor: UIColor.black, size: CGSize(width: 60, height: 60)), for: UIControlState.normal)
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        uuid = appDelegate.uuid
        
        picker.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.addSubview(refreshControl) // not required when using UITableViewController
        
        cleanup()
    }
    
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view        
        loadImages()
        self.refreshControl?.endRefreshing()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentTandCAlert()
    }
    
    
    func presentTandCAlert() {
        
        let tandc =  KeychainWrapper.standard.bool(forKey: "WiSaw-tandc")
        
        
        if(tandc == nil) {
            let alert = UIAlertController(title: "* When you take a photo with WiSaw, it gets added to your Photo Album and will be posted to GEO feed.\n* People close by can see your photo for 24 hours.\n* If you find any photo abusive or inappropriate, you can delete it from the feed, which will remove it from the cloud.\n* We will not tolerate objectionable content or abusive users.\n* The abusive users will be banned from WiSaw.", message: "By using WiSaw I agree to Terms and Conditions.", preferredStyle: .alert)
            
            alert.addAction(
                UIAlertAction(title: "Agree", style: .destructive) { (alert: UIAlertAction!) -> Void in
                    KeychainWrapper.standard.set(true, forKey: "WiSaw-tandc")
                    self.appDelegate.tandc = true
            })
            present(alert, animated: true, completion:nil)
        } else {
            appDelegate.tandc = tandc!
        }
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
        viewControllerUtils.showActivityIndicator(uiView: self.view)
        Alamofire.request("\(appDelegate.host)/photos/feed", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let statusCode = response.response?.statusCode {
                    if(statusCode == 200) {
                        if let json = response.result.value as? [String: Any] {
                            self.photos = json["photos"] as! [Any]
                            print("photos length: \(self.photos.count)")
                            self.collectionView.reloadData()
                        }
                    }
                }
                self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                self.uploadImage()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with an Error: \(error)")
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
        
        let thumbUrl = photoJSON["getThumbUrl"] as! String
        
        cell.configure(url: thumbUrl)
        
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item clicked: \(indexPath.row)")
    
        let pageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
        
        pageViewController.photos = self.photos
        pageViewController.pageIndex = indexPath.row
        
        present(pageViewController, animated: true) {
            print("showing PageViewController")
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
    
    
    func noCamera() {
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
        
        // save to photo album
        UIImageWriteToSavedPhotosAlbum(chosenImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        uploadImage()
    }
    
    
    private func uploadImage() {
        updateCounter()
        
        uploadSessionManager!.session.getAllTasks { tasks in
            if(tasks.count == 0) { // check if upload is in progress
                // hothing is being uploaded right now, let's upload
                let imageFiles = self.getImagesToUpload()
                if(imageFiles.count==0) {//no files to upload found
                    return
                }
                
                
                let imageFilePath =  imageFiles[0].path
                let image = UIImage(contentsOfFile:  imageFilePath)

                // send over to the API
                let size = CGSize(width: 1000, height: 1000)
                let aspectScaledToFitImage = image?.af_imageAspectScaled(toFit: size)
                
                let imageData:Data! = UIImageJPEGRepresentation(aspectScaledToFitImage!, 0.4)
//                let imageBytes:[UInt8] = Array(imageData)

                
                let parameters: [String: Any] = [
                    "uuid" : self.uuid,
                    "location" : [
                        "type": "Point",
                        "coordinates": [ self.lattitude!, self.longitude!]
                    ]
                ]
                
                self.uploadSessionManager!.request("\(self.appDelegate.host)/photos", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .response(
                        responseSerializer: DataRequest.jsonResponseSerializer(),
                        completionHandler: { response in
                            //                self.viewControllerUtils.hideActivityIndicator(uiView: self.view)
                            
                            self.updateCounter()
                            
                            if let statusCode = response.response?.statusCode {
                                if(statusCode == 401) {
                                    let ac = UIAlertController(title: "Unauthorized", message: "Sorry, looks like you are banned from WiSaw.", preferredStyle: .alert)
                                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                                    self.present(ac, animated: true)
                                    
                                    //cleanup -- delete file
                                    do {
                                        try FileManager.default.removeItem(atPath: imageFilePath)
                                        self.loadImages()
                                    }
                                    catch {
                                        print("Ooops1! Something went wrong: \(error)")
                                    }
                                }
                                
                                if(statusCode == 201) {
                                    if let json = response.result.value as? [String: Any] {
                                        let photo = json["photo"] as! [String: Any]
                                        let photoId = photo["id"] as! Int
                                        print("photos id: \(photoId)")
                                        //clean up -- rename file
                                        do {
                                            let documentDirectory = self.appDelegate.getDocumentsDirectory()
                                            
                                            let destinationPath = documentDirectory.appendingPathComponent("wisaw-\(photoId).jpg")
                                            print("new file uploaded: \(destinationPath.path)")
                                            try FileManager.default.moveItem(at: URL(fileURLWithPath: imageFilePath), to: destinationPath)
                                            
                                            
                                            let headers = [
                                                    "Content-Type": "image/jpeg"
                                                ]
                                
                                            let uploadUrl = json["uploadURL"] as! String

                                            Alamofire.upload(imageData, to: uploadUrl, method: .put, headers: headers)
                                                .responseData {
                                                    response in
                                                     if let statusCode = response.response?.statusCode {
                                                        if(statusCode == 200) {
//                                                            self.loadImages()
                                                            print("done uploading \(statusCode)")
                                                        } else {
                                                            print("error uploading, response code: \(statusCode)")
                                                        }
                                                        
                                                    }
                                            }
                                        } catch {
                                            print("Ooops2! Something went wrong: \(error)")
                                        }

                                    }
                                }
                                
                            }
                    })
                
            } else {
                // still uploading something, just exit
                return
            }

        }

    }
    
    private func updateCounter() {
        let tasksCount = getImagesToUpload().count
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!tasksCount - \(tasksCount)")
        //        http://seanallen.co/posts/uibutton-animations
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = .infinity

        // Update the UI to indicate the work has been completed
        DispatchQueue.main.async {
            if(tasksCount == 0) {
                self.uploadCounterButton!.isHidden = true
            } else {
                self.uploadCounterButton!.isHidden = false
                self.uploadCounterButton!.setTitle(String(tasksCount) , for: .normal)
                self.uploadCounterButton.layer.add(flash, forKey: nil)
            }
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        dismiss(animated: true, completion: nil)
        // save image to document directory
        self.saveImage(image: image)
    }
    

    func saveImage(image: UIImage){
        DispatchQueue(label: "com.wisaw.saveimagequeue", qos: .background).async {
            let currentDate = Date()
            let imageName = "wisaw-new-\(currentDate.hashValue).jpg"
            
            //get the JPG data for this image
            let data = UIImageJPEGRepresentation(image, 0.9)
            //get the image path
            let filename = self.appDelegate.getDocumentsDirectory().appendingPathComponent(imageName)
            try? data!.write(to: filename)
            self.uploadImage()
        }
    }
        
    
    func getImagesToUpload() -> [URL] {
        // Full path to documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents = try? FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
        
        return directoryContents!.filter { $0.path.contains("wisaw-new-") }
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

    
    @IBAction func contactUsButtonClicked(_ sender: Any) {
        
        let contactFormViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactFormViewController") as! ContactFormViewController
        
        present(contactFormViewController, animated: true) {
            print("showing detailed image")
        }
    }
    
    //lock orientation to portratin
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    //lock orientation to portratin
    
    private func cleanup() {
        DispatchQueue(label: "com.wisaw.cleanupqueue", qos: .background).async {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let directoryContents = try? FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            
            for filePathUrl in directoryContents! {
                if(!filePathUrl.path.contains("-new")) {
                    print("^^^^^^^^^^^^^^^^^^^^deleting cached file: \(filePathUrl.path)")

                    do {
                        let attributes = try FileManager.default.attributesOfItem(atPath: filePathUrl.path) as NSDictionary
    //                    print("#####################################1")
    //                    print(attributes)
    //                    print("#####################################2")
                        let modificationDate = attributes["NSFileModificationDate"] as! Date
                        
                        let diffInDays = Calendar.current.dateComponents([.day], from: modificationDate, to: Date()).day
                    
                        if (diffInDays! > 10) {
                            // delete
                            try FileManager.default.removeItem(atPath: filePathUrl.path)
                            print("^^^^^^^^^^^^^^^^^^^^deleted cached file: \(filePathUrl.path)")
                        }
                        
                    } catch {
                        print("Ooops3! Something went wrong: \(error)")
                    }

                }
            }
        }

    }
}

