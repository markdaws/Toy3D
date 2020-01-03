import Foundation

public final class FPSCounter {
  private var total = 0.0
  private var sampleIndex = 0
  private var samples: [Double]
  private let sampleCount: Int

  public var currentFPS: Double {
    return 1.0 / (total / Double(sampleCount))
  }

  init(sampleCount: Int) {
    self.sampleCount = sampleCount

    samples = [Double](repeating: 0.0, count: sampleCount)
  }

  func newFrame(time: Time) {
    // Loops through the sample buffer using the last sampleCount values
    // to calculate a moving average of the FPS
    total -= samples[sampleIndex]
    total += time.updateTime
    samples[sampleIndex] = time.updateTime
    sampleIndex = (sampleIndex + 1) % sampleCount
  }
}
