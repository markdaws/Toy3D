public final class PerspectiveCamera {

  public var origin: Vec3 { didSet { buildView = true } }
  public var look: Vec3 { didSet { buildView = true } }
  public var up: Vec3 { didSet { buildView = true } }
  public var fovYDegrees: Float { didSet { buildProjection = true } }
  public var aspectRatio: Float { didSet { buildProjection = true } }
  public var zNear: Float { didSet { buildProjection = true } }
  public var zFar: Float { didSet { buildProjection = true } }

  /// If set will override the default projection matrix that is calculated from the explicit camera parameters
  public var overrideProjectionMatrix: Mat4?

  /// If set will override the default view matrix that is calculated from the explicit camera parameters
  public var overrideViewMatrix: Mat4?

  private var buildProjection = true
  private var buildView = true
  private var _projectionMatrix = Mat4.identity
  private var _viewMatrix = Mat4.identity

  public var projectionMatrix: Mat4 {
    get {
      if let overrideProjectionMatrix = overrideProjectionMatrix {
        return overrideProjectionMatrix
      }

      if buildProjection {
        buildProjection = false
        _projectionMatrix = Math.makePerspective(
          fovyDegrees: fovYDegrees,
          aspectRatio: aspectRatio,
          nearZ: zNear,
          farZ: zFar
        )
      }
      return _projectionMatrix
    }
  }

  public var viewMatrix: Mat4 {
    get {
      if let overrideViewMatrix = overrideViewMatrix {
        return overrideViewMatrix
      }

      if buildView {
        buildView = false
        _viewMatrix = Math.makeLook(eye: origin, look: look, up: up)
      }
      return _viewMatrix
    }
  }

  public init(
    origin: Vec3,
    look: Vec3,
    up: Vec3,
    fovYDegrees: Float,
    aspectRatio: Float,
    zNear: Float,
    zFar: Float
  ) {
    self.origin = origin
    self.look = look
    self.up = up
    self.fovYDegrees = fovYDegrees
    self.aspectRatio = aspectRatio
    self.zNear = zNear
    self.zFar = zFar
  }

}

extension PerspectiveCamera: CustomDebugStringConvertible {

  public var debugDescription: String {
    return "origin: \(origin), fovY: \(fovYDegrees), ar: \(aspectRatio)"
  }
}
