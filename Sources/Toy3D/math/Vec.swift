import CoreGraphics

// Some simple typealiases and helper classes to make using SIMD easier

public typealias Vec2 = SIMD2<Float>
public typealias Vec2UI = SIMD2<UInt32>
public typealias Vec2I = SIMD2<Int>
public typealias Vec3 = SIMD3<Float>
public typealias Vec3I = SIMD3<Int>
public typealias Vec4 = SIMD4<Float>

extension Vec3 {

  init(v: Vec3I) {
    self.init(Float(v.x), Float(v.y), Float(v.z))
  }

  /// Returns a vector with random x,y,z values between -1 and 1
  public static func random() -> Vec3 {
    return [
      Float.random(in: -1.0...1.0),
      Float.random(in: -1.0...1.0),
      Float.random(in: -1.0...1.0)
    ]
  }

  public func to4(w: Float) -> Vec4 {
    return Vec4(self.x, self.y, self.z, w)
  }
}

extension Vec3I {
  func toFloat() -> Vec3 {
    return [Float(self.x), Float(self.y), Float(self.z)]
  }
}
extension Vec4 {

  /// Given a CGColor returns a Vec4 with x,y,z,w set to r,g,b,a
  public static func from(_ color: CGColor) -> Vec4 {
    guard let c = color.components else {
      return Vec4.zero
    }

    if c.count == 2 {
      return [Float(c[0]), Float(c[0]), Float(c[0]), Float(c[1])]
    }

    return [Float(c[0]), Float(c[1]), Float(c[2]), Float(c[3])]
  }

  public func to3() -> Vec3 {
    return Vec3(self.x, self.y, self.z)
  }
}
