//
//  MediaCoordinatorTests.swift
//  MiniInstagramTests
//
//  Created by Renu Punjabi on 12/18/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

//No such module issues with quick nimble mockingjay
//https://github.com/Quick/Quick/issues/731

import Quick
import Nimble
import Mockingjay
import SwiftyJSON
import KeychainSwift

@testable import MiniInstagram

class MediaCoordinatorTests: QuickSpec {

    override func spec() {
        super.spec()
        
        describe("MediaCoordinator") {
            let navigationVC = UINavigationController()
            let mediaCoordinator = MediaCoordinator(navigationVC)
            var media: Media?

            describe("APICalls starts here") {
                var response: [Media]?

                context("FetchMedia starts here") {
                  //beforeEach {
                    if let token = APIProcessor.shared.inquireToken() {
                        let _ = self.stub(urlString: "https://api.instagram.com/v1/users/self/media/recent/?access_token=\(token)", jsonFileName: "MediaResponse")
                        mediaCoordinator.requestMedia({ (result) in
                            guard result != nil else {
                                return
                            }
                            response = result as? [Media]
                            
                            for item: Media in response! {
                                if item.mediaId == "1669903803288561092_6696627282" {
                                    media = item
                                    break
                                }
                            }
                        })
                    }
                  
                   // } //end of before each
                    
                    it("returns json response array") {
                        expect(response).toEventuallyNot(beNil(), timeout: 20)
                        expect(response?.count) == 4
                        expect(media?.mediaId) == "1669903803288561092_6696627282"
                        expect(media?.imageURLString) == "https://scontent.cdninstagram.com/t51.2885-15/e35/p320x320/25007224_737507436445425_5299125074937249792_n.jpg"
                        expect(media?.carouselMedia?.count) == 10
                        expect(media?.userName) == "Renu"
                    }
                    
                }// end of context
                
                context("Get album contents") {
                    var albumPicture: AlbumContent?
                    if let album = media {
                        let pictures = mediaCoordinator.processAlbumContents(album: album)
                        
                        for pic: AlbumContent in pictures {
                            if let urlStr = pic.imageURLStr {
                                if urlStr == "https://scontent.cdninstagram.com/t51.2885-15/e35/p320x320/25007224_737507436445425_5299125074937249792_n.jpg" {
                                    albumPicture = pic
                                    break
                                }
                            }
                        } //end of pictures enumerating for loop
                    }// end of if let checking for media
                    
                    it("returns pictures inside of the given Media") {
                        if let picture = albumPicture {
                           expect(picture.imageURLStr) == "https://scontent.cdninstagram.com/t51.2885-15/e35/p320x320/25007224_737507436445425_5299125074937249792_n.jpg"
                        }
                    } //end of it statement
                } //end of get album contents Context
            }
        }
        
    }
}
