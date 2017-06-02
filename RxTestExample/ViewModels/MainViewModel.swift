//
//  MainViewModel.swift
//  RxTestExample
//
//  Created by Son on 5/29/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import RxSwift
import RxCocoa

final class MainViewModel {

    private let imageDownloader: ImageDownloaderType

    let imageRequest = PublishSubject<URL>()
    var scheduler: SchedulerType?

    var image: Observable<UIImage> {
        return imageRequest
            .asObservable()
            .debounce(0.2, scheduler: scheduler ?? MainScheduler.instance)
            .flatMapLatest { [weak self] url -> Observable<UIImage> in
                guard let welf = self else { return .empty() }
                return welf.imageDownloader.image(from: url).catchError { _ in .empty() }
            }
    }

    required init(imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
    }

}
