import Foundation
import SwiftUI

// MARK: - Priority Level Definition
enum PriorityLevel: String, CaseIterable, Codable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"

    var displayText: String {
        return self.rawValue
    }

    var accentColor: Color {
        switch self {
        case .high:
            return Color(red: 0.95, green: 0.33, blue: 0.38) // Rose Red
        case .normal:
            return Color(red: 0.98, green: 0.58, blue: 0.20) // Warm Amber
        case .low:
            return Color(red: 0.30, green: 0.65, blue: 0.95) // Soft Sky Blue
        }
    }

    var symbol: String {
        switch self {
        case .high: return "exclamationmark.3"
        case .normal: return "exclamationmark.2"
        case .low: return "exclamationmark.1"
        }
    }
}

// MARK: - Core Todo Record
struct TodoRecord: Identifiable, Codable, Equatable {
    var id: String?
    var title: String
    var descriptionText: String
    var isDone: Bool
    var priority: PriorityLevel
    var dateCreated: Date
    var creatorId: String

    init(
        id: String? = nil,
        title: String,
        descriptionText: String = "",
        isDone: Bool = false,
        priority: PriorityLevel = .normal,
        dateCreated: Date = Date(),
        creatorId: String
    ) {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.isDone = isDone
        self.priority = priority
        self.dateCreated = dateCreated
        self.creatorId = creatorId
    }

    // Parse from Firestore document snapshot
    init?(docId: String, data: [String: Any]) {
        guard let title = data["title"] as? String,
              let creatorId = data["creatorId"] as? String else {
            return nil
        }

        self.id = docId
        self.title = title
        self.descriptionText = data["descriptionText"] as? String ?? ""
        self.isDone = data["isDone"] as? Bool ?? false

        if let rawPriority = data["priority"] as? String,
           let parsedPriority = PriorityLevel(rawValue: rawPriority) {
            self.priority = parsedPriority
        } else {
            self.priority = .normal
        }

        if let epoch = data["dateCreated"] as? TimeInterval {
            self.dateCreated = Date(timeIntervalSince1970: epoch)
        } else {
            self.dateCreated = Date()
        }

        self.creatorId = creatorId
    }

    // Serialize to Firestore map payload
    func asDictionary() -> [String: Any] {
        return [
            "title": title,
            "descriptionText": descriptionText,
            "isDone": isDone,
            "priority": priority.rawValue,
            "dateCreated": dateCreated.timeIntervalSince1970,
            "creatorId": creatorId
        ]
    }
}
