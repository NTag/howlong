import ActivityKit
import Foundation

struct BerghainActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var regularInfo: String?
        var regularDate: Double?
        var glInfo: String?
        var glDate: Double?
        var reentryInfo: String?
        var reentryDate: Double?
        var bouncers: [String]

        /// Returns the most recent date from all queues.
        var latestDate: Date? {
            [regularDate, glDate, reentryDate]
                .compactMap { $0.map { Date(timeIntervalSince1970: $0) } }
                .max()
        }
    }
}
