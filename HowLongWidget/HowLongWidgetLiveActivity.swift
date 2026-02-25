import ActivityKit
import SwiftUI
import WidgetKit

struct HowLongWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BerghainActivityAttributes.self) { context in
            LockScreenView(state: context.state)
                .activityBackgroundTint(.black.opacity(0.7))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Text("BH")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .padding(4)
                            .background(.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        Text("Berghain")
                            .font(.headline)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.regularInfo ?? "—")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Normal queue")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            } compactLeading: {
                Text("BH")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .padding(.horizontal, 4)
            } compactTrailing: {
                Text(context.state.regularInfo ?? "—")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
            } minimal: {
                Text("BH")
                    .font(.system(size: 10, weight: .black, design: .rounded))
            }
        }
    }


}

// MARK: - Lock Screen View

private struct LockScreenView: View {
    let state: BerghainActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack(alignment: .top, spacing: 8) {
                Text("BH")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 0) {
                    Text("Berghain")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("LIVE ACTIVITY")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.gray)
                }

                Spacer()

                if let latestDate {
                    (Text(latestDate, style: .relative)
                        .font(.system(size: 10))
                        .foregroundStyle(.gray)
                    + Text(" ago")
                        .font(.system(size: 10))
                        .foregroundStyle(.gray))
                    .multilineTextAlignment(.trailing)
                }
            }

            // Queue cards
            HStack(spacing: 8) {
                QueueCard(
                    icon: "lock.fill",
                    label: "Normal",
                    info: state.regularInfo,
                    date: state.regularDate
                )
                QueueCard(
                    icon: "rectangle.on.rectangle",
                    label: "Re-entry",
                    info: state.reentryInfo,
                    date: state.reentryDate
                )
                QueueCard(
                    icon: "person.2.fill",
                    label: "Guest List",
                    info: state.glInfo,
                    date: state.glDate,
                    isHighlighted: state.glInfo?.lowercased().contains("no queue") == true
                )
            }

            // Bouncers
            if !state.bouncers.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 5, height: 5)
                        Text("BOUNCERS ON SHIFT")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.gray)
                    }

                    HStack(spacing: 6) {
                        ForEach(state.bouncers, id: \.self) { name in
                            Text(name)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.white.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
    }

    private var latestDate: Date? {
        [state.regularDate, state.glDate, state.reentryDate]
            .compactMap { $0 }
            .max()
    }
}

// MARK: - Queue Card (Lock Screen)

private struct QueueCard: View {
    let icon: String
    let label: String
    let info: String?
    let date: Date?
    var isHighlighted: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(isHighlighted ? .green : .white.opacity(0.8))

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.gray)

            if let info {
                Text(info)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isHighlighted ? .green : .white)
            } else {
                Text("No info")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.white.opacity(isHighlighted ? 0.08 : 0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Queue Pill (Dynamic Island)

private struct QueuePill: View {
    let label: String
    let info: String?

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.gray)
            Text(info ?? "Closed")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(info != nil ? .white : .white.opacity(0.4))
        }
    }
}

#Preview("Live Activity", as: .content, using: BerghainActivityAttributes()) {
    HowLongWidgetLiveActivity()
} contentStates: {
    BerghainActivityAttributes.ContentState(
        regularInfo: "1h Wait",
        regularDate: .now.addingTimeInterval(-120),
        glInfo: "No Queue",
        glDate: .now.addingTimeInterval(-120),
        reentryInfo: "2h Wait",
        reentryDate: .now.addingTimeInterval(-120),
        bouncers: ["Matrix", "Andy", "Yoan"]
    )
    BerghainActivityAttributes.ContentState(
        regularInfo: "40 min",
        regularDate: .now.addingTimeInterval(-300),
        glInfo: nil,
        glDate: nil,
        reentryInfo: "10 people",
        reentryDate: .now.addingTimeInterval(-300),
        bouncers: ["Matrix", "Sven"]
    )
}
