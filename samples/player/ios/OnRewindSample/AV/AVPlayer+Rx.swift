//
//  AVPlayer+Rx.swift
//  RxAVPlayer
//
//  Created by Patrick Mick on 3/30/16.
//  Copyright © 2016 YayNext. All rights reserved.
//

import Foundation
import RxSwift
import AVFoundation



extension Reactive where Base: AVPlayer {
  var rate: Observable<Float> {
    return self.observe(Float.self, #keyPath(AVPlayer.rate))
      .map { $0 ?? 0 }
  }

  var currentItem: Observable<AVPlayerItem?> {
    return observe(AVPlayerItem.self, #keyPath(AVPlayer.currentItem))
  }

  var status: Observable<AVPlayer.Status> {
    return self.observe(AVPlayer.Status.self, #keyPath(AVPlayer.status))
      .map { $0 ?? .unknown }
  }

  var error: Observable<NSError?> {
    return self.observe(NSError.self, #keyPath(AVPlayer.error))
  }

  @available(iOS 10.0, tvOS 10.0, *)
  var reasonForWaitingToPlay: Observable<AVPlayer.WaitingReason?> {
    return self.observe(AVPlayer.WaitingReason.self, #keyPath(AVPlayer.reasonForWaitingToPlay))
  }

  @available(iOS 10.0, tvOS 10.0, *)
  var timeControlStatus: Observable<AVPlayer.TimeControlStatus> {
    return self.observe(AVPlayer.TimeControlStatus.self, #keyPath(AVPlayer.timeControlStatus))
      .map { $0 ?? .waitingToPlayAtSpecifiedRate }
  }

  func periodicTimeObserver(interval: CMTime) -> Observable<CMTime> {
    return Observable.create { observer in
      let t = self.base.addPeriodicTimeObserver(forInterval: interval, queue: nil) { time in
        // NOTE: a bit tricky part. We need to skip progress in case of "loading" video
        // it can cause unnecessry zero values for live videos for example
        if #available(iOS 10.0, *) {
          guard self.base.reasonForWaitingToPlay == nil else { return }
        }
        guard self.base.currentItem?.status != .unknown else { return }
        observer.onNext(time)
      }

      return Disposables.create { self.base.removeTimeObserver(t) }
    }
  }

  func boundaryTimeObserver(times: [CMTime]) -> Observable<Void> {
    return Observable.create { observer in
      let timeValues = times.map() { NSValue(time: $0) }
      let t = self.base.addBoundaryTimeObserver(forTimes: timeValues, queue: nil) {
        observer.onNext(())
      }

      return Disposables.create { self.base.removeTimeObserver(t) }
    }
  }
}
