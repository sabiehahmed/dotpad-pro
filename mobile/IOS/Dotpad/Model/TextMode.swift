import Foundation

/// A dot stores either rich text (RTF) or plain text (Markdown-friendly).
enum TextMode: String, Codable, CaseIterable {
    case rich
    case plain

    var fileExtension: String {
        switch self {
        case .rich: return "rtf"
        case .plain: return "txt"
        }
    }
}
