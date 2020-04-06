import Metal

/**
 A material encapsulate the shaders used to render the mesh. A material knows
 which vertex and fragment shader to load plus associated vertex descriptor.
 */
public final class Material {
  public let renderPipelineState: MTLRenderPipelineState

  /// An optional texture that can be accessed by the shaders associated with the material
  public var texture0: Texture?

  /// Support a second optional texture. Some shaders might need more than one texture
  public var texture1: Texture?

  /// Specifies if front, back or no primitives should be culled
  public var cullMode: MTLCullMode = .none

  /// If false the material is not written to the depth buffer
  public var writesToDepthBuffer = true

  /// The vertex descriptor used to create the material
  public let vertexDescriptor: MTLVertexDescriptor

  public init?(
    renderer: Renderer,
    vertexName: String,
    fragmentName: String,
    vertexDescriptor: MTLVertexDescriptor,
    texture0: Texture?,
    texture1: Texture?
  ) {
    self.texture0 = texture0
    self.texture1 = texture1
    self.vertexDescriptor = vertexDescriptor
    let descriptor = renderer.defaultPipelineDescriptor()
    let fragmentProgram = renderer.library.makeFunction(name: fragmentName)
    let vertexProgram = renderer.library.makeFunction(name: vertexName)
    descriptor.vertexFunction = vertexProgram
    descriptor.fragmentFunction = fragmentProgram
    descriptor.vertexDescriptor = vertexDescriptor

    do {
      let state = try renderer.device.makeRenderPipelineState(descriptor: descriptor)
      renderPipelineState = state
    } catch {
      print(error)
      return nil
    }
  }
}

extension Material {
  /**
   Creates a basic material that supports position, normal, color and texture uv
   */
  public static func createBasic(
    renderer: Renderer,
    texture0: Texture?,
    texture1: Texture? = nil,
    vertexName: String? = nil,
    fragmentName: String? = nil
  ) -> Material? {
    let descriptor = MTLVertexDescriptor()

    // Some vertex buffers are reserved by the render, this gives us the first
    // free vertex buffer that we can use.
    let bufferIndex = Renderer.firstFreeVertexBufferIndex

    // position x,y,z
    descriptor.attributes[0].format = .float3
    descriptor.attributes[0].bufferIndex = bufferIndex
    descriptor.attributes[0].offset = 0

    // normal x,y,z
    descriptor.attributes[1].format = .float3
    descriptor.attributes[1].bufferIndex = bufferIndex
    descriptor.attributes[1].offset = MemoryLayout<Float>.stride * 3

    // color r,g,b,a
    descriptor.attributes[2].format = .float4
    descriptor.attributes[2].bufferIndex = bufferIndex
    descriptor.attributes[2].offset = MemoryLayout<Float>.stride * 6

    // texture u,v
    descriptor.attributes[3].format = .float2
    descriptor.attributes[3].bufferIndex = bufferIndex
    descriptor.attributes[3].offset = MemoryLayout<Float>.stride * 10

    descriptor.layouts[bufferIndex].stride = MemoryLayout<Float>.stride * 12

    return Material(
      renderer: renderer,
      vertexName: vertexName ?? "basic_vertex",
      fragmentName: fragmentName ?? (texture0 != nil ? "texture_fragment" : "color_fragment"),
      vertexDescriptor: descriptor,
      texture0: texture0,
      texture1: texture1
    )
  }

}
