import SwiftUI

struct ContentView: View {
    @State private var manager = LiveActivityManager()
    @State private var viewModel = QueueViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Text("BH")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                    Text("How Long?")
                        .font(.title3.weight(.semibold))
                }
                .padding(.top, 24)

                // Queue cards
                if let queues = viewModel.queues {
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            AppQueueCard(
                                icon: "lock.fill",
                                label: "Normal",
                                info: queues.regular?.info,
                                date: queues.regular?.date
                            )
                            AppQueueCard(
                                icon: "rectangle.on.rectangle",
                                label: "Re-entry",
                                info: queues.reentry?.info,
                                date: queues.reentry?.date
                            )
                            AppQueueCard(
                                icon: "person.2.fill",
                                label: "Guest List",
                                info: queues.gl?.info,
                                date: queues.gl?.date
                            )
                        }

                        // Bouncers
                        if !queues.bouncers.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 6, height: 6)
                                    Text("BOUNCERS ON SHIFT")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }

                                HStack(spacing: 6) {
                                    ForEach(queues.bouncers, id: \.self) { name in
                                        Text(name)
                                            .font(.caption.weight(.medium))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 5)
                                            .background(.fill.tertiary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Last updated
                        if let lastUpdated = viewModel.lastUpdated {
                            HStack(spacing: 4) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .controlSize(.mini)
                                }
                                Text("Updated ")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                + Text(lastUpdated, style: .relative)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                + Text(" ago")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .padding(16)
                    .background(.fill.quinary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                } else if viewModel.isLoading {
                    ProgressView()
                        .padding(40)
                } else if let error = viewModel.error {
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(40)
                }

                // Live Activity button
                VStack(spacing: 8) {
                    if !manager.canStartActivity {
                        Label("Live Activities are disabled in Settings", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    if let error = manager.error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task {
                            if manager.isActive {
                                await manager.stop()
                            } else {
                                await manager.start()
                            }
                        }
                    } label: {
                        Label(
                            manager.isActive ? "Stop Live Activity" : "Start Live Activity",
                            systemImage: manager.isActive ? "stop.circle.fill" : "play.circle.fill"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(manager.isActive ? Color.red : Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!manager.canStartActivity)
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 16)
        }
        .task {
            await viewModel.fetch()
            viewModel.startAutoRefresh()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                Task { await viewModel.fetch() }
                viewModel.startAutoRefresh()
            } else {
                viewModel.stopAutoRefresh()
            }
        }
    }
}

// MARK: - App Queue Card

private struct AppQueueCard: View {
    let icon: String
    let label: String
    let info: String?
    let date: Date?

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(info != nil ? .primary : .tertiary)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            if let info {
                Text(info)
                    .font(.headline)
            } else {
                Text("No info")
                    .font(.headline)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.fill.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ContentView()
}
