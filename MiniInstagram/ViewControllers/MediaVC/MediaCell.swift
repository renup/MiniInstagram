//
//  MediaCell.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/16/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import Alamofire

class MediaCell: UITableViewCell {
    
    @IBOutlet weak var mediaImageView: UIImageView!
    var imageHelper: ImageHelper { return .shared }

    func configureCell(media: Media) {
        setPlaceholderImage(urlString: media.imageURLString)
        imageHelper.reset()
        if let urlStr = media.imageURLString {
            imageHelper.loadImage(urlString: urlStr, completionHandler: {[unowned self] (image) in
                if let receivedImage = image {
                    self.populateWithImage(image: receivedImage)
                }
            })
        }
    }
    
    private func setPlaceholderImage(urlString: String?) {
        // Assigns a placeholder image for the cell
        guard let placeholderImage = UIImage(named: "placeHolder.png"), let urlStr = urlString, let imgURL = URL(string: urlStr) else {
            return
        }
        mediaImageView.af_setImage(withURL: imgURL, placeholderImage: placeholderImage)
    }
    
    /// Populates the coverImageview with the image provided
    ///
    /// - Parameter image: image Object of type UIImage
    private func populateWithImage(image: UIImage) {
        mediaImageView.image = image
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
    }
    
    @IBOutlet weak var unlikeButtonClicked: UIButton!
    
}
