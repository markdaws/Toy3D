import Metal

/**
 BasicVertex represents a common set of values that you might want to associate with a vertex.

 This one supports position, color, normal and texture coordinates.
 */
public struct BasicVertex {

  // Empty vertex, useful when initiaizing arrays with a fixed size
  public static let Zero = BasicVertex(pos: [0, 0, 0], normal: [0, 0, 0], color: [0, 0, 0, 0], tex: [0, 0])

  // position
  public var x, y, z : Float

  /// Helper wrapper around the x, y, z values
  public var pos: Vec3 {
     get { return Vec3(x, y, z) }
     set {
       x = newValue.x;
       y = newValue.y;
       z = newValue.z
     }
   }

  // normal
  public var nx, ny, nz: Float

  /// Helper wrapper around the nx, ny, nz values
  public var normal: Vec3 {
    get { return Vec3(nx, ny, nz) }
    set {
      nx = newValue.x
      ny = newValue.y
      nz = newValue.z
    }
  }

  // color
  public var r, g, b, a: Float

  // texCoords
  public var u, v: Float

  public init(pos: Vec3, normal: Vec3, color: Vec4, tex: Vec2) {
    x = pos.x
    y = pos.y
    z = pos.z
    nx = normal.x
    ny = normal.y
    nz = normal.z
    r = color.x
    g = color.y
    b = color.z
    a = color.w
    u = tex.x
    v = tex.y
  }

  public func floatBuffer() -> [Float] {
    return [x, y, z, nx, ny, nz, r, g, b, a, u, v]
  }

  /// Given an array of vertices, returns an MTLBuffer containing the vertex data
  public static func toBuffer(device: MTLDevice, vertices: [BasicVertex]) -> MTLBuffer? {
    var data = [Float]()
    vertices.forEach { (vertex) in
      data.append(contentsOf: vertex.floatBuffer())
    }

    let size = MemoryLayout<BasicVertex>.stride * vertices.count
    return device.makeBuffer(bytes: data, length: size, options: [])
  }
}
