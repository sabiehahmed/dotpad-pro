import Foundation

/// Seam for the future server sync layer. The local app already marks edited
/// dots `dirty` and carries an optional `remoteId`; a concrete implementation
/// will push dirty dots and reconcile remote changes. No network yet.
protocol SyncEngine {
    func pushDirty(_ dots: [Dot], content: (Dot) -> NSAttributedString) async throws
    func pull() async throws -> [Dot]
}

/// Default no-op engine used until the server phase lands.
struct NoopSyncEngine: SyncEngine {
    func pushDirty(_ dots: [Dot], content: (Dot) -> NSAttributedString) async throws {}
    func pull() async throws -> [Dot] { [] }
}
