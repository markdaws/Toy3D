import CoreGraphics
import MetalKit

public final class Primitives {

  /**
   Creates a cuboid object centered around 0,0,0 with dimensions width, height and length. Each face of the cube
   can have a color and also texture coordinates are set from 0,0 top left of each face to 1,1 bottom right.

   - Note: Normals are not currently set, they are just set to (0, 0, 0)
   */
  public static func cuboid(
    renderer: Renderer,
    width: Float,
    height: Float,
    length: Float,
    topColor: CGColor = UIColor.white.cgColor,
    rightColor: CGColor = UIColor.white.cgColor,
    bottomColor: CGColor = UIColor.white.cgColor,
    leftColor: CGColor = UIColor.white.cgColor,
    frontColor: CGColor = UIColor.white.cgColor,
    backColor: CGColor = UIColor.white.cgColor
  ) -> Mesh? {
    let hw = width / 2.0
    let hh = height / 2.0
    let hl = length / 2.0

    // Because we can have a different color per face, we can't share vertices across
    // faces, so they must be duplicated
    let vertices = [
      // top
      BasicVertex(pos: [-hw, hh, hl], normal: [0, 0, 0], color: Vec4.from(topColor), tex: [0, 1]),
      BasicVertex(pos: [hw, hh, hl], normal: [0, 0, 0], color: Vec4.from(topColor), tex: [1, 1]),
      BasicVertex(pos: [hw, hh, -hl], normal: [0, 0, 0], color: Vec4.from(topColor), tex: [1, 0]),
      BasicVertex(pos: [-hw, hh, hl], normal: [0, 0, 0], color: Vec4.from(topColor), tex: [0, 1]),
      BasicVertex(pos: [hw, hh, -hl], normal: [0, 0, 0], color: Vec4.from(topColor), tex: [1, 0]),
      BasicVertex(pos: [-hw, hh, -hl], normal: [0, 0, 0], color: Vec4.from(topColor), tex: [0, 0]),

      // right
      BasicVertex(pos: [hw, -hh, hl], normal: [0, 0, 0], color: Vec4.from(rightColor), tex: [0, 1]),
      BasicVertex(pos: [hw, -hh, -hl], normal: [0, 0, 0], color: Vec4.from(rightColor), tex: [1, 1]),
      BasicVertex(pos: [hw, hh, -hl], normal: [0, 0, 0], color: Vec4.from(rightColor), tex: [1, 0]),
      BasicVertex(pos: [hw, -hh, hl], normal: [0, 0, 0], color: Vec4.from(rightColor), tex: [0, 1]),
      BasicVertex(pos: [hw, hh, -hl], normal: [0, 0, 0], color: Vec4.from(rightColor), tex: [1, 0]),
      BasicVertex(pos: [hw, hh, hl], normal: [0, 0, 0], color: Vec4.from(rightColor), tex: [0, 0]),

      // bottom
      BasicVertex(pos: [-hw, -hh, hl], normal: [0, 0, 0], color: Vec4.from(bottomColor), tex: [0, 0]),
      BasicVertex(pos: [-hw, -hh, -hl], normal: [0, 0, 0], color: Vec4.from(bottomColor), tex: [0, 1]),
      BasicVertex(pos: [hw, -hh, -hl], normal: [0, 0, 0], color: Vec4.from(bottomColor), tex: [1, 1]),
      BasicVertex(pos: [-hw, -hh, hl], normal: [0, 0, 0], color: Vec4.from(bottomColor), tex: [0, 0]),
      BasicVertex(pos: [hw, -hh, -hl], normal: [0, 0, 0], color: Vec4.from(bottomColor), tex: [1, 1]),
      BasicVertex(pos: [hw, -hh, hl], normal: [0, 0, 0], color: Vec4.from(bottomColor), tex: [1, 0]),

      // left
      BasicVertex(pos: [-hw, -hh, hl], normal: [0, 0, 0], color: Vec4.from(leftColor), tex: [1, 1]),
      BasicVertex(pos: [-hw, -hh, -hl], normal: [0, 0, 0], color: Vec4.from(leftColor), tex: [0, 1]),
      BasicVertex(pos: [-hw, hh, -hl], normal: [0, 0, 0], color: Vec4.from(leftColor), tex: [0, 0]),
      BasicVertex(pos: [-hw, -hh, hl], normal: [0, 0, 0], color: Vec4.from(leftColor), tex: [1, 1]),
      BasicVertex(pos: [-hw, hh, -hl], normal: [0, 0, 0], color: Vec4.from(leftColor), tex: [0, 0]),
      BasicVertex(pos: [-hw, hh, hl], normal: [0, 0, 0], color: Vec4.from(leftColor), tex: [1, 0]),

      // front
      BasicVertex(pos: [-hw, -hh, hl], normal: [0, 0, 0], color: Vec4.from(frontColor), tex: [0, 1]),
      BasicVertex(pos: [hw, -hh, hl], normal: [0, 0, 0], color: Vec4.from(frontColor), tex: [1, 1]),
      BasicVertex(pos: [hw, hh, hl], normal: [0, 0, 0], color: Vec4.from(frontColor), tex: [1, 0]),
      BasicVertex(pos: [-hw, -hh, hl], normal: [0, 0, 0], color: Vec4.from(frontColor), tex: [0, 1]),
      BasicVertex(pos: [hw, hh, hl], normal: [0, 0, 0], color: Vec4.from(frontColor), tex: [1, 0]),
      BasicVertex(pos: [-hw, hh, hl], normal: [0, 0, 0], color: Vec4.from(frontColor), tex: [0, 0]),

      // back
      BasicVertex(pos: [hw, -hh, -hl], normal: [0, 0, 0], color: Vec4.from(backColor), tex: [0, 1]),
      BasicVertex(pos: [-hw, -hh, -hl], normal: [0, 0, 0], color: Vec4.from(backColor), tex: [1, 1]),
      BasicVertex(pos: [-hw, hh, -hl], normal: [0, 0, 0], color: Vec4.from(backColor), tex: [1, 0]),
      BasicVertex(pos: [hw, -hh, -hl], normal: [0, 0, 0], color: Vec4.from(backColor), tex: [0, 1]),
      BasicVertex(pos: [-hw, hh, -hl], normal: [0, 0, 0], color: Vec4.from(backColor), tex: [1, 0]),
      BasicVertex(pos: [hw, hh, -hl], normal: [0, 0, 0], color: Vec4.from(backColor), tex: [0, 0]),
    ]

    guard let buffer = BasicVertex.toBuffer(device: renderer.device, vertices: vertices) else {
      return nil
    }

    let vertexBuffer = Mesh.VertexBuffer(
      buffer: buffer,
      bufferIndex: Renderer.firstFreeVertexBufferIndex,
      primitiveType: .triangle,
      vertexCount: vertices.count
    )

    return Mesh(vertexBuffer: vertexBuffer)
  }

  // TODO: return a node
  static func sphere(device: MTLDevice, radius: Float) -> MDLMesh {
    let allocator = MTKMeshBufferAllocator(device: device)
    let mesh = MDLMesh.newEllipsoid(
      withRadii: [radius, radius, radius],
      radialSegments: 8,
      verticalSegments: 8,
      geometryType: .triangles,
      inwardNormals: false,
      hemisphere: false,
      allocator: allocator
    )

    // TODO: How would someone define these vertices
    return mesh
  }
  
}
