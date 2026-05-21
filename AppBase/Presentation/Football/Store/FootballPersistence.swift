//
//  FootballPersistence.swift
//  AppBase
//

import CoreGraphics
import Foundation

// MARK: - Snapshots

struct FootballMatchesSnapshot: Codable, Equatable {
    var matches: [FootballMatch]
    var currentMatchId: String?
}

struct FootballLineupsSnapshot: Codable, Equatable {
    var savedLineups: [FootballLineup]
    var currentLineup: FootballLineup
    var tacticalStrokes: [TacticalStroke]
    var strokeUndoStack: [[TacticalStroke]]
    var strokeRedoStack: [[TacticalStroke]]
    var tacticalLineOptions: TacticalLineOptions
    var pitchDisplayOptions: PitchDisplayOptions
}

// MARK: - CGPoint (used by lineup / match assignments)

extension CGPoint {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(CGFloat.self)
        let y = try container.decode(CGFloat.self)
        self.init(x: x, y: y)
    }
}
