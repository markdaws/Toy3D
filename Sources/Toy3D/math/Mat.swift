import simd

// A simple typealias around SIMD to make typing easier
public typealias Mat4 = float4x4

extension Mat4 {
  public static let identity = float4x4(Float(1.0))
}

extension Mat4 {

  /// Creates a scale matrix with the diagonal set to scaleX, scaleY, scaleZ
  public static func scale(_ scaleX: Float, _ scaleY: Float, _ scaleZ: Float) -> Mat4 {
    return Mat4(diagonal: [scaleX, scaleY, scaleZ, 1])
  }

  /// Creates a matrix that rotates around the origin using the specified axis and angle
  public static func rotate(radians: Float, axis: Vec3) -> Mat4 {
    return Mat4(Quaternion(angle: radians, axis: axis))
  }

  /// Creates a translation matrix
  public static func translate(_ translation: Vec3) -> Mat4 {
    return Mat4(columns:(Vec4(1, 0, 0, 0),
                         Vec4(0, 1, 0, 0),
                         Vec4(0, 0, 1, 0),
                         Vec4(translation, 1))
    )
  }
}
