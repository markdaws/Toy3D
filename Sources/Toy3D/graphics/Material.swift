import Metal

/**
 A material encapsulate the shaders used to render the mesh. A material knows
 which vertex and fragment shader to load plus associated vertex descriptor.
 */
public final class Material {
  public let renderPipelineState: MTLRenderPipelineState
  public var texture: Texture?

  public init?(
    renderer: Renderer,
    vertexName: String,
    fragmentName: String,
    vertexDescriptor: MTLVertexDescriptor,
    texture: Texture?
  ) {
    self.texture = texture
    let descriptor = renderer.defaultPipelineDescriptor()
    let fragmentProgram = renderer.library.makeFunction(name: fragmentName)
    let vertexProgram = renderer.library.makeFunction(name: vertexName)
    descriptor.vertexFunction = vertexProgram
    descriptor.fragmentFunction = fragmentProgram
    descriptor.vertexDescriptor = vertexDescriptor

    guard let state = try? renderer.device.makeRenderPipelineState(descriptor: descriptor) else {
      return nil
    }
    renderPipelineState = state
  }
}

extension Material {
  public static func createBasic(renderer: Renderer, texture: Texture?) -> Material? {
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

    descriptor.attributes[3].format = .float2
    descriptor.attributes[3].bufferIndex = bufferIndex
    descriptor.attributes[3].offset = MemoryLayout<Float>.stride * 10

    descriptor.layouts[bufferIndex].stride = MemoryLayout<Float>.stride * 12

    return Material(
      renderer: renderer,
      vertexName: "basic_vertex",
      fragmentName: texture != nil ? "texture_fragment" : "color_fragment",
      vertexDescriptor: descriptor,
      texture: texture
    )
  }
}
