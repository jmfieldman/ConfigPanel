//
//  TweakCoordinate.swift
//  Copyright © 2025 Jason Fieldman.
//

public struct TweakCoordinate: Hashable, Sendable {
    public struct Table: Hashable, Sendable {
        public let table: String
    }

    public struct Section: Hashable, Sendable {
        public let section: String
    }

    public struct Row: Hashable, Sendable {
        public let row: String
    }

    public let table: Table
    public let section: Section
    public let row: Row

    public init(_ table: Table, _ section: Section, _ row: Row) {
        self.table = table
        self.section = section
        self.row = row
    }
}
