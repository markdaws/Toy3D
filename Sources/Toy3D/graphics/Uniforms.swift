/// Values that are constant for the entire frame
struct Uniforms {
  var time: Float
  var resolution: SIMD2<Int32>
  var view: Mat4
  var inverseView: Mat4
  var viewProjection: Mat4
}
