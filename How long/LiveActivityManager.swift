import ActivityKit
import Foundation
import Observation

@Observable
@MainActor
final class LiveActivityManager {
    var isActive = false
    var error: String?

    private var activity: Activity<BerghainActivityAttributes>?
    private var tokenObservationTask: Task<Void, Never>?
    private var currentToken: String?

    var canStartActivity: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func start() async {
        error = nil

        // Fetch current queue data for initial state
        let initialState: BerghainActivityAttributes.ContentState
        do {
            let queues = try await APIService.fetchQueues()
            initialState = BerghainActivityAttributes.ContentState(
                regularInfo: queues.regular?.info,
                regularDate: queues.regular?.date,
                glInfo: queues.gl?.info,
                glDate: queues.gl?.date,
                reentryInfo: queues.reentry?.info,
                reentryDate: queues.reentry?.date,
                bouncers: queues.bouncers
            )
        } catch {
            self.error = "Failed to fetch queue data: \(error.localizedDescription)"
            return
        }

        // Start the Live Activity
        do {
            let attributes = BerghainActivityAttributes()
            let content = ActivityContent(state: initialState, staleDate: Date.now.addingTimeInterval(5 * 60))

            let activity = try Activity<BerghainActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: .token
            )
            self.activity = activity
            self.isActive = true

            observePushTokenUpdates(for: activity)
        } catch {
            self.error = "Failed to start Live Activity: \(error.localizedDescription)"
        }
    }

    func stop() async {
        guard let activity else { return }

        // Deregister token from backend
        if let token = currentToken {
            try? await APIService.deregisterToken(token)
        }

        tokenObservationTask?.cancel()
        tokenObservationTask = nil
        currentToken = nil

        let finalState = activity.content.state
        await activity.end(
            ActivityContent(state: finalState, staleDate: nil),
            dismissalPolicy: .immediate
        )

        self.activity = nil
        self.isActive = false
    }

    private nonisolated func observePushTokenUpdates(for activity: Activity<BerghainActivityAttributes>) {
        Task { @MainActor in
            tokenObservationTask?.cancel()
            tokenObservationTask = Task {
                for await pushToken in activity.pushTokenUpdates {
                    let tokenString = pushToken.map { String(format: "%02x", $0) }.joined()

                    // Deregister old token if it changed
                    if let oldToken = currentToken, oldToken != tokenString {
                        try? await APIService.deregisterToken(oldToken)
                    }

                    currentToken = tokenString

                    do {
                        try await APIService.registerToken(tokenString)
                    } catch {
                        self.error = "Failed to register push token"
                    }
                }
            }
        }
    }
}
