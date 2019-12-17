public struct Sphere {
  let center: Vec3
  let radius: Float

  /// Returns the bounds of the specified sphere as an axis aligned bounding box
  public static func bounds(_ sphere: Sphere) -> AABB {
    return AABB(
      min: sphere.center - sphere.radius,
      max: sphere.center + sphere.radius
    )
  }
}
