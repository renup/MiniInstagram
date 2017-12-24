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
    var mediaArr: [Media]? {
        didSet {
            tableView.reloadData()
            showMediaAbsentMessage()
        }
    }
    var value: MediaViewControllerDelegate?
    weak var delegate: MediaViewControllerDelegate? {
        get{ return value }
        set { value = newValue }
    }
    
    lazy var likeUnlikeButtonCell = MediaCell()
    
    private func showMediaAbsentMessage() {
        if mediaArr == nil || (mediaArr?.count)! < 1 {
            self.showErrorMessageAlert(title: "No Media", message: "Something went wrong. Please Make sure you are logged in or you have internet connectivity")
        }
    }
    
    //MARK: dataSource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mediaArray = mediaArr {
            return mediaArray.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mediaCell", for: indexPath) as! MediaCell

        if let mediaArray = mediaArr {
            cell.configureCell(media: mediaArray[indexPath.row])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mediaArray = mediaArr {
            delegate?.userSelectedAnAlbum(media: mediaArray[indexPath.row])
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
            guard let mediaArray = mediaArr, let indxPath = indexPath else {
                return
            }
            
            var album = mediaArray[indxPath.row]
            guard let liked = album.userLiked else {
                return
            }
            
            if liked { //unlike the photo
                mediaArr![indxPath.row].userLiked = false
                delegate?.userClickedLikeUnlikeButton(media: mediaArray[(indxPath.row)], like: false)
            } else { //like the photo
                mediaArr![indxPath.row].userLiked = true
                delegate?.userClickedLikeUnlikeButton(media: mediaArray[(indxPath.row)], like: true)
            }
        }
    }
    
    func informUserAboutLikeUnlikeFailure() {
        showErrorMessageAlert(title: "Request Failed", message: "Something went wrong. Please try liking/unliking later")
    }
    
    func updateLikeUnlikeButtonAppearance(like: Bool) {
        if like {
            likeUnlikeButtonCell.likeUnlikeButton.setBackgroundImage(UIImage(named: "like"), for: .normal)
        } else {
            likeUnlikeButtonCell.likeUnlikeButton.setBackgroundImage(UIImage(named: "dislike"), for: .normal)
        }
    }
    
}


