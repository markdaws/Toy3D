import Metal

/**
 BasicVertex represents a common set of values that you might want to associate with a vertex.

 This one supports position, color, normal and texture coordinates.
 */
public struct BasicVertex {

  // position
  public var x, y, z : Float

  // normal
  public var nx, ny, nz: Float

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
