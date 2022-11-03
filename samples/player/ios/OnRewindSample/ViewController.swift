//
//  ViewController.swift
//  OnRewindTest
//
//  Created by Sergei Mikhan on 1/11/19.
//  Copyright © 2019 Sergei Mikhan. All rights reserved.
//

import UIKit
import OnRewindSDK
import RxSwift
import RxCocoa

import AVKit

extension UINavigationController {

  public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }
}

enum Events: Equatable {
  case fullscreen(OnRewind.EventParams)
  case list(OnRewind.EventParams)
  case embeded(OnRewind.EventParams)
}

class ViewController: UIViewController {

  private let disposeBag = DisposeBag()
  private let eventsSubject = PublishSubject<Events>()

  private let presentButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = .orange
    button.setTitle("Present fullscreen player", for: .normal)
    button.titleLabel?.numberOfLines = 0
    return button
  }()

  private let pushButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = .orange
    button.setTitle("Push embedded player", for: .normal)
    button.titleLabel?.numberOfLines = 0
    return button
  }()

  private let listButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = .orange
    button.setTitle("Push player embedded in list", for: .normal)
    button.titleLabel?.numberOfLines = 0
    return button
  }()

  private var lastEvent: Events?
  private var storedEvent: Events?
  private var restoreCompletion: OnRewind.PipStoreStateClosure?

  override func viewDidLoad() {
    super.viewDidLoad()

    OnRewind.pipStoreState = { [weak self] in
      self?.storedEvent = self?.lastEvent
      guard let event = self?.lastEvent else {
        return
      }
      switch event {
      case .fullscreen:
        // SDK will dismiss view controller
        break
      default:
        // need to pop player controller
        self?.navigationController?.popViewController(animated: true)
      }
    }

    OnRewind.pipRestoreState = { [weak self] completion in
      guard let self = self else {
        completion()
        return
      }
      guard let storedEvent = self.storedEvent else {
        completion()
        return
      }
      self.restoreCompletion = completion;
      self.eventsSubject.onNext(storedEvent)
    }

    view.backgroundColor = .white

    view.addSubview(presentButton)
    view.addSubview(pushButton)
    view.addSubview(listButton)


    OnRewind.set(
      baseUrl: "https://hbs-stats-provider.origins-digital.com/",
      akamaiPrivateKey: "0df73252ceaf17d78589371d5b8d1bbb",
      accountKey: "T6vPCPENV",
      competitionId: "fu17wwc",
      seasonId: "2022"
    )

    let params: OnRewind.EventParams = .matchId("134072")

    eventsSubject.subscribe(onNext: { [weak self] event in
      guard let self = self else { return }
      self.lastEvent = event
      switch event {
      case .embeded(let params):
        self.navigationController?.pushViewController(
          DetailsViewController(params: params),
          animated: true, completion: self.restoreCompletion
        )
      case .fullscreen(let params):
          OnRewind.presentPlayer(with: params, from: self, playerWrapperClosure: {
            //let wrapper = KalturaPlayerDemo()
            let wrapper = AVPlayerDemo()
            return wrapper
          })
      case .list(let params):
        self.navigationController?.pushViewController(
          ListViewController(params: params),
          animated: true, completion: self.restoreCompletion
        )
      }
    }).disposed(by: disposeBag)

    presentButton.rx.tap.subscribe(onNext: { [weak self] in
      self?.eventsSubject.onNext(.fullscreen(params))
    }).disposed(by: disposeBag)

    pushButton.rx.tap.subscribe(onNext: { [weak self] in
      self?.eventsSubject.onNext(.embeded(params))
    }).disposed(by: disposeBag)

    listButton.rx.tap.subscribe(onNext: { [weak self] in
      self?.eventsSubject.onNext(.list(params))
    }).disposed(by: disposeBag)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    presentButton.pin.horizontally(12.0).height(100.0).top(view.pin.safeArea.top + 12).hCenter()
    pushButton.pin.horizontally(12.0).height(100.0).below(of: presentButton).marginTop(12).hCenter()
    listButton.pin.horizontally(12.0).height(100.0).below(of: pushButton).marginTop(12).hCenter()
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .landscape
  }
}
