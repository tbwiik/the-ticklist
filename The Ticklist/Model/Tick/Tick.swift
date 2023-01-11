//
//  Tick.swift
//  The Ticklist
//
//  Created by Torbjørn Wiik on 05/01/2023.
//

import Foundation

struct Tick: Identifiable, Codable, Equatable {
    
    let id: UUID
    let name: String
    let region: String
    var dicipline: Dicipline
    var grade: String //Consider changing to own struct later
    var rating: Int
    var ascents: [Ascent]
    var logItems: [LogItem]
    
    init(id: UUID = UUID(), name: String, region: String, dicipline: Dicipline, grade: String, rating: Int, ascents: [Ascent], logItems: [LogItem]) {
        self.id = id
        self.name = name
        self.region = region
        self.dicipline = dicipline
        self.grade = grade
        self.rating = rating
        self.ascents = ascents
        self.logItems = logItems
    }
    
    /**
     Compares on name, region and dicipline

     - Compares values directly
     - CaseSensitive
     */
    func equals(tickToCompare:Tick) -> Bool {
        let equalNames = name == tickToCompare.name
        let equalRegions = region == tickToCompare.region
        let equalDicipline = dicipline == tickToCompare.dicipline
        return equalNames && equalRegions && equalDicipline
    }
    
}

///Date formatting
extension Date{
    func formatDate() -> String {
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
}
