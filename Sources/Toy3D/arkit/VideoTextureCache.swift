//
//  VideoTextureCache.swift
//  
//
//  Created by Mark Dawson on 3/28/20.
//

import ARKit
import CoreVideo
import Foundation

/// A cache used to interact with ARFrame video frames
public final class VideoTextureCache {
  private var capturedImageTextureCache: CVMetalTextureCache!

  public init?(device: MTLDevice) {
    var textureCache: CVMetalTextureCache?
    let result = CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
    if result != kCVReturnSuccess {
      return nil
    }
    capturedImageTextureCache = textureCache
  }

  /// Returns a texture containing the image data of the frames captured image
  public func toTexture(frame: ARFrame) -> (y: CVMetalTexture, CbCr: CVMetalTexture)? {
    // Create two textures (Y and CbCr) from the provided frame's captured image
    let pixelBuffer = frame.capturedImage

    if (CVPixelBufferGetPlaneCount(pixelBuffer) < 2) {
      return nil
    }

    guard let capturedImageTextureY = createTexture(
      fromPixelBuffer: pixelBuffer,
      pixelFormat:.r8Unorm, planeIndex:0),
    let capturedImageTextureCbCr = createTexture(
      fromPixelBuffer: pixelBuffer,
      pixelFormat:.rg8Unorm, planeIndex:1) else {
        return nil
    }

    return (y: capturedImageTextureY, CbCr: capturedImageTextureCbCr)
  }

   private func createTexture(
     fromPixelBuffer pixelBuffer: CVPixelBuffer,
     pixelFormat: MTLPixelFormat,
     planeIndex: Int
   ) -> CVMetalTexture? {
     let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
     let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)

     var texture: CVMetalTexture? = nil
     let status = CVMetalTextureCacheCreateTextureFromImage(
       nil,
       capturedImageTextureCache,
       pixelBuffer,
       nil,
       pixelFormat,
       width,
       height,
       planeIndex,
       &texture)

     if status != kCVReturnSuccess {
         return nil
     }

     return texture
   }

}
