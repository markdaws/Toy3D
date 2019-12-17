import simd

/*
 An axis aligned bounding box
 */
public struct AABB {
  public let min: Vec3
  public let max: Vec3
  public let center: Vec3
  public let size: Vec3

  public init() {
    min = Vec3.zero
    max = Vec3.zero
    center = Vec3.zero
    size = Vec3.zero
  }

  public init(min: Vec3, max: Vec3) {
    self.min = min
    self.max = max
    size = max - min
    center = min + 0.5 * size
  }

  /// Returns a copy of the AABB with the bounds added to it.
  public func add(bounds: AABB) -> AABB {
    let min = simd.min(bounds.min, self.min)
    let max = simd.max(bounds.max, self.max)
    return AABB(min: min, max: max)
  }

  /// Returns true if the point is contained inside the AABB
  public func contains(_ item: Vec3) -> Bool {
    return
      item.x >= min.x &&
      item.y >= min.y &&
      item.z >= min.z &&
      item.x <= max.x &&
      item.y <= max.y &&
      item.z <= max.z
  }
}
