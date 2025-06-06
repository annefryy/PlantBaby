import Foundation
import UIKit // Import UIKit for UIImage
import SwiftUI // Import SwiftUI for UIImage

struct CareEvent: Identifiable, Codable, CaseIterable, CustomStringConvertible, Hashable {
    let id: UUID
    let type: CareType
    let date: Date
    var note: String?

    init(id: UUID = UUID(), type: CareType, date: Date, note: String? = nil) {
        self.id = id
        self.type = type
        self.date = date
        self.note = note
    }

    var description: String {
        return self.rawValue
    }

    var rawValue: String {
        switch self {
        case .watering: return "Watering"
        case .fertilizing: return "Fertilizing"
        case .pruning: return "Pruning"
        case .repotting: return "Repotting"
        }
    }

    // Add hashValue for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(date)
        hasher.combine(note)
    }

    // Add static var allCases for CaseIterable conformance
    static var allCases: [CareEvent.CareType] = [.watering, .fertilizing, .pruning, .repotting]
}

enum CareType: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
    case watering
    case fertilizing
    case pruning
    case repotting

    var id: String { self.rawValue }
    var description: String { self.rawValue.capitalized }
}

struct Plant: Identifiable, Codable {
    let id: UUID
    var name: String
    var scientificName: String?
    var description: String?
    var age: String?
    var imageUrl: String?
    var imagePath: String?
    var temp: String?
    var light: String?
    var humidity: String?
    var fertilizer: String?
    var notes: String?
    var careHistory: [CareEvent]
    var nextCareDate: Date?
    var lastWatered: Date?
    var lastFertilized: Date?
    var lastPruned: Date?
    var lastRepotted: Date?

    var uiImage: UIImage? {
        if let path = imagePath, let uiImage = UIImage(contentsOfFile: path) {
            return uiImage
        } else if let urlString = imageUrl, let url = URL(string: urlString), urlString.hasPrefix("http") {
            return nil // Async loading handles web URLs
        } else if let urlString = imageUrl {
            return UIImage(named: urlString)
        }
        return nil
    }

    init(
        id: UUID = UUID(),
        name: String,
        scientificName: String? = nil,
        description: String? = nil,
        age: String? = nil,
        imageUrl: String? = nil,
        imagePath: String? = nil,
        temp: String? = nil,
        light: String? = nil,
        humidity: String? = nil,
        fertilizer: String? = nil,
        notes: String? = nil,
        careHistory: [CareEvent] = [],
        nextCareDate: Date? = nil,
        lastWatered: Date? = nil,
        lastFertilized: Date? = nil,
        lastPruned: Date? = nil,
        lastRepotted: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.scientificName = scientificName
        self.description = description
        self.age = age
        self.imageUrl = imageUrl
        self.imagePath = imagePath
        self.temp = temp
        self.light = light
        self.humidity = humidity
        self.fertilizer = fertilizer
        self.notes = notes
        self.careHistory = careHistory
        self.nextCareDate = nextCareDate
        self.lastWatered = lastWatered
        self.lastFertilized = lastFertilized
        self.lastPruned = lastPruned
        self.lastRepotted = lastRepotted
    }
    
    // Helper method to get the last care date for a specific type
    func lastCareDate(for type: CareType) -> Date? {
        switch type {
        case .watering: return lastWatered
        case .fertilizing: return lastFertilized
        case .pruning: return lastPruned
        case .repotting: return lastRepotted
        }
    }
    
    // Helper method to get the next care date based on care type
    func nextCareDate(for type: CareType) -> Date? {
        guard let lastDate = lastCareDate(for: type) else { return nil }
        
        let calendar = Calendar.current
        switch type {
        case .watering:
            return calendar.date(byAdding: .day, value: 7, to: lastDate) // Example: water every 7 days
        case .fertilizing:
            return calendar.date(byAdding: .month, value: 1, to: lastDate) // Example: fertilize monthly
        case .pruning:
            return calendar.date(byAdding: .month, value: 3, to: lastDate) // Example: prune every 3 months
        case .repotting:
            return calendar.date(byAdding: .year, value: 1, to: lastDate) // Example: repot yearly
        }
    }
}

// Image Saving Utility
extension URL {
    static var documentsDirectory: URL {
        // Find the documents directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension UIImage {
    func saveToDocuments(withName name: String) -> String? {
        guard let data = self.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = URL.documentsDirectory.appendingPathComponent("\(name)-\(UUID().uuidString).jpg")
        do {
            try data.write(to: filename)
            return filename.lastPathComponent // Return only the file name to store in the model
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
} 