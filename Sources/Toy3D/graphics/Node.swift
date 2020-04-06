import MetalKit

// https://stackoverflow.com/questions/38773807/difference-between-packed-vs-normal-data-type

/**
 The Node class provides us with a way to hierarchically organise our scene data for rendering.

 A node can have 0 or more child nodes. The child nodes transforms are applied in addition to the
 parents. So if we have a structure like N0 -> N1 -> N2 where N2 is a child of N1 and N1 is a child
 of N0. Then the final model transform applied to N2 would be (in right to left order):
 N0.transform * N1.transform * N2.transform

 A node can have a mesh associated with it. If not the node is simply a container.
 */
public final class Node {
  public var position = Vec3(0, 0, 0)
  public var orientation = Quaternion.identity
  public var scale = Vec3(1, 1, 1)

  /// If provided the transform property will return this value vs. combining the pos / scale / orientation values
  public var overrideTransform: Mat4?

  /**
   The mesh associated with the node. Note that this is optional, a mesh can just be a container
   for other child nodes and not have any renderable information associated with it.
   */
  public var mesh: Mesh?

  /**
   The update function can be used to modify the node parameters every frame. If this closure is
   present it will be called once before the render call, every frame. You could use this to rotate
   the node etc.
   */
  public var update: ((_ time: Time, _ node: Node) -> Void)?

  /**
   Returns a matrix that is the combination of the position, orientation and scale properties.
   These are applied in scale -> rotate -> translate order.
   */
  public var transform: Mat4 {
    if let overrideTransform = overrideTransform {
      return overrideTransform
    }
    let translate = Mat4.translate(position)
    let s = Mat4.scale(scale.x, scale.y, scale.z)
    return translate * orientation.toMat() * s
  }

  /// If true this node and all of its descendents are not rendered
  public var isHidden = false

  private var children = [Node]()

  public init(mesh: Mesh? = nil) {
    self.mesh = mesh
  }

  /// Adds a new child to the nodes children collection at the end
  public func addChild(_ child: Node) {
    children.append(child)
  }

  /// Adds a new child in the nodes children collection at the specified index
  public func insertChild(_ child: Node, index: Int) {
    children.insert(child, at: index)
  }

  /// Removes a child from the node
  public func removeChild(_ child: Node) {
    let index = children.firstIndex { (node) -> Bool in
      return node === child
    }

    if let index = index {
      children.remove(at: index)
    }
  }

  /// Removes all children from the node
  public func clearAllChildren() {
    children.removeAll()
  }

  func updateInternal(time: Time) {
    update?(time, self)

    for child in children {
      child.updateInternal(time: time)
    }
  }

  func render(
    time: Time,
    camera: PerspectiveCamera,
    renderer: Renderer,
    encoder: MTLRenderCommandEncoder,
    parentTransform: Mat4
  ) {

    if isHidden {
      return
    }

    let worldTransform = parentTransform * transform

    // If there is no mesh then this is simply a passthrough node that contains
    // other nodes
    if let mesh = mesh, let material = mesh.material {

      // Every model has a unique model matrix, so we pass them through to the vertex
      // shader using a buffer, just like the vertices.
      // Since the data is small we can just use setVertexBytes to let Metal give
      // us a buffer from it's buffer pool.
      var constants = ModelConstants(
        modelMatrix: worldTransform,
        inverseModelMatrix: simd_inverse(worldTransform)
      )
      encoder.setVertexBytes(&constants, length: MemoryLayout<ModelConstants>.size, index: 1)

      if let texture0 = material.texture0 {
        encoder.setFragmentTexture(texture0.mtlTexture, index: 0)
        encoder.setFragmentSamplerState(texture0.samplerState, index: 0)
      }

      if let texture1 = material.texture1 {
        encoder.setFragmentTexture(texture1.mtlTexture, index: 1)
        encoder.setFragmentSamplerState(texture1.samplerState, index: 1)
      }

      if material.writesToDepthBuffer {
        encoder.setDepthStencilState(renderer.enabledDepthStencilState)
      } else {
        encoder.setDepthStencilState(renderer.disabledDepthStencilState)
      }

      encoder.setCullMode(material.cullMode)

      encoder.setRenderPipelineState(material.renderPipelineState)
      mesh.render(encoder: encoder)
    }

    for node in children {
      node.render(
        time: time,
        camera: camera,
        renderer: renderer,
        encoder: encoder,
        parentTransform: worldTransform
      )
    }
  }

}

