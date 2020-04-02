/// A struct that contains per model information, for now just the model matrix
/// that transforms the model from local to world space.
struct ModelConstants {
  var modelMatrix: Mat4
  var inverseModelMatrix: Mat4
}
