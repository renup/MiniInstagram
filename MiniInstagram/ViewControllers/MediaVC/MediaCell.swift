//
//  MediaCell.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/16/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit

class MediaCell: UITableViewCell {

    @IBOutlet weak var likeUnlikeButton: UIButton!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    var imageHelper: ImageHelper { return .shared }

    func configureCell(media: Media) {
        if let urlStr = media.imageURLString {
            setPlaceholderImage(urlString: urlStr)
            imageHelper.reset()
            imageHelper.loadImage(urlString: urlStr, completionHandler: {[unowned self] (image) in
                if let receivedImage = image {
                    self.populateWithImage(image: receivedImage)
                }
            })
        }
    }
    
    private func setPlaceholderImage(urlString: String) {
        // Assigns a placeholder image for the cell
        guard let imgURL = URL(string: urlString) else {
            return
        }
        mediaImageView.af_setImage(withURL: imgURL, placeholderImage: imageHelper.getPlaceHolderImage(inputURLStr: urlString))
    }
    
    /// Populates the coverImageview with the image provided
    ///
    /// - Parameter image: image Object of type UIImage
    private func populateWithImage(image: UIImage) {
        mediaImageView.image = image
    }
    
}
