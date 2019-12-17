import simd

/// Simple math utilities
public final class Math {

  private init() { }

  /// Converts degrees to radians
  public static func toRadians(_ degrees: Float) -> Float {
    return degrees * .pi / 180.0
  }

  /// Converts radians to degrees
  public static func toDegrees(_ radians: Float) -> Float {
    return radians * 180.0 / .pi
  }

  /**
   Returns a matrix that converts points from world space to eye space
   */
  public static func makeLook(
    eye: Vec3,
    look: Vec3,
    up: Vec3
  ) -> Mat4 {

    let vLook = normalize(look)
    let vSide = normalize(cross(vLook, normalize(up)))
    let vUp = normalize(cross(vSide, vLook))

    return Mat4([
      Vec4(vSide, 0),
      Vec4(vUp, 0),
      Vec4(vLook, 0),
      Vec4(-eye, 1)
    ])
  }

  /// Returns a perspective projection matrix, to convert world space to Metal clip space
  public static func makePerspective(
    fovyDegrees fovy: Float,
    aspectRatio: Float,
    nearZ: Float,
    farZ: Float
  ) -> Mat4 {
    let ys = 1 / tanf(Math.toRadians(fovy) * 0.5)
    let xs = ys / aspectRatio
    let zs = farZ / (nearZ - farZ)
    return Mat4([
      Vec4(xs,  0, 0,   0),
      Vec4( 0, ys, 0,   0),
      Vec4( 0,  0, zs, -1),
      Vec4( 0,  0, zs * nearZ, 0)
    ])
  }
}
