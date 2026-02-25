import Foundation
import Observation

@Observable
@MainActor
final class QueueViewModel {
    var queues: QueuesResponse?
    var lastUpdated: Date?
    var isLoading = false
    var error: String?

    private var refreshTimer: Timer?

    func fetch() async {
        isLoading = true
        error = nil
        do {
            queues = try await APIService.fetchQueues()
            lastUpdated = Date.now
        } catch {
            self.error = "Failed to load queues"
        }
        isLoading = false
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.fetch()
            }
        }
    }

    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
