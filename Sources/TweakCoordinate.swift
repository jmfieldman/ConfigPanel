//
//  TweakCoordinate.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx

public struct TweakCoordinate: Hashable, Sendable {
    public struct Table: Hashable, Sendable {
        public let table: String
    }

    public struct Section: Hashable, Sendable {
        public let section: String
    }

    public let table: Table
    public let section: Section
    public let row: String

    public init(_ table: Table, _ section: Section, _ row: String) {
        self.table = table
        self.section = section
        self.row = row
    }

    public var propertyKey: PersistentPropertyKey {
        PersistentPropertyKey(key: "\(table.table).\(section.section).\(row)")
    }
}
