import AppKit

public final class HapticFeedbackManager {
    public static let shared = HapticFeedbackManager()

    private init() {}

    public func triggerSuccess() {
        // Trigger standard generic confirmation haptic feedback pattern on supported Force Touch Trackpads
        NSHapticFeedbackManager.defaultPerformer.perform(
            .alignment,
            performanceTime: .now
        )
    }

    public func triggerFailure() {
        // Trigger a triple click/warning vibration haptic
        NSHapticFeedbackManager.defaultPerformer.perform(
            .alignment,
            performanceTime: .now
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        }
    }

    public func triggerSnapshotSwitch() {
        // Trigger standard snapshot state transition haptic ticks
        NSHapticFeedbackManager.defaultPerformer.perform(
            .levelChange,
            performanceTime: .now
        )
    }
}
