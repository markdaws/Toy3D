import MetalKit

/**
 The texture class is a simple wrapper around a MTLTexture and the associated MTLSamplerState
 */
public final class Texture {

  public var mtlTexture: MTLTexture
  public var samplerState: MTLSamplerState?

  public init(mtlTexture: MTLTexture, samplerState: MTLSamplerState?) {
    self.mtlTexture = mtlTexture
    self.samplerState = samplerState
  }

  /// Loads a texture from the main bundle with the given name
  public static func loadMetalTexture(device: MTLDevice, named: String) -> MTLTexture? {
    let texLoader = MTKTextureLoader(device: device)
    return try? texLoader.newTexture(
      name: named,
      scaleFactor: 1.0,
      bundle: nil,
      options: [.generateMipmaps : true]
    )
  }
}
