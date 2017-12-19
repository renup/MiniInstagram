//
//  UIViewControllerHelper.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/13/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

//UIViewController convenience class to instantiate ViewController from storyboard

import Foundation
import UIKit

extension UIViewController {
    
    func showErrorMessageAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    class func defaultNibName() -> String {
        return String(describing: self)
    }
    
    class func instantiateUsingDefaultStoryboardIdWithStoryboardName(name: String) -> UIViewController {
        print("defaultname: \(defaultNibName())")
        return instantiateControllerFromStoryboard(name: name, identifier: defaultNibName())
    }
    
    class func instantiateControllerFromStoryboard(name: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard.init(name: name, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
}
