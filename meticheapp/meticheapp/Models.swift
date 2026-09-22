import Foundation
import SwiftUI

enum ExternalEventProvider: String, CaseIterable, Identifiable {
    case partiful = "Partiful"
    case appleInvites = "Apple Invites"
    case eventbrite = "Eventbrite"
    case dice = "DICE"
    case other = "External event"

    var id: Self { self }

    static func detect(from url: URL) -> ExternalEventProvider {
        let host = url.host()?.lowercased() ?? ""
        if host.contains("partiful") { return .partiful }
        if host.contains("eventbrite") { return .eventbrite }
        if host.contains("dice.fm") { return .dice }
        if host.contains("icloud.com") || host.contains("apple.com") { return .appleInvites }
        return .other
    }
}

struct Person: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var handle: String
    var initials: String
    var color: Color
    var avatarData: Data? = nil
}

struct FriendGroup: Identifiable, Equatable {
    let id: UUID
    var name: String
    var tagline: String
    var symbol: String
    var memberIDs: [UUID]
    var expiresAt: Date? = nil
    var externalProvider: ExternalEventProvider? = nil
    var externalURL: URL? = nil

    var isTemporary: Bool {
        guard let expiresAt else { return false }
        return expiresAt > .now
    }
}

struct BulletinPost: Identifiable, Equatable {
    let id: UUID
    let groupID: UUID
    let authorID: UUID
    var body: String
    var createdAt: Date
    var isAnonymous: Bool
    var isPinned: Bool
    var locationName: String?
    var reactions: Int
    var comments: [PostComment]
    var taggedPersonIDs: [UUID] = []
}

struct PostComment: Identifiable, Equatable {
    let id: UUID
    let authorName: String
    let body: String
}

struct SocialEvent: Identifiable, Equatable {
    let id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var locationName: String?
    var notes: String
    var groupID: UUID?
    var attendeeIDs: [UUID]
    var checklist: [EventChecklistItem]
    var sourceName: String
}

struct EventChecklistItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isComplete: Bool
}

struct Relationship: Identifiable, Equatable {
    enum Status: String, CaseIterable, Identifiable {
        case closeFriends = "Close friends"
        case friends = "Friends"
        case complicated = "Complicated"

        var id: Self { self }

        var color: Color {
            switch self {
            case .closeFriends: .green
            case .friends: .blue
            case .complicated: .orange
            }
        }
    }

    let id: UUID
    let firstPersonID: UUID
    let secondPersonID: UUID
    var perspectives: [RelationshipPerspective]

    var status: Status {
        perspectives.first?.status ?? .friends
    }

    var note: String? {
        perspectives.first?.note
    }

    var isConfirmed: Bool {
        Set(perspectives.map(\.authorID)).count > 1
    }

    func includes(_ personID: UUID) -> Bool {
        firstPersonID == personID || secondPersonID == personID
    }

    func otherPersonID(than personID: UUID) -> UUID? {
        if firstPersonID == personID { return secondPersonID }
        if secondPersonID == personID { return firstPersonID }
        return nil
    }
}

struct RelationshipPerspective: Identifiable, Equatable {
    enum Visibility: String, CaseIterable, Identifiable {
        case onlyMe = "Only me"
        case closeFriends = "Close friends"
        case selectedGroup = "The Inner Circle"
        case connections = "My connections"

        var id: Self { self }
    }

    let id: UUID
    let authorID: UUID
    let otherPersonID: UUID
    var status: Relationship.Status
    var note: String
    var visibility: Visibility
    var updatedAt: Date
}
