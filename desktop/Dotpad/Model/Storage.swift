import AppKit

/// File IO seam: reads/writes `index.json` and per-dot content files under
/// Application Support. All writes are atomic. This is the single boundary a
/// future `SyncEngine` will sit beside.
struct Storage {
    struct Index: Codable {
        var version: Int
        var dots: [Dot]
        var activeDotId: UUID?
    }

    let baseURL: URL
    private let dotsURL: URL
    private let indexURL: URL
    private let fm = FileManager.default

    init(baseURL: URL? = nil) {
        let root = baseURL ?? Storage.defaultBaseURL()
        self.baseURL = root
        self.dotsURL = root.appendingPathComponent("dots", isDirectory: true)
        self.indexURL = root.appendingPathComponent("index.json")
        try? fm.createDirectory(at: dotsURL, withIntermediateDirectories: true)
    }

    static func defaultBaseURL() -> URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent("Dotpad", isDirectory: true)
    }

    // MARK: Index

    func loadIndex() -> Index? {
        guard let data = try? Data(contentsOf: indexURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(Index.self, from: data)
    }

    func saveIndex(_ index: Index) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(index) else { return }
        atomicWrite(data, to: indexURL)
    }

    // MARK: Content

    func loadContent(for dot: Dot) -> NSAttributedString {
        let url = dotsURL.appendingPathComponent(dot.fileName)
        guard let data = try? Data(contentsOf: url) else { return NSAttributedString() }
        switch dot.mode {
        case .rich:
            let opts: [NSAttributedString.DocumentReadingOptionKey: Any] =
                [.documentType: NSAttributedString.DocumentType.rtf]
            return (try? NSAttributedString(data: data, options: opts, documentAttributes: nil))
                ?? NSAttributedString()
        case .plain:
            let text = String(data: data, encoding: .utf8) ?? ""
            return NSAttributedString(string: text)
        }
    }

    func saveContent(_ attributed: NSAttributedString, for dot: Dot) {
        let url = dotsURL.appendingPathComponent(dot.fileName)
        switch dot.mode {
        case .rich:
            let range = NSRange(location: 0, length: attributed.length)
            let opts: [NSAttributedString.DocumentAttributeKey: Any] =
                [.documentType: NSAttributedString.DocumentType.rtf]
            guard let data = try? attributed.data(from: range, documentAttributes: opts) else { return }
            atomicWrite(data, to: url)
        case .plain:
            let data = Data(attributed.string.utf8)
            atomicWrite(data, to: url)
        }
    }

    func deleteContent(for dot: Dot) {
        let url = dotsURL.appendingPathComponent(dot.fileName)
        try? fm.removeItem(at: url)
    }

    // MARK: Atomic write

    private func atomicWrite(_ data: Data, to url: URL) {
        let tmp = url.deletingLastPathComponent()
            .appendingPathComponent(".\(url.lastPathComponent).tmp")
        do {
            try data.write(to: tmp, options: .atomic)
            _ = try? fm.replaceItemAt(url, withItemAt: tmp)
        } catch {
            try? data.write(to: url, options: .atomic)
        }
    }
}
