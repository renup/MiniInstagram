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
    func userSelectedAnAlbum(media: Media)
}

class MediaViewController: UITableViewController {
    
    var mediaAlbum: [Media]? {
        didSet {
            tableView.reloadData()
        }
    }
    var value: MediaViewControllerDelegate?
    weak var delegate: MediaViewControllerDelegate? {
        get{ return value }
        set { value = newValue }
    }
    
    //MARK: dataSource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let media = mediaAlbum {
            return media.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mediaCell", for: indexPath) as! MediaCell
        if let media = mediaAlbum {
            cell.configureCell(media: media[indexPath.row])
            cell.likeButton.isHidden = true
            cell.unlikeButton.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let media = mediaAlbum {
            delegate?.userSelectedAnAlbum(media: media[indexPath.row])
        }
    }
    
}


