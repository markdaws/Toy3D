import Metal

/**
 Wraps the concepts of a pool of buffers. The caller passes in a closure that creates the specific buffer
 and then you can call nextSync to get a new buffer and release() once the commandbuffer no longer
 needs to hold a reference to it.
 */
final class BufferManager {

  private let device: MTLDevice
  private let inflightCount: Int
  private var bufferIndex: Int = 0
  private let createBuffer: (MTLDevice) -> MTLBuffer?
  private let semaphore: DispatchSemaphore
  private var buffers: [MTLBuffer]

  /**
   - parameters:
     - device: The metal device
     - inflightCount: The number of buffers to manage
     - createBuffer: a closure that will ne called inflightCount times to create the buffers
   */
  init(device: MTLDevice, inflightCount: Int, createBuffer: @escaping (MTLDevice) -> MTLBuffer?) {
    self.device = device
    self.inflightCount = inflightCount
    self.createBuffer = createBuffer
    semaphore = DispatchSemaphore(value: inflightCount)
    buffers = [MTLBuffer]()
  }

  /// You must call this before calling nextSync()
  func createBuffers() {
    for _ in 0..<inflightCount {
      if let buffer = createBuffer(device) {
        buffers.append(buffer)
      } else {
        print("Failed to create buffer")
      }
    }
  }

  /// Returns the next free buffer. If a buffer is not available this will block the caller
  func nextSync() -> MTLBuffer {
    semaphore.wait()

    let buffer = buffers[bufferIndex]
    bufferIndex = (bufferIndex + 1) % inflightCount
    return buffer
  }

  /**
   Indicates a buffer has been released.

   - note: There is an implicit assumption that buffers are released in the same order
           that they were acquired in.
   */
  func release() {
    semaphore.signal()
  }
}
