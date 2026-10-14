import SwiftUI
import MapKit

// MARK: - Models

struct Place: Identifiable {
    let id: String
    let name: String
    let category: String
    let rating: Double
    let reviewCount: Int
    let friendCount: Int
    let symbol: String
    let color: Color
    let coordinate: CLLocationCoordinate2D
    let reviews: [CommunityReview]

    func matches(_ query: String) -> Bool {
        let value = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.localizedCaseInsensitiveContains(value)
            || category.localizedCaseInsensitiveContains(value)
    }

    static let samples = [
        Place(
            id: "central-park",
            name: "Central Park",
            category: "Landmark · Park",
            rating: 4.9,
            reviewCount: 18_420,
            friendCount: 24,
            symbol: "leaf.fill",
            color: .green,
            coordinate: CLLocationCoordinate2D(latitude: 40.7829, longitude: -73.9654),
            reviews: CommunityReview.feed
        ),
        Place(
            id: "metropolitan-museum",
            name: "The Metropolitan Museum of Art",
            category: "Landmark · Museum",
            rating: 4.8,
            reviewCount: 12_806,
            friendCount: 17,
            symbol: "building.columns.fill",
            color: .pink,
            coordinate: CLLocationCoordinate2D(latitude: 40.7794, longitude: -73.9632),
            reviews: Array(CommunityReview.feed.prefix(2))
        ),
        Place(
            id: "empire-state",
            name: "Empire State Building",
            category: "Landmark · Observation Deck",
            rating: 4.7,
            reviewCount: 9_742,
            friendCount: 11,
            symbol: "building.2.fill",
            color: .blue,
            coordinate: CLLocationCoordinate2D(latitude: 40.7484, longitude: -73.9857),
            reviews: Array(CommunityReview.feed.suffix(2))
        ),
        Place(
            id: "statue-of-liberty",
            name: "Statue of Liberty",
            category: "Landmark · Monument",
            rating: 4.8,
            reviewCount: 15_310,
            friendCount: 8,
            symbol: "sparkles",
            color: .mint,
            coordinate: CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0445),
            reviews: CommunityReview.feed
        ),
        Place(
            id: "katzs-deli",
            name: "Katz’s Delicatessen",
            category: "Restaurant · Deli",
            rating: 4.6,
            reviewCount: 8_913,
            friendCount: 14,
            symbol: "fork.knife",
            color: .orange,
            coordinate: CLLocationCoordinate2D(latitude: 40.7223, longitude: -73.9874),
            reviews: CommunityReview.feed
        ),
        Place(
            id: "le-bernardin",
            name: "Le Bernardin",
            category: "Restaurant · French Seafood",
            rating: 4.8,
            reviewCount: 3_218,
            friendCount: 5,
            symbol: "fork.knife.circle.fill",
            color: .indigo,
            coordinate: CLLocationCoordinate2D(latitude: 40.7616, longitude: -73.9817),
            reviews: Array(CommunityReview.feed.prefix(2))
        )
    ]
}

struct CommunityReview: Identifiable {
    let id: String
    let author: String
    let initials: String
    let placeName: String
    let rating: Int
    let text: String
    let relativeDate: String
    let isFriend: Bool
    let color: Color

    static let feed = [
        CommunityReview(
            id: "review-1",
            author: "Maya R.",
            initials: "MR",
            placeName: "Central Park",
            rating: 5,
            text: "The Reservoir loop at sunrise is beautiful and much quieter. Save time for the Conservatory Garden, too.",
            relativeDate: "2d ago",
            isFriend: true,
            color: .purple
        ),
        CommunityReview(
            id: "review-2",
            author: "CityNomad",
            initials: "CN",
            placeName: "The Metropolitan Museum of Art",
            rating: 4,
            text: "Give yourself at least three hours. The Egyptian collection is extraordinary, and the rooftop view is worth the wait.",
            relativeDate: "5d ago",
            isFriend: false,
            color: .indigo
        ),
        CommunityReview(
            id: "review-3",
            author: "Jordan Lee",
            initials: "JL",
            placeName: "Katz’s Delicatessen",
            rating: 5,
            text: "The pastrami is absolutely the order. The line moves faster than it looks, and sharing one sandwich is plenty.",
            relativeDate: "1w ago",
            isFriend: true,
            color: .teal
        )
    ]
}

enum ReviewVisibility: String, CaseIterable, Identifiable {
    case everyone
    case friends
    case onlyMe

    var id: String { rawValue }

    var title: String {
        switch self {
        case .everyone: "Everyone"
        case .friends: "Friends Only"
        case .onlyMe: "Only Me"
        }
    }

    var symbol: String {
        switch self {
        case .everyone: "globe.americas.fill"
        case .friends: "person.2.fill"
        case .onlyMe: "lock.fill"
        }
    }
}

enum CommunityFilter: String, CaseIterable, Identifiable {
    case friends
    case nearby
    case following

    var id: String { rawValue }

