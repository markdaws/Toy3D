import simd

//Simple typealias to make using sind types easier

public typealias Quaternion = simd_quatf

extension Quaternion {
  public static let identity = simd_quatf(angle: 0, axis: [1, 0, 0])

  public func toMat() -> Mat4 {
    var m = Mat4(self)
    m[3][3] = 1
    return m
  }
}
