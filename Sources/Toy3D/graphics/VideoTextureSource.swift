//
//  VideoTextureSource.swift
//
//  Created by Mark Dawson on 4/5/20.
//

import AVFoundation
import Foundation

// Code ported from this article:
// https://www.invasivecode.com/weblog/metal-video-processing-ios-tvos/

/**
 VideoTextureSource can be used to extract frames from a video source and convert those
 frames to MTLTexture instances.
 */
public final class VideoTextureSource {
  private let player: AVPlayer
  private let playerItemVideoOutput: AVPlayerItemVideoOutput
  private let textureCache: CVMetalTextureCache

  public init?(renderer: Renderer, videoUrl: URL) {
    var textCache: CVMetalTextureCache?
    if CVMetalTextureCacheCreate(
      kCFAllocatorDefault,
      nil,
      renderer.device,
      nil,
      &textCache
      ) != kCVReturnSuccess {
      print("Unable to allocate texture cache.")
      return nil
    }

    self.textureCache = textCache!

    let asset = AVURLAsset(url: videoUrl)

    playerItemVideoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [
      String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)
    ])

    let playerItem = AVPlayerItem(asset: asset)
    playerItem.add(playerItemVideoOutput)

    player = AVPlayer(playerItem: playerItem)
    player.actionAtItemEnd = .none
  }

  /**
   Causes the video to begin playing

   - Parameters:
     - repeat: If true the video will repeat from the beginning once it has completed
   */
  public func play(repeat: Bool) {
    NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: self.player.currentItem,
      queue: .main
    ) { [weak self] _ in
      self?.player.seek(to: CMTime.zero)
      self?.player.play()
    }

    player.play()
  }

  /// Pauses the video
  public func pause() {
    player.pause()
  }

  /**
   When called will extract a MTLTexture from the video.

   - Parameters:
      hostTime: The timestamp of the frame to extract. If nil CACurrentMediaTime is used.
   */
  public func createTexture(hostTime: CFTimeInterval?) -> MTLTexture? {
    var currentTime = CMTime.invalid
    currentTime = playerItemVideoOutput.itemTime(forHostTime: hostTime ?? CACurrentMediaTime())

    guard playerItemVideoOutput.hasNewPixelBuffer(forItemTime: currentTime),
      let pixelBuffer = playerItemVideoOutput.copyPixelBuffer(
        forItemTime: currentTime,
        itemTimeForDisplay: nil) else {
      return nil
    }

    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)

    var cvTextureOut: CVMetalTexture?
    CVMetalTextureCacheCreateTextureFromImage(
      kCFAllocatorDefault,
      self.textureCache,
      pixelBuffer,
      nil,
      .bgra8Unorm,
      width,
      height,
      0,
      &cvTextureOut
    )

    guard let cvTexture = cvTextureOut, let inputTexture = CVMetalTextureGetTexture(cvTexture) else {
       print("Failed to create metal texture")
       return nil
    }
    return inputTexture
  }
}
