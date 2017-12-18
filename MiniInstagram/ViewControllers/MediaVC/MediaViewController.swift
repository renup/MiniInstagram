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
    func userClickedLikeUnlikeButton(media: Media, like: Bool, cell: MediaCell)
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
            if media[indexPath.row].userLiked == true {
                cell.likeUnlikeButton.layer.backgroundColor = UIColor.red.cgColor
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let media = mediaAlbum {
            delegate?.userSelectedAnAlbum(media: media[indexPath.row])
        }
    }
    
    func getCell(_ sender: Any) -> MediaCell? {
        if let button = sender as? UIButton {
            if let cell = button.superview?.superview as? MediaCell {
                return cell
            }
        }
        return nil
    }
    
    @IBAction func likeUnlikeButtonClicked(_ sender: Any) {
        let cell = getCell(sender)
        if let row = cell {
            let indexPath = tableView.indexPath(for: row)
            guard let album = mediaAlbum, let indxPath = indexPath else {
                return
            }
            
            if row.likeUnlikeButton.layer.backgroundColor == UIColor.red.cgColor {
                delegate?.userClickedLikeUnlikeButton(media: album[(indxPath.row)], like: false, cell: row)
            } else {
                delegate?.userClickedLikeUnlikeButton(media: album[(indxPath.row)], like: true, cell: row)
            }
        }
    }
    
    func updateLikeUnlikeButtonAppearance(like: Bool, cell: MediaCell) {
        if like {
            cell.likeUnlikeButton.layer.backgroundColor = UIColor.red.cgColor
        } else {
            cell.likeUnlikeButton.layer.backgroundColor = UIColor.blue.cgColor
        }
    }
    
}


