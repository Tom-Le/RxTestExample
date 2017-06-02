//
//  MainViewController.swift
//  RxTestExample
//
//  Created by Son on 5/29/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {

    private struct Constants {
        static let dogPictureUrl = URL(string: "https://s-media-cache-ak0.pinimg.com/736x/b5/25/22/b525226283f771d2ab913feeab1555f7.jpg")
        static let catPictureUrl = URL(string: "https://s-media-cache-ak0.pinimg.com/736x/29/9e/56/299e56ab07c75af6407289ecc4ab1dd6.jpg")
        static let pandaPictureUrl = URL(string: "https://www.cutestpaw.com/wp-content/uploads/2016/02/Panda-puff..jpg")
        static let foxPictureUrl = URL(string: "https://s3.amazonaws.com/gs-geo-images/0b119fd3-2b7a-4040-81cb-ef58b24b84d5.jpg")
    }

    @IBOutlet weak var dogButton: UIButton!
    @IBOutlet weak var catButton: UIButton!
    @IBOutlet weak var pandaButton: UIButton!
    @IBOutlet weak var foxButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    private let viewModel = MainViewModel(imageDownloader: ImageDownloader())
    private let bag = DisposeBag()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        bind(button: dogButton, to: Constants.dogPictureUrl)
        bind(button: catButton, to: Constants.catPictureUrl)
        bind(button: pandaButton, to: Constants.pandaPictureUrl)
        bind(button: foxButton, to: Constants.foxPictureUrl)

        viewModel.image
            .asDriver(onErrorDriveWith: .never())
            .drive(imageView.rx.image(transitionType: kCATransitionFade))
            .disposed(by: bag)
    }

    private func bind(button: UIButton, to url: URL?) {
        guard let url = url else { return }
        button.rx
            .controlEvent(.touchUpInside)
            .map { return url }
            .bind(to: viewModel.imageRequest)
            .disposed(by: bag)
    }

}
