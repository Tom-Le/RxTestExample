//
//  ImageDownloaderTests.swift
//  RxTestExample
//
//  Created by Son on 5/30/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import OHHTTPStubs
@testable import RxTestExample

final class ImageDownloaderTests: XCTestCase {

    let imageDownloader = ImageDownloader()

    override func setUp() {
        super.setUp()

        stub(condition: isHost("www.rose.com")) { _ in
            guard let path = Bundle(for: type(of: self)).path(forResource: "rose", ofType: "jpg") else {
                return OHHTTPStubsResponse(error: LazyError(message: "No image"))
            }
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: nil)
        }

        stub(condition: isHost("www.failure.com")) { _ in
            return OHHTTPStubsResponse(error: LazyError(message: "whoops"))
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testImageDownloadSucceeds() throws {
        let url = try URL(string: "http://www.rose.com/").unwrap()
        guard let _ = try imageDownloader.image(from: url).toBlocking().single() else {
            XCTFail("Image download failed")
            return
        }
    }

    func testImageDownloadFails() throws {
        do {
            let url = try URL(string: "http://www.failure.com/").unwrap()
            let _ = try imageDownloader.image(from: url).toBlocking().first()
            XCTFail("Image download should have failed")
        } catch let error as LazyError where error.message == "whoops" {
            return
        }
    }

}