    var title: String {
        switch self {
        case .friends: "Friends"
        case .nearby: "Nearby"
        case .following: "Following"
        }
    }
}

enum FindCategory: String, CaseIterable, Identifiable {
    case people
    case devices
    case items
    case me

    var id: String { rawValue }

    static let mapFilterCases: [FindCategory] = [.people, .devices, .items]

    var title: String {
        switch self {
        case .people: "People"
        case .devices: "Devices"
        case .items: "Items"
        case .me: "Me"
        }
    }

    var symbol: String {
        switch self {
        case .people: "person.2.fill"
        case .devices: "macbook.and.iphone"
        case .items: "airtag.fill"
        case .me: "location.fill"
        }
    }

    var heading: String {
        switch self {
        case .people: "People you share with"
        case .devices: "Your Apple devices"
        case .items: "Items in the Find My network"
        case .me: "Your location"
        }
    }

    var subtitle: String {
        switch self {
        case .people: "Location sharing stays in your control"
        case .devices: "Signed in with your Apple Account"
        case .items: "Protected with end-to-end encryption"
        case .me: "Choose how your location is shared"
        }
    }
}

struct TrackedItem: Identifiable {
    let id: String
    let name: String
    let status: String
    let initials: String
    let symbol: String
    let color: Color
    let category: FindCategory
    let coordinate: CLLocationCoordinate2D

    static let samples = [
        TrackedItem(
            id: "maya",
            name: "Maya",
            status: "Live · 2 min away",
            initials: "MR",
            symbol: "person.fill",
            color: .purple,
            category: .people,
            coordinate: CLLocationCoordinate2D(latitude: 40.7587, longitude: -73.9787)
        ),
        TrackedItem(
            id: "jordan",
            name: "Jordan",
            status: "Home · Now",
            initials: "JL",
            symbol: "person.fill",
            color: .teal,
            category: .people,
            coordinate: CLLocationCoordinate2D(latitude: 40.7411, longitude: -73.9897)
        ),
        TrackedItem(
            id: "iphone",
            name: "Ricardo’s iPhone",
            status: "With You",
            initials: "",
            symbol: "iphone",
            color: .blue,
            category: .devices,
            coordinate: CLLocationCoordinate2D(latitude: 40.7527, longitude: -73.9772)
        ),
        TrackedItem(
            id: "macbook",
            name: "MacBook Pro",
            status: "Home · Now",
            initials: "",
            symbol: "laptopcomputer",
            color: .indigo,
            category: .devices,
            coordinate: CLLocationCoordinate2D(latitude: 40.7411, longitude: -73.9897)
        ),
        TrackedItem(
            id: "ipad",
            name: "Ricardo’s iPad",
            status: "Home · Now",
            initials: "",
            symbol: "ipad",
            color: .mint,
            category: .devices,
            coordinate: CLLocationCoordinate2D(latitude: 40.74125, longitude: -73.98955)
        ),
        TrackedItem(
            id: "airpods",
            name: "AirPods Pro",
            status: "Home · 4 min ago",
            initials: "",
            symbol: "airpodspro",
            color: .cyan,
            category: .devices,
            coordinate: CLLocationCoordinate2D(latitude: 40.74095, longitude: -73.98985)
        ),
        TrackedItem(
            id: "keys",
            name: "Keys",
            status: "With You",
            initials: "",
            symbol: "key.fill",
            color: .orange,
            category: .items,
            coordinate: CLLocationCoordinate2D(latitude: 40.7505, longitude: -73.9934)
        ),
        TrackedItem(
            id: "backpack",
            name: "Backpack",
            status: "Gym · 12 min ago",
            initials: "",
            symbol: "backpack.fill",
            color: .green,
            category: .items,
            coordinate: CLLocationCoordinate2D(latitude: 40.7308, longitude: -73.9973)
        )
    ]

    func matches(_ query: String) -> Bool {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return false }
        return name.localizedCaseInsensitiveContains(normalized)
            || status.localizedCaseInsensitiveContains(normalized)
            || category.title.localizedCaseInsensitiveContains(normalized)
    }

    func demoCoordinate(at date: Date) -> CLLocationCoordinate2D {
        guard category == .people || id == "iphone" else {
            return coordinate
        }

        let phase: Double
        switch id {
        case "maya": phase = 0
        case "jordan": phase = 2.1
        case "iphone": phase = 4.2
        default: phase = 1
        }

        let elapsed = date.timeIntervalSinceReferenceDate / 7
        let scale = id == "iphone" ? 0.00065 : 0.00125
        return CLLocationCoordinate2D(
            latitude: coordinate.latitude + sin(elapsed + phase) * scale,
            longitude: coordinate.longitude + cos(elapsed * 0.82 + phase) * scale * 1.45
        )
    }
}

