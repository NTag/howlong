import Foundation

struct QueueInfo: Codable {
    let info: String
    let date: Date
}

struct QueuesResponse: Codable {
    let regular: QueueInfo?
    let gl: QueueInfo?
    let reentry: QueueInfo?
    let bouncers: [String]
}

enum APIService {
    private static let baseURL = "https://berghain.ntag.fr"

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    static func fetchQueues() async throws -> QueuesResponse {
        let url = URL(string: "\(baseURL)/queues")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode(QueuesResponse.self, from: data)
    }

    static func registerToken(_ token: String) async throws {
        let url = URL(string: "\(baseURL)/tokens")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["token": token])
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    static func deregisterToken(_ token: String) async throws {
        let url = URL(string: "\(baseURL)/tokens")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["token": token])
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
