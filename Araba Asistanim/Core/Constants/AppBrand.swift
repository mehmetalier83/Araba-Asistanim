import Foundation

/// The user-visible product name. It comes from `CFBundleDisplayName`, set by
/// the target's `INFOPLIST_KEY_CFBundleDisplayName` build setting, so renaming
/// the app (home screen and in-app text alike) is a one-line change there.
enum AppBrand {
    static let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? "Araba Asistanım"

    /// The name in capitals for small eyebrow labels, using Turkish casing (i → İ).
    static let uppercasedName = name.uppercased(with: Locale(identifier: "tr_TR"))
}
