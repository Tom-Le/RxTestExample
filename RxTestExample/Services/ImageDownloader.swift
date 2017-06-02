//
//  ImageDownloader.swift
//  RxTestExample
//
//  Created by Son on 5/29/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import RxSwift

protocol ImageDownloaderType {
    func image(from: URL) -> Observable<UIImage>
}

final class ImageDownloader: ImageDownloaderType {

    func image(from link: URL) -> Observable<UIImage> {
        return .create { observer in
            let dataTask = URLSession.shared.dataTask(with: link) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {
                    observer.onError(LazyError(message: "Invalid image data"))
                    return
                }
                observer.onNext(image)
                observer.onCompleted()
            }

            dataTask.resume()

            return Disposables.create {
                dataTask.cancel()
            }
        }
    }
}
