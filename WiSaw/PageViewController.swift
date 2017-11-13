//
//  PageViewController.swift
//  WiSaw
//
//  Created by D on 11/12/17.
//  Copyright © 2017 EchoWaves. All rights reserved.
//

import Foundation
import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageIndex = 0
    var photos: [Any] = []

    //this is a cache of detailed contollers
    var detailedViewControllers = [Int: DetailedViewController]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        

        setViewControllers([detailedViewController(pageIndex: pageIndex)], direction: .forward, animated: true, completion: nil)
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            if pageIndex == 0 {
                return nil
                // wrap to last page in array
            } else {
                // go to previous page in array
                pageIndex -= 1
                return detailedViewController(pageIndex: pageIndex)
            }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if pageIndex == photos.count - 1 {
            // wrap to last page in array
            return nil
        } else {
            // go to previous page in array
            pageIndex += 1
            return detailedViewController(pageIndex: pageIndex)
        }
    }
    
    func detailedViewController(pageIndex: Int) -> DetailedViewController {
        
        if let detailedViewController = detailedViewControllers[pageIndex] {
            return detailedViewController
        }
        
        let detailedViewController:DetailedViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController
        detailedViewController.photoJSON = self.photos[pageIndex] as! [String: Any]
        detailedViewControllers[pageIndex] = detailedViewController
        return detailedViewController
    }
    
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//    }
}
