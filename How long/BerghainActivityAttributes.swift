import ActivityKit
import Foundation

struct BerghainActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var regularInfo: String?
        var regularDate: Date?
        var glInfo: String?
        var glDate: Date?
        var reentryInfo: String?
        var reentryDate: Date?
        var bouncers: [String]
    }
}
