//
//  MainViewModelTests.swift
//  RxTestExample
//
//  Created by Son on 5/30/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import RxTestExample

private final class MockImageDownloader: ImageDownloaderType {

    var image: UIImage?

    func image(from: URL) -> Observable<UIImage> {
        guard let image = image else {
            return .error(LazyError(message: "No image"))
        }
        return Observable.just(image)
    }
}

final class MainViewModelTests: XCTestCase {

    private var mockImageDownloader: MockImageDownloader!
    private var viewModel: MainViewModel!
    private var testScheduler: TestScheduler!

    override func setUp() {
        super.setUp()

        mockImageDownloader = MockImageDownloader()
        viewModel = MainViewModel(imageDownloader: mockImageDownloader)
        testScheduler = TestScheduler(initialClock: 0, resolution: 0.1, simulateProcessingDelay: false)

        viewModel.scheduler = testScheduler
    }

    func testRequestingImagesSucceedsMethod1() throws {
        let dummyImage = UIImage()
        mockImageDownloader.image = dummyImage

        let _ = testScheduler
            .createHotObservable([
                next(10, try URL(string: "https://example.com").unwrap()),
                next(20, try URL(string: "https://example.com").unwrap()),
                next(30, try URL(string: "https://example.com").unwrap())
            ])
            .bind(to: viewModel.imageRequest)

        let imageObserver = testScheduler.createObserver(UIImage.self)
        let _ = viewModel.image.subscribe(imageObserver)

        testScheduler.start()

        let expectedEvents = [
            next(12, dummyImage),
            next(22, dummyImage),
            next(32, dummyImage)
        ]
        XCTAssertEqual(expectedEvents, imageObserver.events)
    }

    func testRequestingImagesSucceedsMethod2() throws {
        let dummyImage = UIImage()
        mockImageDownloader.image = dummyImage

        let _ = testScheduler
            .createHotObservable([
                next(10, try URL(string: "https://example.com").unwrap()),
                next(20, try URL(string: "https://example.com").unwrap()),
                next(30, try URL(string: "https://example.com").unwrap())
            ])
            .bind(to: viewModel.imageRequest)

        let imageObservable = viewModel.image
        let imageObserver = testScheduler.start(created: 0, subscribed: 0, disposed: 40) {
            return imageObservable
        }
        let expectedEvents = [
            next(12, dummyImage),
            next(22, dummyImage),
            next(32, dummyImage)
        ]
        XCTAssertEqual(expectedEvents, imageObserver.events)
    }

    func testRequestingImageFailsDoesNotTerminateImageObservable() throws {
        let dummyImage = UIImage()

        let _ = testScheduler
            .createHotObservable([
                next(10, try URL(string: "https://example.com").unwrap()),
                next(20, try URL(string: "https://example.com").unwrap()),
                next(30, try URL(string: "https://example.com").unwrap())
            ])
            .bind(to: viewModel.imageRequest)

        testScheduler.scheduleAt(25) { [weak self] in
            self?.mockImageDownloader.image = dummyImage
        }

        let imageObservable = viewModel.image
        let imageObserver = testScheduler.start(created: 0, subscribed: 0, disposed: 40) {
            return imageObservable
        }
        let expectedEvents = [next(32, dummyImage)]
        XCTAssertEqual(expectedEvents, imageObserver.events)
    }

    func testRequestsThrottled() throws {
        let dummyImage = UIImage()
        mockImageDownloader.image = dummyImage

        let _ = testScheduler
            .createHotObservable([
                next(1, try URL(string: "https://example.com").unwrap()),
                next(2, try URL(string: "https://example.com").unwrap()),
                next(3, try URL(string: "https://example.com").unwrap()),
                next(6, try URL(string: "https://example.com").unwrap()),
                next(7, try URL(string: "https://example.com").unwrap())
            ])
            .bind(to: viewModel.imageRequest)

        let imageObservable = viewModel.image
        let imageObserver = testScheduler.start(created: 0, subscribed: 0, disposed: 10) { imageObservable }

        let expectedEvents = [next(5, dummyImage), next(9, dummyImage)]
        XCTAssertEqual(expectedEvents, imageObserver.events)
    }

}
