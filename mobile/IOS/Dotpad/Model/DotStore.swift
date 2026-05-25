import UIKit
import Combine

struct DocStats: Equatable {
    var lines: Int
    var words: Int
    var characters: Int
    static let zero = DocStats(lines: 0, words: 0, characters: 0)
}

/// Central state: the ordered dots, the active selection, the active dot's
/// content, and debounced persistence.
final class DotStore: ObservableObject {
    @Published private(set) var dots: [Dot] = []
    @Published private(set) var activeDotId: UUID?
    @Published private(set) var stats: DocStats = .zero
    @Published private(set) var lastSaved: Date?

    /// Active dot's content. The editor reads this on dot-switch and writes
    /// back through `updateActiveContent`.
    private(set) var activeContent = NSAttributedString()

    private let storage: Storage
    private var saveWorkItem: DispatchWorkItem?
    private let saveDelay: TimeInterval = 0.4

    /// Tot's seven seed colors, then the palette cycles for added dots.
    static let palette = [
        "#F2C94C", "#F2994A", "#EB5757", "#9B51E0",
        "#2D9CDB", "#56CCF2", "#9AA0A6",
    ]

    init(storage: Storage = Storage()) {
        self.storage = storage
        load()
    }

    var activeDot: Dot? { dots.first { $0.id == activeDotId } }

    // MARK: Load / seed

    private func load() {
        if let index = storage.loadIndex(), !index.dots.isEmpty {
            dots = index.dots.sorted { $0.order < $1.order }
            activeDotId = index.activeDotId ?? dots.first?.id
        } else {
            seed()
        }
        loadActiveContent()
    }

    private func seed() {
        dots = (0..<7).map { i in
            Dot(order: i, colorHex: Self.palette[i % Self.palette.count])
        }
        activeDotId = dots.first?.id
        persistIndex()
    }

    private func loadActiveContent() {
        guard let dot = activeDot else { activeContent = NSAttributedString(); recomputeStats(); return }
        activeContent = storage.loadContent(for: dot)
        recomputeStats()
    }

    /// Plain-text preview for an inactive dot (used by the paged carousel).
    func previewText(for dot: Dot) -> String {
        storage.loadContent(for: dot).string
    }

    // MARK: Selection

    func select(_ id: UUID) {
        guard id != activeDotId else { return }
        flushSave()
        activeDotId = id
        persistIndex()
        loadActiveContent()
        objectWillChange.send()
    }

    func selectIndex(_ index: Int) {
        guard dots.indices.contains(index) else { return }
        select(dots[index].id)
    }

    // MARK: Mutations

    @discardableResult
    func addDot() -> Dot {
        flushSave()
        let order = (dots.map(\.order).max() ?? -1) + 1
        let dot = Dot(order: order, colorHex: Self.palette[order % Self.palette.count])
        dots.append(dot)
        activeDotId = dot.id
        activeContent = NSAttributedString()
        recomputeStats()
        persistIndex()
        return dot
    }

    func removeDot(_ id: UUID) {
        guard dots.count > 1, let dot = dots.first(where: { $0.id == id }) else { return }
        storage.deleteContent(for: dot)
        dots.removeAll { $0.id == id }
        reorderInPlace()
        if activeDotId == id {
            activeDotId = dots.first?.id
            loadActiveContent()
        }
        persistIndex()
    }

    func move(from source: Int, to destination: Int) {
        guard dots.indices.contains(source) else { return }
        var clamped = destination
        if clamped > source { clamped -= 1 }
        clamped = max(0, min(clamped, dots.count - 1))
        let dot = dots.remove(at: source)
        dots.insert(dot, at: clamped)
        reorderInPlace()
        persistIndex()
    }

    func setMode(_ mode: TextMode, for id: UUID) {
        guard let i = dots.firstIndex(where: { $0.id == id }), dots[i].mode != mode else { return }
        let old = dots[i]
        let content = (id == activeDotId) ? activeContent : storage.loadContent(for: old)
        storage.deleteContent(for: old)
        dots[i].mode = mode
        dots[i].updatedAt = Date()
        storage.saveContent(content, for: dots[i])
        persistIndex()
        if id == activeDotId { objectWillChange.send() }
    }

    private func reorderInPlace() {
        for i in dots.indices { dots[i].order = i }
    }

    // MARK: Editing

    func updateActiveContent(_ attributed: NSAttributedString) {
        activeContent = attributed
        recomputeStats()
        scheduleSave()
    }

    private func recomputeStats() {
        stats = Self.computeStats(activeContent.string)
    }

    static func computeStats(_ text: String) -> DocStats {
        let chars = text.count
        let words = text.split { $0 == " " || $0 == "\n" || $0 == "\t" }.count
        let lines = text.isEmpty ? 0 : text.components(separatedBy: "\n").count
        return DocStats(lines: lines, words: words, characters: chars)
    }

    // MARK: Persistence

    private func scheduleSave() {
        saveWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.flushSave() }
        saveWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + saveDelay, execute: work)
    }

    func flushSave() {
        saveWorkItem?.cancel()
        saveWorkItem = nil
        guard let i = dots.firstIndex(where: { $0.id == activeDotId }) else { return }
        dots[i].updatedAt = Date()
        dots[i].dirty = true
        storage.saveContent(activeContent, for: dots[i])
        lastSaved = Date()
        persistIndex()
    }

    private func persistIndex() {
        let index = Storage.Index(version: 1, dots: dots, activeDotId: activeDotId)
        storage.saveIndex(index)
    }
}
