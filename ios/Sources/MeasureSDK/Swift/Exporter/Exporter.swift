//
//  Exporter.swift
//  MeasureSDK
//
//  Created by Adwin Ross on 17/10/24.
//

import Foundation

protocol Exporter {
    func export()
}

/// Local-only exporter.
///
/// This SDK never uploads data to a remote server. All collected monitors (events and spans) are
/// kept in the local database (bounded by the configured max disk usage) and printed to the
/// console as they are collected. This class only logs a short summary of how many monitors are
/// retained so developers know where the data lives.
final class BaseExporter: Exporter {
    private let logger: Logger
    private let dispatchQueue: DispatchQueue
    private let eventStore: EventStore
    private let spanStore: SpanStore
    private let isExporting = AtomicBool(false)

    init(logger: Logger,
         dispatchQueue: DispatchQueue,
         eventStore: EventStore,
         spanStore: SpanStore) {
        self.logger = logger
        self.dispatchQueue = dispatchQueue
        self.eventStore = eventStore
        self.spanStore = spanStore
    }

    func export() {
        var started = false
        isExporting.setTrueIfFalse { started = true }
        guard started else { return }

        dispatchQueue.async { [weak self] in
            guard let self else { return }
            let events = self.eventStore.getEventsCount()
            let spans = self.spanStore.getSpansCount()
            MonitorPrinter.line("Local mode: not uploading. Retained in DB -> \(events) events, \(spans) spans.")
            self.isExporting.set(false)
        }
    }
}
