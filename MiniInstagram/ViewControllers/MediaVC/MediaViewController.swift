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
    func userClickedLikeUnlikeButton(media: Media, like: Bool)    
}

class MediaViewController: UITableViewController {
    var mediaAlbum: [Media]? {
        didSet {
            showMediaAbsentMessage()
            tableView.reloadData()
        }
    }
    var value: MediaViewControllerDelegate?
    weak var delegate: MediaViewControllerDelegate? {
        get{ return value }
        set { value = newValue }
    }
    
    lazy var likeUnlikeButtonCell = MediaCell()
    
    private func showMediaAbsentMessage() {
        if mediaAlbum == nil {
            self.showErrorMessageAlert(title: "No Media", message: "Something went wrong. Please Make sure you are logged in")
        }
        
//        guard let media = mediaAlbum else {
//            return
//        }
//        if media.count < 1 {
//           self.showErrorMessageAlert(title: "No Media", message: "Something went wrong. Please Make sure you are logged in")
//        }
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
            likeUnlikeButtonCell = row
            let indexPath = tableView.indexPath(for: row)
            guard let album = mediaAlbum, let indxPath = indexPath else {
                return
            }
            
            if row.likeUnlikeButton.layer.backgroundColor == UIColor.red.cgColor {
                delegate?.userClickedLikeUnlikeButton(media: album[(indxPath.row)], like: false)
            } else {
                delegate?.userClickedLikeUnlikeButton(media: album[(indxPath.row)], like: true)
            }
        }
    }
    
    func informUserAboutLikeUnlikeFailure() {
        let alert = UIAlertController(title: "Request Failed", message: "Something went wrong. Please try liking/unliking later", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateLikeUnlikeButtonAppearance(like: Bool) {
        if like {
            likeUnlikeButtonCell.likeUnlikeButton.layer.backgroundColor = UIColor.red.cgColor
        } else {
            likeUnlikeButtonCell.likeUnlikeButton.layer.backgroundColor = UIColor.blue.cgColor
        }
    }
    
}


