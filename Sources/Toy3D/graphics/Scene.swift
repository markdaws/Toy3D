import Metal

/**
 A scene contains a single root object where you can add all of the nodes that
 will be rendered in a scene.
 */
public final class Scene {

  /// The top level node in our entire scene
  public let root = Node()

  /// A camera used to view the content of the scene
  public var camera: PerspectiveCamera

  /// A color that will be used as the background for every new frame
  public var clearColor: MTLClearColor = MTLClearColor(
    red: 0.0,
    green: 0.0,
    blue: 0.0,
    alpha: 1.0
  )

  init() {
    camera = PerspectiveCamera(
      origin: [0, 0, 5],
      look: [0, 0, -1],
      up: [0, 1, 0],
      fovYDegrees: 90,
      aspectRatio: 1.0,
      zNear: 0.001,
      zFar: 1000.0
    )
  }

  func update(time: Time) {
    root.updateInternal(time: time)
  }

  func render(
    time: Time,
    renderer: Renderer,
    encoder: MTLRenderCommandEncoder,
    uniformBuffer: MTLBuffer
  ) {

    root.render(
      time: time,
      camera: camera,
      renderer: renderer,
      encoder: encoder,
      parentTransform: Mat4.identity
    )

  }
}
