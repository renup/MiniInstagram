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
            
            describe("APICalls starts here") {
                var response: [Media]?
                var media: Media?                
                
                context("FetchMedia starts here") {
                    let _ = self.stub(urlString: "https://api.instagram.com/v1/users/self/media/recent/?access_token=\(String(describing: APIProcessor.shared.inquireToken()))", jsonFileName: "MediaResponse")
                    mediaCoordinator.requestMedia({ (result) in
                        guard result != nil else {
                            return
                        }
                        response = result as? [Media]
                        
                        for item: Media in response! {
                            if item.mediaId == "1669903803288561092_6696627282" {
                                media = item
                            }
                        }
                    })
//                    beforeEach {
//                    } //end of before each
                }// end of context
                
                it("returns json response array") {
                    expect(response).toEventuallyNot(beNil(), timeout: 20)
                    expect(response?.count) == 4
                    expect(media?.mediaId) == "1669903803288561092_6696627282"
                    expect(media?.imageURLString) == "https://scontent.cdninstagram.com/t51.2885-15/e35/p320x320/25007224_737507436445425_5299125074937249792_n.jpg"
                    expect(media?.carouselMedia?.count) == 10
                    expect(media?.userName) == "Renu"
                }
            }
        }
        
    }
}
