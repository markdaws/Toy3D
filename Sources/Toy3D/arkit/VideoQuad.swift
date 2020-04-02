//
//  VideoQuad.swift
//  
//
//  Created by Mark Dawson on 3/28/20.
//

import ARKit
import Foundation

/// Creates a quad that renders a video feed from ARKit
public final class VideoQuad {

  public let node = Node()

  private var videoTextureCache: VideoTextureCache?
  private var displayToCameraTransform = CGAffineTransform.identity

  public init() { }

  /// Call to create a cache to hold the video information. This must be called for the quad to render any content
  public func createCache(renderer: Renderer) {
    videoTextureCache = VideoTextureCache(device: renderer.device)

    initQuad(renderer)
  }

  /// Updates the quad with the latest video feed information
  public func update(renderer: Renderer, frame: ARFrame) {
    guard let textures = videoTextureCache?.toTexture(frame: frame) else {
      return
    }

    guard let mesh = node.mesh else {
      return
    }

    // Once we have some textures we will create the material otherwise the
    // shader will error out
    if mesh.material == nil {
      let descriptor = MTLVertexDescriptor()

      // texture clip space coords
      descriptor.attributes[0].format = .float3
      descriptor.attributes[0].bufferIndex = Renderer.firstFreeVertexBufferIndex
      descriptor.attributes[0].offset = 0

      // texture u,v
      descriptor.attributes[1].format = .float2
      descriptor.attributes[1].bufferIndex = Renderer.firstFreeVertexBufferIndex
      descriptor.attributes[1].offset = MemoryLayout<Float>.stride * 10

      // TODO: Replace 12 with the size of the basic vertex
      descriptor.layouts[Renderer.firstFreeVertexBufferIndex].stride = MemoryLayout<Float>.size * 12

      let material = Material(
        renderer: renderer,
        vertexName: "capturedImageVertexTransform",
        fragmentName: "capturedImageFragmentShader",
        vertexDescriptor: descriptor,
        texture0: nil,
        texture1: nil
      )

      // We don't want the video feed writing to the depth buffer, otherwise other
      // 3D content will not be rendered
      material?.writesToDepthBuffer = false

      mesh.material = material
    }

    guard let textureY = CVMetalTextureGetTexture(textures.y),
      let textureCbCr = CVMetalTextureGetTexture(textures.CbCr) else {
      return
    }

    mesh.material?.texture0 = Texture(mtlTexture: textureY, samplerState: nil)
    mesh.material?.texture1 = Texture(mtlTexture: textureCbCr, samplerState: nil)
  }

  private func initQuad(_ renderer: Renderer) {
    guard let vertexBuffer = createVertexBuffer(renderer: renderer) else {
      print("failed to create VideoQuad vertex buffer")
      return
    }

    // We draw two triangles to fill the screen, then the vertex shader just passes
    // through the position values which are already set in clip space
    let mesh = Mesh(vertexBuffer: vertexBuffer)
    node.mesh = mesh
  }

  public func viewportSizeChanged(_ renderer: Renderer, _ frame: ARFrame, _ viewportSize: CGSize) {
    displayToCameraTransform = frame.displayTransform(
      for: .landscapeRight,
      viewportSize: viewportSize).inverted()

    guard let vertexBuffer = createVertexBuffer(renderer: renderer) else {
      print("Failed to create vertex buffer after resize")
      return
    }

    node.mesh?.vertexBuffer = vertexBuffer
  }

  private func createVertexBuffer(renderer: Renderer) -> Mesh.VertexBuffer? {

    let t = { (texIn: Vec2) -> Vec2 in
      let textureCoord = CGPoint(x: CGFloat(texIn.x), y: CGFloat(texIn.y))
      let transformedCoord = textureCoord.applying(self.displayToCameraTransform)
      return [Float(transformedCoord.x), Float(transformedCoord.y)]
    }

    let vertices: [BasicVertex] = [
      BasicVertex(pos: [-1, -1, 0], normal: [0, 0, 0], color: [0, 0, 0, 0], tex: t([0, 1])),
      BasicVertex(pos: [1, -1, 0], normal: [0, 0, 0], color: [0, 0, 0, 0], tex: t([1, 1])),
      BasicVertex(pos: [1, 1, 0], normal: [0, 0, 0], color: [0, 0, 0, 0], tex: t([1, 0])),
      BasicVertex(pos: [-1, -1, 0], normal: [0, 0, 0], color: [0, 0, 0, 0], tex: t([0, 1])),
      BasicVertex(pos: [1, 1, 0], normal: [0, 0, 0], color: [0, 0, 0, 0], tex: t([1, 0])),
      BasicVertex(pos: [-1, 1 ,0], normal: [0, 0, 0], color: [0, 0, 0, 0], tex: t([0, 0])),
    ]

    guard let buffer = BasicVertex.toBuffer(device: renderer.device, vertices: vertices) else {
      return nil
    }

    return Mesh.VertexBuffer(
      buffer: buffer,
      bufferIndex: Renderer.firstFreeVertexBufferIndex,
      primitiveType: .triangle,
      vertexCount: 6
    )
  }
}