enum EventSource: String, CaseIterable, Identifiable {
    case appleCalendar
    case googleCalendar
    case eventbrite
    case dice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .appleCalendar: "Apple Calendar"
        case .googleCalendar: "Google Calendar"
        case .eventbrite: "Eventbrite"
        case .dice: "DICE"
        }
    }

    var attribution: String {
        switch self {
        case .appleCalendar: "Found in your Calendar"
        case .googleCalendar: "Found in Google Calendar"
        case .eventbrite: "Recommended by Eventbrite"
        case .dice: "Recommended by DICE"
        }
    }

    var symbol: String {
        switch self {
        case .appleCalendar: "calendar"
        case .googleCalendar: "calendar.badge.clock"
        case .eventbrite: "ticket.fill"
        case .dice: "music.note"
        }
    }

    var color: Color {
        switch self {
        case .appleCalendar: .red
        case .googleCalendar: .blue
        case .eventbrite: .orange
        case .dice: .purple
        }
    }
}

struct EventAttendee: Identifiable {
    let id: String
    let name: String
    let initials: String
    let color: Color
}

struct CityEvent: Identifiable {
    let id: String
    let title: String
    let venue: String
    let address: String
    let timing: String
    let proximity: String
    let summary: String
    let source: EventSource
    let category: String
    let symbol: String
    let coordinate: CLLocationCoordinate2D
    let attendees: [EventAttendee]

    static let samples = [
        CityEvent(
            id: "pier-five-soccer",
            title: "Pickup soccer match with college friends",
            venue: "Brooklyn Bridge Park · Pier 5",
            address: "334 Furman Street, Brooklyn",
            timing: "In 3 days · 6:30 PM",
            proximity: "12 minutes away",
            summary: "You are already near the waterfront. Leave by 6:05 PM for an easy walk to the field.",
            source: .appleCalendar,
            category: "Sports",
            symbol: "soccerball",
            coordinate: CLLocationCoordinate2D(latitude: 40.6948, longitude: -74.0016),
            attendees: [
                EventAttendee(id: "maya", name: "Maya Rodriguez", initials: "MR", color: .purple),
                EventAttendee(id: "jordan", name: "Jordan Lee", initials: "JL", color: .teal),
                EventAttendee(id: "alex", name: "Alex Chen", initials: "AC", color: .blue)
            ]
        ),
        CityEvent(
            id: "chelsea-art-walk",
            title: "Chelsea Gallery Night",
            venue: "West Chelsea Arts District",
            address: "525 West 25th Street, Manhattan",
            timing: "Tonight · 7:00 PM",
            proximity: "8 minutes away",
            summary: "A late-night gallery walk featuring new installations across six nearby spaces.",
            source: .eventbrite,
            category: "Arts & Culture",
            symbol: "paintpalette.fill",
            coordinate: CLLocationCoordinate2D(latitude: 40.7498, longitude: -74.0048),
            attendees: []
        ),
        CityEvent(
            id: "brooklyn-steel-live",
            title: "Japanese Breakfast — Live",
            venue: "Brooklyn Steel",
            address: "319 Frost Street, Brooklyn",
            timing: "Tomorrow · 8:00 PM",
            proximity: "24 minutes away",
            summary: "Tickets are still available and this show matches artists you frequently listen to.",
            source: .dice,
            category: "Live Music",
            symbol: "music.mic",
            coordinate: CLLocationCoordinate2D(latitude: 40.7194, longitude: -73.9390),
            attendees: []
        ),
        CityEvent(
            id: "sunday-brunch",
            title: "Sunday brunch with the design team",
            venue: "Balthazar",
            address: "80 Spring Street, Manhattan",
            timing: "In 3 days · 11:30 AM",
            proximity: "15 minutes away",
            summary: "A shared calendar event with colleagues who are already in your contacts.",
            source: .googleCalendar,
            category: "Food & Social",
            symbol: "fork.knife",
            coordinate: CLLocationCoordinate2D(latitude: 40.7227, longitude: -73.9982),
            attendees: [
                EventAttendee(id: "nina", name: "Nina Patel", initials: "NP", color: .pink),
                EventAttendee(id: "sam", name: "Sam Rivera", initials: "SR", color: .indigo)
            ]
        )
    ]
}

extension CLLocationCoordinate2D {
    static let findDemoLocation = CLLocationCoordinate2D(
        latitude: 40.7527,
        longitude: -73.9772
    )
}

extension MKCoordinateRegion {
    static let newYorkCity = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.19, longitudeDelta: 0.16)
    )

    static let newYorkCityTransit = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.08)
    )

    static let losAngeles = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.90, longitude: -118.18),
        span: MKCoordinateSpan(latitudeDelta: 1.25, longitudeDelta: 1.05)
    )

    static let losAngelesTransit = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.02, longitude: -118.24),
        span: MKCoordinateSpan(latitudeDelta: 0.68, longitudeDelta: 0.58)
    )

    static let sanFrancisco = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7838, longitude: -122.4090),
        span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
    )

    static let sanFranciscoWide = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7838, longitude: -122.4090),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
}

#Preview {
    ContentView()
}
