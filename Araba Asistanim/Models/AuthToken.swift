import Foundation

/// A session token pair. Shaped to match what a typical OAuth2/JWT-style ASP.NET
/// API would return, so swapping MockAuthService for a real implementation later
/// doesn't require changing this type.
struct AuthToken: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    var isExpired: Bool { expiresAt <= .now }
}
