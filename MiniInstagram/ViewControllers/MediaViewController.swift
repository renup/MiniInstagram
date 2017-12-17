//
//  MediaViewController.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/12/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit

class MediaCell: UITableViewCell {
    @IBOutlet weak var mediaImageView: UIImageView!
    
    @IBOutlet weak var likeUnlikeButton: UIButton!
    
    func configureCell(media: Media) {
        
    }
    
    @IBAction func likeUnlikeButtonClicked(_ sender: Any) {
    }
    
    
}


protocol MediaViewControllerDelegate: class {
    func userLikedAMedia()
}

class MediaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var mediaAlbum: [Media]?
    var value: MediaViewControllerDelegate?
    weak var delegate: MediaViewControllerDelegate? {
        get{ return value }
        set { value = newValue }
    }
    
    //MARK: dataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let media = mediaAlbum {
            return media.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mediaCell", for: indexPath) as! MediaCell
        if let media = mediaAlbum {
            cell.configureCell(media: media[indexPath.row])
        }
        return cell
    }
    
}


