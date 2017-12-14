//
//  MediaViewController.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/12/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit

protocol MediaViewControllerDelegate: class {
    func userLikedAMedia()
}

class MediaViewController: UIViewController {
    var value: MediaViewControllerDelegate?
   
    weak var delegate: MediaViewControllerDelegate? {
        get{ return value }
        set { value = newValue }
    }
}
