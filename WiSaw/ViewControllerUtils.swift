//
//  ViewControllerUtils.swift
//  WiSaw
//
//  Created by D on 11/10/17.
//  Copyright © 2017 EchoWaves. All rights reserved.
//
//https://github.com/erangaeb/dev-notes/blob/master/swift/ViewControllerUtils.swift


import Foundation
import UIKit

class ViewControllerUtils {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    /*
     Show customized activity indicator,
     actually add activity indicator to passing view
     
     @param uiView - add activity indicator to this view
     */
    func showActivityIndicator(uiView: UIView) {
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = uiView.center
        
        uiView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    /*
     Hide activity indicator
     Actually remove activity indicator from its super view
     
     @param uiView - remove activity indicator from this view
     */
    func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    /*
     Define UIColor from hex value
     
     @param rgbValue - hex color value
     @param alpha - transparency level
     */
//    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
//        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
//        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
//        let blue = CGFloat(rgbValue & 0xFF)/256.0
//        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
//    }
    
}

//// In order to show the activity indicator, call the function from your view controller
//// ViewControllerUtils().showActivityIndicator(self.view)

//// In order to hide the activity indicator, call the function from your view controller
//// ViewControllerUtils().hideActivityIndicator(self.view)

