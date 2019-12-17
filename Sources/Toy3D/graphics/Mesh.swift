import MetalKit

/**
 A mesh contains the vertices data and also an associated material that should be
 used to render the mesh.

 The vertices and the material are tightly coupled since the underlying shaders expect
 data to be in a certain format in the vertex buffer.

 Each material specifies the vertex descriptor that it expects in the vertex buffer.
 */
public final class Mesh {

  public struct VertexBuffer {
    public let buffer: MTLBuffer
    public let bufferIndex: Int
    public let primitiveType: MTLPrimitiveType
    public let vertexCount: Int

    public init(buffer: MTLBuffer, bufferIndex: Int, primitiveType: MTLPrimitiveType, vertexCount: Int) {
      self.buffer = buffer
      self.bufferIndex = bufferIndex
      self.primitiveType = primitiveType
      self.vertexCount = vertexCount
    }
  }

  public var vertexBuffer: VertexBuffer? = nil
  public var mtkMesh: MTKMesh?
  public var material: Material?

  public init(mtkMesh: MTKMesh) {
    self.mtkMesh = mtkMesh
  }

  public init(vertexBuffer: VertexBuffer) {
    self.vertexBuffer = vertexBuffer
  }

  func render(encoder: MTLRenderCommandEncoder) {

    if let mesh = mtkMesh {
      encoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: Renderer.firstFreeVertexBufferIndex)

      for submesh in mesh.submeshes {
        encoder.drawIndexedPrimitives(
          type: .triangle,
          indexCount: submesh.indexCount,
          indexType: submesh.indexType,
          indexBuffer: submesh.indexBuffer.buffer,
          indexBufferOffset: submesh.indexBuffer.offset
        )
      }
      return
    }

    guard let vertexBuffer = vertexBuffer else {
      return
    }

    encoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: vertexBuffer.bufferIndex)
    encoder.drawPrimitives(
      type: vertexBuffer.primitiveType,
      vertexStart: 0,
      vertexCount: vertexBuffer.vertexCount,
      instanceCount: 1
    )
  }
}
