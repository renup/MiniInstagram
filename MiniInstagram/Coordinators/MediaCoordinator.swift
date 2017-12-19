//
//  MediaCoordinator.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/12/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import OAuthSwift
import SwiftyJSON

protocol MediaCoordinatorDelegate: class {
    func needToRefreshAuthorizingWithInstagram()
}

class MediaCoordinator: NSObject {
    var oauthswift: OAuthSwift?
    var navigationVC: UINavigationController?
    var mediaViewController: MediaViewController?
    var value: MediaCoordinatorDelegate?
    var albumContentViewController: AlbumContentsViewController?
    var tabViewController: InstagramTabBarController?
    
    weak var delegate: MediaCoordinatorDelegate? {
        set { value = newValue }
        get { return value }
    }
    
    init(_ navigationVC: UINavigationController) {
        self.navigationVC = navigationVC
    }

    func showMediaViewController() {
        
        if let tabVC = navigationVC?.viewControllers.first as? InstagramTabBarController {
            tabViewController = tabVC
            if tabVC.selectedIndex == 1 {
                guard let navVC = tabVC.viewControllers![1] as? UINavigationController else {
                    return
                }
                tabViewController?.selectedIndex = 1
                if let mediaVC = navVC.viewControllers.first as? MediaViewController {
                    mediaViewController = mediaVC
                }
                mediaViewController?.delegate = self
                getMedia()
            } else  if tabVC.selectedIndex == 2 {
                guard let navVC = tabVC.viewControllers?.last as? UINavigationController else {
                    return
                }
                tabViewController?.selectedIndex = 2
                if let albumContentsVC = navVC.viewControllers.first as? AlbumContentsViewController {
                    albumContentViewController = albumContentsVC
                } else {
                   //resetting the root of navVC for likes since we pulled it in other navigationstack
                    if let albumVC = albumContentViewController {
                        navVC.setViewControllers([albumVC], animated: false)
                    }
                }
                
                getLikes()
            } //end of else if
        }
    }
    
    private func createMediaObjects(json: JSON) -> [Media] {
        var albumArray = [Media]()
        let array = json["data"] //albums array
        for item in array { //
            let album = Media(mediaAlbum: item)
            albumArray.append(album)
        }
        return albumArray
    }
    
    fileprivate func processAlbumContents(album: Media) -> [AlbumContent] {
        var albumImages = [AlbumContent]()
        if let imagesArray = album.carouselMedia {
            for subJson in imagesArray {
                var contentString = ""
                if subJson["images"].dictionary != nil {
                    contentString = subJson["images"]["low_resolution"]["url"].stringValue
                } else if subJson["videos"].dictionary != nil {
                    contentString = subJson["videos"]["low_resolution"]["url"].stringValue
                }
                let albumContent = AlbumContent(urlString: contentString)
                albumImages.append(albumContent)
            } // end of for loop
        } //end of if let
        return albumImages
    }
    
    
    func requestMedia(_ completionHandler: @escaping completionHandler) {
        DispatchQueue.global(qos: .utility).async {
            APIProcessor.shared.fetchMedia(completionHandler: {[unowned self] (response) in
                if response != nil {
                    let json = JSON(response!)
                    let mediaObjectsArray = self.createMediaObjects(json: json)
                    completionHandler(mediaObjectsArray)
                        return
                }
                completionHandler(response)
            })
        }
    }
    
    private func getMedia() {
        //start loading animation
        requestMedia {[unowned self] (mediaObjects) in
            self.mediaViewController?.mediaAlbum = mediaObjects as? [Media]
        }
        //stop loading animation
    }

    func requestLikes(_ likesCompletionHandler: @escaping completionHandler) {
        DispatchQueue.global(qos: .utility).async {
            APIProcessor.shared.fetchUserLikes(completionHandler: {[unowned self] (response) in

                if let result = response {
                   let pictures =  self.processLikesResponse(response: result)
                    likesCompletionHandler(pictures)
                    return
                }
                likesCompletionHandler(response)
            })
        }
    }
    
    func getLikes() {
        //show loading animation
        requestLikes {[unowned self] (response) in
            self.albumContentViewController?.albumPictureURLs = response as? [AlbumContent]
        }
    }
    
    private func processLikesResponse(response: Any) -> [AlbumContent] {
        let json = JSON(response)
            var likedPhotosURLStringArray = [AlbumContent]()
            let array = self.createMediaObjects(json: json)
            for item in array {
                let likedPhotos = self.processAlbumContents(album: item)
                likedPhotosURLStringArray.append(contentsOf: likedPhotos)
            }
        return likedPhotosURLStringArray
    }
}

extension MediaCoordinator: MediaViewControllerDelegate {
    func userClickedLikeUnlikeButton(media: Media, like: Bool, cell: MediaCell) {
        if let id = media.mediaId {
            APIProcessor.shared.likeUnlikeMedia(mediaId: id, like: like) {[unowned self] (response) in
                let json = JSON(response!)
                
                if json["meta"]["code"] == 200 {
                    self.mediaViewController?.updateLikeUnlikeButtonAppearance(like: like, cell: cell)
                }
            }
        }
    }
    
    
    func userSelectedAnAlbum(media: Media) {
        let albumPictureURLs = processAlbumContents(album: media)
    
        if let navVC = tabViewController?.viewControllers![1] as? UINavigationController {
            if albumContentViewController == nil {
                guard let albumContentVC = AlbumContentsViewController.instantiateControllerFromStoryboard(name: "Instagram", identifier: "AlbumContentsViewController") as? AlbumContentsViewController else {
                    return
                }
                albumContentViewController = albumContentVC
            }
            albumContentViewController?.albumPictureURLs = albumPictureURLs
            navVC.pushViewController(albumContentViewController!, animated: true)
        }
    }
}
