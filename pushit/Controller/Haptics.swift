import CoreHaptics

class HapticManager {
  // 1
  let hapticEngine: CHHapticEngine

  // 2
  init?() {
    // 3
    let hapticCapability = CHHapticEngine.capabilitiesForHardware()
    guard hapticCapability.supportsHaptics else {
      return nil
    }

    // 4
    do {
      hapticEngine = try CHHapticEngine()
    } catch let error {
      print("Haptic engine Creation Error: \(error)")
      return nil
    }
  }
    
    
}

extension HapticManager {
  private func slicePattern() throws -> CHHapticPattern {
    let slice = CHHapticEvent(
      eventType: .hapticContinuous,
      parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
      ],
      relativeTime: 0,
      duration: 0.25)

    let snip = CHHapticEvent(
      eventType: .hapticTransient,
      parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
      ],
      relativeTime: 0.08)

    return try CHHapticPattern(events: [slice, snip], parameters: [])
  }
    
    func playSlice() {
      do {
        // 1
        let pattern = try slicePattern()
        // 2
        try hapticEngine.start()
        // 3
        let player = try hapticEngine.makePlayer(with: pattern)
        // 4
        try player.start(atTime: CHHapticTimeImmediate)
        // 5
        hapticEngine.notifyWhenPlayersFinished { _ in
          return .stopEngine
        }
      } catch {
        print("Failed to play slice: \(error)")
      }
    }
}
