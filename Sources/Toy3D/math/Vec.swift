import CoreGraphics

// Some simple typealiases and helper classes to make using SIMD easier

public typealias Vec2 = SIMD2<Float>
public typealias Vec3 = SIMD3<Float>
public typealias Vec4 = SIMD4<Float>

extension Vec3 {
  
  /// Returns a vector with random x,y,z values between -1 and 1
  public static func random() -> Vec3 {
    return [
      Float.random(in: -1.0...1.0),
      Float.random(in: -1.0...1.0),
      Float.random(in: -1.0...1.0)
    ]
  }
}

extension Vec4 {

  /// Given a CGColor returns a Vec4 with x,y,z,w set to r,g,b,a
  public static func from(_ color: CGColor) -> Vec4 {
    guard let c = color.components else {
      return Vec4.zero
    }

    return [Float(c[0]), Float(c[1]), Float(c[2]), Float(c[3])]
  }
}
