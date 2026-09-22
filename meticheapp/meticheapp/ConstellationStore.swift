import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ConstellationStore {
    var hasCompletedOnboarding = false
    var displayName = ""
    var selectedGroupID: UUID?
    var groups: [FriendGroup]
    var people: [Person]
    var posts: [BulletinPost]
    var relationships: [Relationship]
    var events: [SocialEvent]
    let currentUserID: UUID

    init() {
        let sam = Person(id: UUID(), name: "Sam", handle: "@sam", initials: "S", color: .pink)
        let josh = Person(id: UUID(), name: "Josh", handle: "@josh", initials: "J", color: .indigo)
        let penelope = Person(id: UUID(), name: "Penelope", handle: "@penny", initials: "P", color: .orange)
        let alex = Person(id: UUID(), name: "Alex", handle: "@alex", initials: "A", color: .teal)
        let maya = Person(id: UUID(), name: "Maya", handle: "@maya", initials: "M", color: .green)
        let theo = Person(id: UUID(), name: "Theo", handle: "@theo", initials: "T", color: .red)
        let nina = Person(id: UUID(), name: "Nina", handle: "@nina", initials: "N", color: .cyan)
        let lena = Person(id: UUID(), name: "Lena", handle: "@lena", initials: "L", color: .yellow)
        let jordan = Person(id: UUID(), name: "Jordan", handle: "@jordan", initials: "J", color: .mint)
        let priya = Person(id: UUID(), name: "Priya", handle: "@priya", initials: "P", color: .purple)
        let marco = Person(id: UUID(), name: "Marco", handle: "@marco", initials: "M", color: .brown)
        let devon = Person(id: UUID(), name: "Devon", handle: "@devon", initials: "D", color: .blue)
        let group = FriendGroup(
            id: UUID(),
            name: "The Inner Circle",
            tagline: "For our eyes only",
            symbol: "sparkles",
            memberIDs: [sam.id, josh.id, penelope.id, alex.id]
        )
        let nyuGroup = FriendGroup(
            id: UUID(),
            name: "NYU After Dark",
            tagline: "Campus sightings and late-night lore",
            symbol: "building.columns.fill",
            memberIDs: [sam.id, penelope.id, maya.id, theo.id, lena.id]
        )
        let studioGroup = FriendGroup(
            id: UUID(),
            name: "Studio Crew",
            tagline: "Deadlines, openings, and everything between",
            symbol: "paintpalette.fill",
            memberIDs: [sam.id, alex.id, maya.id, nina.id, jordan.id, priya.id]
        )
        let coffeeGroup = FriendGroup(
            id: UUID(),
            name: "Common Ground Café",
            tagline: "The crew from our favorite third place",
            symbol: "cup.and.saucer.fill",
            memberIDs: [sam.id, josh.id, jordan.id, marco.id]
        )
        let rooftopEvent = FriendGroup(
            id: UUID(),
            name: "Maya’s Rooftop",
            tagline: "Saturday’s guest circle",
            symbol: "party.popper.fill",
            memberIDs: [sam.id, maya.id, theo.id, priya.id, devon.id],
            expiresAt: .now.addingTimeInterval(60 * 60 * 36),
            externalProvider: .partiful,
            externalURL: URL(string: "https://partiful.com/e/example")
        )

        people = [sam, josh, penelope, alex, maya, theo, nina, lena, jordan, priya, marco, devon]
        currentUserID = sam.id
        groups = [group, nyuGroup, studioGroup, coffeeGroup, rooftopEvent]
        selectedGroupID = group.id
        events = [
            SocialEvent(
                id: UUID(),
                title: "Inner Circle Dinner",
                startDate: .now.addingTimeInterval(60 * 60 * 28),
                endDate: .now.addingTimeInterval(60 * 60 * 31),
                locationName: "Avec River North",
                notes: "Penelope is allergic to shellfish. Ask for a table away from the bar.",
                groupID: group.id,
                attendeeIDs: [sam.id, josh.id, penelope.id, alex.id],
                checklist: [
                    EventChecklistItem(id: UUID(), title: "Confirm reservation", isComplete: true),
                    EventChecklistItem(id: UUID(), title: "Bring Josh’s camera", isComplete: false),
                    EventChecklistItem(id: UUID(), title: "Share parking details", isComplete: false)
                ],
                sourceName: "Constella"
            ),
            SocialEvent(
                id: UUID(),
                title: "Open Studio Night",
                startDate: .now.addingTimeInterval(60 * 60 * 76),
                endDate: .now.addingTimeInterval(60 * 60 * 80),
                locationName: "Brooklyn Studio",
                notes: "Bring one unfinished piece and invite one person the group should meet.",
                groupID: studioGroup.id,
                attendeeIDs: [sam.id, alex.id, maya.id, nina.id, jordan.id, priya.id],
                checklist: [
                    EventChecklistItem(id: UUID(), title: "Pick up sparkling water", isComplete: false),
                    EventChecklistItem(id: UUID(), title: "Prepare shared playlist", isComplete: true)
                ],
                sourceName: "Apple Calendar"
            ),
            SocialEvent(
                id: UUID(),
                title: "Maya’s Rooftop",
                startDate: .now.addingTimeInterval(60 * 60 * 36),
                endDate: .now.addingTimeInterval(60 * 60 * 41),
                locationName: "Lower East Side",
                notes: "Imported event. Exact address remains in the original invitation.",
                groupID: rooftopEvent.id,
                attendeeIDs: rooftopEvent.memberIDs,
                checklist: [
                    EventChecklistItem(id: UUID(), title: "Bring ice", isComplete: false),
                    EventChecklistItem(id: UUID(), title: "Add songs to the queue", isComplete: false)
                ],
                sourceName: "Partiful"
            ),
            SocialEvent(
                id: UUID(),
                title: "Coffee Walk",
                startDate: .now.addingTimeInterval(60 * 60 * 52),
                endDate: .now.addingTimeInterval(60 * 60 * 53),
                locationName: "Riverwalk",
                notes: "Casual morning walk. Text the circle if the weather changes.",
                groupID: coffeeGroup.id,
                attendeeIDs: [sam.id, josh.id, jordan.id],
                checklist: [],
                sourceName: "Google Calendar"
            )
        ]
        posts = [
            BulletinPost(
                id: UUID(),
                groupID: group.id,
                authorID: sam.id,
                body: "Friday plans moved to 8. Apparently there is more to this story…",
                createdAt: .now.addingTimeInterval(-900),
                isAnonymous: false,
                isPinned: true,
                locationName: "River North",
                reactions: 7,
                comments: [PostComment(id: UUID(), authorName: "Alex", body: "I need the full story.")],
                taggedPersonIDs: [josh.id]
            ),
            BulletinPost(
                id: UUID(),
                groupID: group.id,
                authorID: penelope.id,
                body: "Spotted: two familiar faces leaving brunch together. Draw your own conclusions.",
                createdAt: .now.addingTimeInterval(-3_600),
                isAnonymous: true,
                isPinned: false,
                locationName: "West Loop",
                reactions: 11,
                comments: [
                    PostComment(id: UUID(), authorName: "Josh", body: "I can reserve the table if we settle on a time."),
                    PostComment(id: UUID(), authorName: "Alex", body: "Adding this to the shared calendar now.")
                ],
                taggedPersonIDs: [josh.id, penelope.id]
            ),
            BulletinPost(
                id: UUID(),
                groupID: group.id,
                authorID: alex.id,
                body: "I made a shared album for last night. Add your photos before I send the recap tomorrow.",
                createdAt: .now.addingTimeInterval(-2_400),
                isAnonymous: false,
                isPinned: false,
                locationName: nil,
                reactions: 12,
                comments: [
                    PostComment(id: UUID(), authorName: "Sam", body: "Just added the good group shot."),
                    PostComment(id: UUID(), authorName: "Penelope", body: "Uploading mine after work!")
                ],
                taggedPersonIDs: [sam.id, josh.id, penelope.id]
            ),
            BulletinPost(
                id: UUID(),
                groupID: group.id,
                authorID: josh.id,
                body: "Anyone free for a quick coffee walk tomorrow morning? Thinking 9:30 near the river.",
                createdAt: .now.addingTimeInterval(-4_800),
                isAnonymous: false,
                isPinned: false,
                locationName: "Riverwalk",
                reactions: 6,
                comments: [
                    PostComment(id: UUID(), authorName: "Sam", body: "I’m in."),
                    PostComment(id: UUID(), authorName: "Alex", body: "Can join at 10!")
                ],
                taggedPersonIDs: []
            ),
            BulletinPost(
                id: UUID(),
                groupID: group.id,
                authorID: penelope.id,
                body: "Recommendation thread: drop one restaurant you would genuinely go back to this month.",
                createdAt: .now.addingTimeInterval(-9_600),
                isAnonymous: false,
                isPinned: false,
                locationName: "Chicago",
                reactions: 15,
                comments: [
                    PostComment(id: UUID(), authorName: "Josh", body: "The new noodle place on Clark."),
                    PostComment(id: UUID(), authorName: "Alex", body: "Still voting for our usual tapas spot."),
                    PostComment(id: UUID(), authorName: "Sam", body: "Saving all of these for Friday.")
                ],
                taggedPersonIDs: []
            ),
            BulletinPost(
                id: UUID(),
                groupID: nyuGroup.id,
                authorID: maya.id,
                body: "Penelope introduced Maya and Lena at the gallery opening. They already have brunch plans.",
                createdAt: .now.addingTimeInterval(-7_200),
                isAnonymous: false,
                isPinned: false,
                locationName: "West Town",
                reactions: 5,
                comments: [],
                taggedPersonIDs: [penelope.id, maya.id, lena.id]
            ),
            BulletinPost(
                id: UUID(),
                groupID: studioGroup.id,
                authorID: nina.id,
                body: "Open studio is Thursday. Bring one unfinished thing and one person you want us to meet.",
                createdAt: .now.addingTimeInterval(-10_800),
                isAnonymous: false,
                isPinned: true,
                locationName: "Brooklyn",
                reactions: 9,
                comments: [],
                taggedPersonIDs: [alex.id, jordan.id, priya.id]
            ),
            BulletinPost(
                id: UUID(),
                groupID: rooftopEvent.id,
                authorID: maya.id,
                body: "Rooftop details are live. Add songs to the shared queue and invite only people you know personally.",
                createdAt: .now.addingTimeInterval(-1_800),
                isAnonymous: false,
                isPinned: true,
                locationName: "Lower East Side",
                reactions: 14,
                comments: [],
                taggedPersonIDs: [theo.id, priya.id, devon.id]
            )
        ]
        relationships = [
            Relationship(
                id: UUID(),
                firstPersonID: sam.id,
                secondPersonID: josh.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: sam.id, otherPersonID: josh.id, status: .closeFriends, note: "Friends since freshman year.", visibility: .selectedGroup, updatedAt: .now.addingTimeInterval(-86_400)),
                    RelationshipPerspective(id: UUID(), authorID: josh.id, otherPersonID: sam.id, status: .closeFriends, note: "Sam always has my back.", visibility: .selectedGroup, updatedAt: .now.addingTimeInterval(-43_200))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: josh.id,
                secondPersonID: penelope.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: josh.id, otherPersonID: penelope.id, status: .friends, note: "We run in the same circles.", visibility: .selectedGroup, updatedAt: .now.addingTimeInterval(-172_800))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: sam.id,
                secondPersonID: penelope.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: sam.id, otherPersonID: penelope.id, status: .complicated, note: "We are taking some space.", visibility: .closeFriends, updatedAt: .now.addingTimeInterval(-7_200))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: sam.id,
                secondPersonID: alex.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: alex.id, otherPersonID: sam.id, status: .friends, note: "The calm one in every crisis.", visibility: .connections, updatedAt: .now.addingTimeInterval(-259_200))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: penelope.id,
                secondPersonID: maya.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: penelope.id, otherPersonID: maya.id, status: .closeFriends, note: "My first call for every last-minute plan.", visibility: .selectedGroup, updatedAt: .now.addingTimeInterval(-90_000)),
                    RelationshipPerspective(id: UUID(), authorID: maya.id, otherPersonID: penelope.id, status: .closeFriends, note: "She brought me into this whole circle.", visibility: .selectedGroup, updatedAt: .now.addingTimeInterval(-88_000))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: penelope.id,
                secondPersonID: theo.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: penelope.id, otherPersonID: theo.id, status: .friends, note: "We became friends through Maya.", visibility: .connections, updatedAt: .now.addingTimeInterval(-150_000))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: maya.id,
                secondPersonID: alex.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: maya.id, otherPersonID: alex.id, status: .friends, note: "Alex always knows how to smooth things over.", visibility: .selectedGroup, updatedAt: .now.addingTimeInterval(-210_000))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: theo.id,
                secondPersonID: josh.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: theo.id, otherPersonID: josh.id, status: .complicated, note: "We are civil now, but there is unresolved history.", visibility: .closeFriends, updatedAt: .now.addingTimeInterval(-18_000)),
                    RelationshipPerspective(id: UUID(), authorID: josh.id, otherPersonID: theo.id, status: .complicated, note: "Trust is still being rebuilt.", visibility: .closeFriends, updatedAt: .now.addingTimeInterval(-16_000))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: alex.id,
                secondPersonID: nina.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: alex.id, otherPersonID: nina.id, status: .closeFriends, note: "We work together and somehow still like each other.", visibility: .connections, updatedAt: .now.addingTimeInterval(-300_000))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: penelope.id,
                secondPersonID: lena.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: lena.id, otherPersonID: penelope.id, status: .friends, note: "New friends, but the energy is good.", visibility: .selectedGroup, updatedAt: .now.addingTimeInterval(-6_000))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: nina.id,
                secondPersonID: jordan.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: nina.id, otherPersonID: jordan.id, status: .closeFriends, note: "We survived our first launch together.", visibility: .connections, updatedAt: .now.addingTimeInterval(-120_000))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: priya.id,
                secondPersonID: maya.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: priya.id, otherPersonID: maya.id, status: .friends, note: "Met through the studio, now regular collaborators.", visibility: .connections, updatedAt: .now.addingTimeInterval(-70_000))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: jordan.id,
                secondPersonID: marco.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: jordan.id, otherPersonID: marco.id, status: .friends, note: "Our shifts always overlapped at Common Ground.", visibility: .connections, updatedAt: .now.addingTimeInterval(-190_000))
                ]
            ),
            Relationship(
                id: UUID(),
                firstPersonID: devon.id,
                secondPersonID: theo.id,
                perspectives: [
                    RelationshipPerspective(id: UUID(), authorID: devon.id, otherPersonID: theo.id, status: .friends, note: "We met at Maya’s last party.", visibility: .selectedGroup, updatedAt: .now.addingTimeInterval(-12_000))
                ]
            )
        ]
    }

    var selectedGroup: FriendGroup? {
        groups.first { $0.id == selectedGroupID }
    }

    var selectedGroupPosts: [BulletinPost] {
        guard let selectedGroupID else { return [] }
        return posts(for: selectedGroupID)
    }

    func posts(for groupID: UUID) -> [BulletinPost] {
        posts
            .filter { $0.groupID == groupID }
            .sorted {
                if $0.isPinned != $1.isPinned { return $0.isPinned }
                return $0.createdAt > $1.createdAt
            }
    }

    func group(withID id: UUID) -> FriendGroup? {
        groups.first { $0.id == id }
    }

    func createGroup(name: String, tagline: String) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else { return }
        let group = FriendGroup(
            id: UUID(),
            name: cleanedName,
            tagline: tagline.trimmingCharacters(in: .whitespacesAndNewlines),
            symbol: "sun.max.fill",
            memberIDs: [currentUserID]
        )
        groups.append(group)
        selectedGroupID = group.id
    }

    func importEvent(title: String, link: URL, endsAt: Date) {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTitle.isEmpty else { return }
        let provider = ExternalEventProvider.detect(from: link)
        let event = FriendGroup(
            id: UUID(),
            name: cleanedTitle,
            tagline: "Imported event circle",
            symbol: "party.popper.fill",
            memberIDs: [currentUserID],
            expiresAt: endsAt,
            externalProvider: provider,
            externalURL: link
        )
        groups.append(event)
        selectedGroupID = event.id
    }

    func completeOnboarding(name: String) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        displayName = cleanedName.isEmpty ? "New Insider" : cleanedName
        if let currentUserIndex = people.firstIndex(where: { $0.id == currentUserID }) {
            people[currentUserIndex].name = displayName
            people[currentUserIndex].initials = String(displayName.prefix(1)).uppercased()
        }
        hasCompletedOnboarding = true
    }

    func person(withID id: UUID) -> Person? {
        people.first { $0.id == id }
    }

    func relationships(for personID: UUID) -> [Relationship] {
        relationships.filter { $0.includes(personID) }
    }

    func posts(about personID: UUID) -> [BulletinPost] {
        selectedGroupPosts.filter { $0.taggedPersonIDs.contains(personID) }
    }

    func posts(about personID: UUID, in groupID: UUID) -> [BulletinPost] {
        posts(for: groupID).filter { $0.taggedPersonIDs.contains(personID) }
    }

    func setAvatarData(_ data: Data?, for personID: UUID) {
        guard let personIndex = people.firstIndex(where: { $0.id == personID }) else { return }
        people[personIndex].avatarData = data
    }

    func savePerspective(
        about otherPersonID: UUID,
        status: Relationship.Status,
        note: String,
        visibility: RelationshipPerspective.Visibility
    ) {
        let cleanedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if let relationshipIndex = relationships.firstIndex(where: {
            $0.includes(currentUserID) && $0.includes(otherPersonID)
        }) {
            if let perspectiveIndex = relationships[relationshipIndex].perspectives.firstIndex(where: {
                $0.authorID == currentUserID
            }) {
                relationships[relationshipIndex].perspectives[perspectiveIndex].status = status
                relationships[relationshipIndex].perspectives[perspectiveIndex].note = cleanedNote
                relationships[relationshipIndex].perspectives[perspectiveIndex].visibility = visibility
                relationships[relationshipIndex].perspectives[perspectiveIndex].updatedAt = .now
            } else {
                relationships[relationshipIndex].perspectives.append(
                    RelationshipPerspective(
                        id: UUID(),
                        authorID: currentUserID,
                        otherPersonID: otherPersonID,
                        status: status,
                        note: cleanedNote,
                        visibility: visibility,
                        updatedAt: .now
                    )
                )
            }
        } else {
            relationships.append(
                Relationship(
                    id: UUID(),
                    firstPersonID: currentUserID,
                    secondPersonID: otherPersonID,
                    perspectives: [
                        RelationshipPerspective(
                            id: UUID(),
                            authorID: currentUserID,
                            otherPersonID: otherPersonID,
                            status: status,
                            note: cleanedNote,
                            visibility: visibility,
                            updatedAt: .now
                        )
                    ]
                )
            )
        }
    }

    func addPost(
        body: String,
        isAnonymous: Bool,
        locationName: String?,
        taggedPersonID: UUID? = nil,
        groupID destinationGroupID: UUID? = nil
    ) {
        guard let groupID = destinationGroupID ?? selectedGroupID,
              let authorID = people.first?.id else { return }
        let cleanedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedBody.isEmpty else { return }

        posts.append(
            BulletinPost(
                id: UUID(),
                groupID: groupID,
                authorID: authorID,
                body: cleanedBody,
                createdAt: .now,
                isAnonymous: isAnonymous,
                isPinned: false,
                locationName: locationName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                reactions: 0,
                comments: [],
                taggedPersonIDs: taggedPersonID.map { [$0] } ?? []
            )
        )
    }

    func toggleReaction(for postID: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].reactions += 1
    }

    func togglePin(for postID: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].isPinned.toggle()
    }

    func addComment(_ body: String, to postID: UUID) {
        let cleanedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedBody.isEmpty,
              let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].comments.append(
            PostComment(id: UUID(), authorName: displayName, body: cleanedBody)
        )
    }

    var upcomingEvents: [SocialEvent] {
        events.filter { $0.endDate >= .now }.sorted { $0.startDate < $1.startDate }
    }

    func addEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        locationName: String,
        notes: String,
        groupID: UUID?,
        attendeeIDs: [UUID]
    ) {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTitle.isEmpty else { return }
        events.append(
            SocialEvent(
                id: UUID(),
                title: cleanedTitle,
                startDate: startDate,
                endDate: max(endDate, startDate),
                locationName: locationName.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                groupID: groupID,
                attendeeIDs: attendeeIDs,
                checklist: [],
                sourceName: "Constella"
            )
        )
    }

    func deleteEvent(_ eventID: UUID) {
        events.removeAll { $0.id == eventID }
    }

    func toggleChecklistItem(_ itemID: UUID, in eventID: UUID) {
        guard let eventIndex = events.firstIndex(where: { $0.id == eventID }),
              let itemIndex = events[eventIndex].checklist.firstIndex(where: { $0.id == itemID }) else { return }
        events[eventIndex].checklist[itemIndex].isComplete.toggle()
    }

    func addChecklistItem(_ title: String, to eventID: UUID) {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTitle.isEmpty,
              let eventIndex = events.firstIndex(where: { $0.id == eventID }) else { return }
        events[eventIndex].checklist.append(EventChecklistItem(id: UUID(), title: cleanedTitle, isComplete: false))
    }

    func toggleAttendee(_ personID: UUID, in eventID: UUID) {
        guard let eventIndex = events.firstIndex(where: { $0.id == eventID }) else { return }
        if let attendeeIndex = events[eventIndex].attendeeIDs.firstIndex(of: personID) {
            events[eventIndex].attendeeIDs.remove(at: attendeeIndex)
        } else {
            events[eventIndex].attendeeIDs.append(personID)
        }
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
