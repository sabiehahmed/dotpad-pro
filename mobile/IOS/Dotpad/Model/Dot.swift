import Foundation

/// Metadata for a single note "dot". Content lives in a sibling file
/// (`dots/<id>.rtf` or `.txt`); this struct is what `index.json` stores.
struct Dot: Identifiable, Codable, Equatable {
    let id: UUID
    var order: Int
    var colorHex: String
    var mode: TextMode
    var updatedAt: Date

    var remoteId: String?
    var dirty: Bool

    init(
        id: UUID = UUID(),
        order: Int,
        colorHex: String,
        mode: TextMode = .rich,
        updatedAt: Date = Date(),
        remoteId: String? = nil,
        dirty: Bool = false
    ) {
        self.id = id
        self.order = order
        self.colorHex = colorHex
        self.mode = mode
        self.updatedAt = updatedAt
        self.remoteId = remoteId
        self.dirty = dirty
    }

    var fileName: String { "\(id.uuidString).\(mode.fileExtension)" }
}
