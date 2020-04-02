
// https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/FunctionsandLibraries.html#//apple_ref/doc/uid/TP40016642-CH24-SW1

import MetalKit
import MetalPerformanceShaders

/**
 The render class is our entry point into a 3D scene. It is repsonsible for creating the MTLDevice and
 command queue and also creates a Scene object that will can use to populate with 3D object.

 The renderer also implements the MTKViewDelegate protocol and gets the per frame updates
 from MTKView for rendering.

 You will want to create the renderer instance first and hold on to it for the lifetime of your app.
 */
public final class Renderer: NSObject {

  // Internally we are using two vertex buffer slots for uniform
  // and per model data in slots 0 and 1. This value lets callers
  // know what is the first buffer they can use safely
  public static let firstFreeVertexBufferIndex = 2

  public let device: MTLDevice
  public let library: MTLLibrary
  public let commandQueue: MTLCommandQueue
  public let scene = Scene()
  public let fpsCounter = FPSCounter(sampleCount: 100)
  public var onFrame: (() -> Void)?
  public var onViewportSizeChanged: ((CGSize) -> Void)?

  internal var enabledDepthStencilState: MTLDepthStencilState
  internal var disabledDepthStencilState: MTLDepthStencilState

  private var lastTime: TimeInterval?
  private let creationTime: TimeInterval
  private let mtkView: MTKView
  private let uniformBuffers: BufferManager

  public init?(mtkView: MTKView) {

    guard let device = MTLCreateSystemDefaultDevice() else {
      print("Metal is not supported")
      return nil
    }
    self.device = device

    guard let library = device.makeDefaultLibrary() else {
      print("Failed to make default library")
      return nil
    }
    self.library = library

    guard let commandQueue = device.makeCommandQueue() else {
      print("Failed to make a command queue")
      return nil
    }
    self.commandQueue = commandQueue

    self.mtkView = mtkView
    mtkView.device = device

    mtkView.colorPixelFormat = .bgra8Unorm_srgb
    mtkView.depthStencilPixelFormat = .depth32Float

    uniformBuffers = BufferManager(device: device, inflightCount: 3, createBuffer: { (device) in
      return device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: [])
    })
    uniformBuffers.createBuffers()

    let enabledDepthDescriptor = MTLDepthStencilDescriptor()
    enabledDepthDescriptor.isDepthWriteEnabled = true
    enabledDepthDescriptor.depthCompareFunction = .less
    enabledDepthStencilState = device.makeDepthStencilState(descriptor: enabledDepthDescriptor)!

    let disabledDepthDescriptor = MTLDepthStencilDescriptor()
    disabledDepthDescriptor.isDepthWriteEnabled = false
    disabledDepthDescriptor.depthCompareFunction = .less
    disabledDepthStencilState = device.makeDepthStencilState(descriptor: disabledDepthDescriptor)!

    creationTime = Date.timeIntervalSinceReferenceDate
    super.init()
  }

  func defaultPipelineDescriptor() -> MTLRenderPipelineDescriptor {
    let descriptor = MTLRenderPipelineDescriptor()
    descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
    descriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
    return descriptor
  }

}

extension Renderer: MTKViewDelegate {

  /// This is called anytime the view size changes. If this happens we need to update
  /// the camera values accordingly
  public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    scene.camera.aspectRatio = Float(size.width / size.height)
    onViewportSizeChanged?(size)
  }

  /// Called every frame
  public func draw(in view: MTKView) {
    onFrame?()

    guard let descriptor = view.currentRenderPassDescriptor else {
      return
    }

    guard let commandBuffer = commandQueue.makeCommandBuffer() else {
      return
    }

    guard let drawable = view.currentDrawable else {
      return
    }

    let attachment = descriptor.colorAttachments[0]
    attachment?.loadAction = .clear
    attachment?.clearColor = scene.clearColor

    guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
      return
    }

    let now = Date.timeIntervalSinceReferenceDate
    if lastTime == nil {
      lastTime = now
    }

    let time = Time(
      totalTime: Date.timeIntervalSinceReferenceDate - creationTime,
      updateTime: now - lastTime!
    )
    lastTime = now

    // The uniform buffers store values that are constant across the entire frame
    let uniformBuffer = uniformBuffers.nextSync()
    let uniformContents = uniformBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
    uniformContents.pointee.time = Float(time.totalTime)

    let viewMatrix = scene.camera.viewMatrix
    uniformContents.pointee.view = viewMatrix

    uniformContents.pointee.inverseView = viewMatrix.inverse
    uniformContents.pointee.viewProjection = scene.camera.projectionMatrix * viewMatrix
    uniformContents.pointee.resolution = [
      Int32(mtkView.frame.size.width * UIScreen.main.scale),
      Int32(mtkView.frame.size.height * UIScreen.main.scale)
    ]

    encoder.setDepthStencilState(enabledDepthStencilState)
    encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 0)
    encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)

    fpsCounter.newFrame(time: time)
    scene.update(time: time)

    scene.render(
      time: time,
      renderer: self,
      encoder: encoder,
      uniformBuffer: uniformBuffer
    )

    encoder.endEncoding()

    commandBuffer.addCompletedHandler { (MTLCommandBuffer) in
      self.uniformBuffers.release()
    }

    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
