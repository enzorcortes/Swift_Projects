import MapKit
import SwiftUI

enum SampleData {
    static let profilePosts = [
        ProfilePost(id: UUID(), caption: "New 10K best", systemImage: "trophy.fill", colors: [.orange, .pink]),
        ProfilePost(id: UUID(), caption: "Barton sunrise", systemImage: "sunrise.fill", colors: [.cyan, .indigo]),
        ProfilePost(id: UUID(), caption: "8.7 mi² claimed", systemImage: "map.fill", colors: [.indigo, .purple]),
        ProfilePost(id: UUID(), caption: "Crew swim", systemImage: "person.3.fill", colors: [.blue, .cyan]),
        ProfilePost(id: UUID(), caption: "Race ready", systemImage: "figure.run", colors: [.green, .teal]),
        ProfilePost(id: UUID(), caption: "Three crowns", systemImage: "crown.fill", colors: [.yellow, .orange])
    ]

    static let dataProviders = [
        WorkoutDataProvider(id: "health", name: "Apple Health", connectionDetail: "On-device HealthKit import", systemImage: "heart.fill", color: .red, workoutCount: "84 workouts", lastSync: "Synced now"),
        WorkoutDataProvider(id: "strava", name: "Strava", connectionDetail: "Direct account connection", systemImage: "figure.run", color: .orange, workoutCount: "31 workouts", lastSync: "2 min ago"),
        WorkoutDataProvider(id: "nike", name: "Nike Run Club", connectionDetail: "Imported through Apple Health", systemImage: "shoeprints.fill", color: .black, workoutCount: "8 workouts", lastSync: "18 min ago"),
        WorkoutDataProvider(id: "garmin", name: "Garmin Connect", connectionDetail: "Direct partner connection", systemImage: "watch.analog", color: .blue, workoutCount: "5 workouts", lastSync: "1 hr ago"),
        WorkoutDataProvider(id: "fit", name: "FIT / GPX Files", connectionDetail: "Manual file import", systemImage: "doc.badge.plus", color: .indigo, workoutCount: "No imports", lastSync: "Not connected")
    ]

    static let comments = [
        FeedComment(id: UUID(), author: "Luke", text: "I’m taking that block back tomorrow."),
        FeedComment(id: UUID(), author: "Maya", text: "That route was seriously clever!")
    ]

    static let feedPosts = [
        FeedPost(id: UUID(), author: "Maya", authorIcon: "person.crop.circle.fill", kind: .territory, title: "South Congress is contested", detail: "Maya captured two blocks from Trailblazer after a 4.2-mile run. The territory has changed hands three times this week.", timestamp: .now.addingTimeInterval(-900), likeCount: 31, comments: comments, tint: .pink, territory: territoryCoordinates),
        FeedPost(id: UUID(), author: "The Bellyfloppers", authorIcon: "drop.fill", kind: .achievement, title: "New city leader", detail: "The crew moved into first place in Austin after collectively swimming 42 miles this week.", timestamp: .now.addingTimeInterval(-3_600), likeCount: 87, comments: [FeedComment(id: UUID(), author: "Derek", text: "Proud of this crew!")], tint: .cyan, territory: []),
        FeedPost(id: UUID(), author: "Luke", authorIcon: "person.crop.circle.fill", kind: .workout, title: "Morning ride through the Veloway", detail: "18.6 mi cycling · 1:04:12 · claimed 1.2 mi²", timestamp: .now.addingTimeInterval(-7_200), likeCount: 19, comments: [], tint: .green, territory: [])
    ]

    static let incomingFeedPosts = [
        FeedPost(id: UUID(), author: "Front Desk Crew", authorIcon: "bell.fill", kind: .territory, title: "Front Desk Crew is advancing", detail: "A coordinated lunch run captured 0.9 mi² near downtown Austin.", timestamp: .now, likeCount: 12, comments: comments, tint: .orange, territory: friendTerritories[1].coordinates),
        FeedPost(id: UUID(), author: "Derek", authorIcon: "person.crop.circle.fill", kind: .achievement, title: "Barton Springs defended", detail: "Derek extended his freestyle lead to 6.4 miles this season.", timestamp: .now, likeCount: 24, comments: comments, tint: .cyan, territory: [])
    ]

    static let followers = [
        SocialPerson(id: UUID(), name: "Maya", subtitle: "Friend · Austin", score: "7.9 mi²", systemImage: "person.crop.circle.fill", tint: .pink),
        SocialPerson(id: UUID(), name: "Luke", subtitle: "Front Desk Crew", score: "6.4 mi²", systemImage: "person.crop.circle.fill", tint: .green),
        SocialPerson(id: UUID(), name: "Derek", subtitle: "The Bellyfloppers", score: "6 crowns", systemImage: "person.crop.circle.fill", tint: .cyan),
        SocialPerson(id: UUID(), name: "Jordan", subtitle: "Friend · Austin", score: "16.2 mi²", systemImage: "person.crop.circle.fill", tint: .orange)
    ]

    static let following = [followers[0], followers[2], followers[3]]

    static let competitors = [
        Competitor(id: UUID(), name: "Derek", score: "6.0 mi"),
        Competitor(id: UUID(), name: "Luke", score: "4.0 mi"),
        Competitor(id: UUID(), name: "Maya", score: "3.4 mi")
    ]

    static let cityCompetitors = [
        Competitor(id: UUID(), name: "Avery", score: "18.7 mi²"),
        Competitor(id: UUID(), name: "Jordan", score: "16.2 mi²"),
        Competitor(id: UUID(), name: "Trailblazer", score: "8.7 mi²"),
        Competitor(id: UUID(), name: "Maya", score: "7.9 mi²"),
        Competitor(id: UUID(), name: "Luke", score: "6.4 mi²")
    ]

    static let venues = [
        Venue(id: UUID(), name: "Barton Springs Pool", sport: .swimming, coordinate: .init(latitude: 30.2637, longitude: -97.7713), distanceAway: "1.2 mi", isOwned: true, leaderboard: competitors),
        Venue(id: UUID(), name: "Deep Eddy Pool", sport: .swimming, coordinate: .init(latitude: 30.2770, longitude: -97.7731), distanceAway: "2.4 mi", isOwned: false, leaderboard: Array(competitors.dropFirst())),
        Venue(id: UUID(), name: "Butler Trail", sport: .running, coordinate: .init(latitude: 30.2599, longitude: -97.7476), distanceAway: "0.8 mi", isOwned: true, leaderboard: competitors),
        Venue(id: UUID(), name: "Veloway", sport: .cycling, coordinate: .init(latitude: 30.1916, longitude: -97.8731), distanceAway: "9.6 mi", isOwned: false, leaderboard: Array(competitors.reversed()))
    ]

    static let amenities = [
        TrainingAmenity(id: UUID(), name: "Butler Trail Water Station", kind: .water, coordinate: .init(latitude: 30.2621, longitude: -97.7514), distanceAway: "0.3 mi", detail: "Bottle filler available dawn to dusk", rating: "4.8", recommendationCount: 42, recommendation: "Cold water and good pressure. The fountain is beside the trail map."),
        TrainingAmenity(id: UUID(), name: "Auditorium Shores Restrooms", kind: .restroom, coordinate: .init(latitude: 30.2602, longitude: -97.7500), distanceAway: "0.5 mi", detail: "Public facilities near the trail entrance", rating: "4.2", recommendationCount: 28, recommendation: "Usually open early and well lit. Short line on weekday mornings."),
        TrainingAmenity(id: UUID(), name: "South First Refuel Stop", kind: .refuel, coordinate: .init(latitude: 30.2552, longitude: -97.7550), distanceAway: "0.9 mi", detail: "Snacks, electrolytes, and outdoor seating", rating: "4.7", recommendationCount: 61, recommendation: "Fast stop for water and a banana without leaving the training route."),
        TrainingAmenity(id: UUID(), name: "Deep Eddy Water Fountain", kind: .water, coordinate: .init(latitude: 30.2764, longitude: -97.7722), distanceAway: "2.3 mi", detail: "Fountain outside the pool entrance", rating: "4.5", recommendationCount: 19, recommendation: "Accessible even when the pool entrance is busy.")
    ]

    static let crews = [
        Crew(
            id: UUID(),
            name: "The Bellyfloppers",
            motto: "Making waves, taking names.",
            systemImage: "drop.fill",
            color: .cyan,
            memberCount: 14,
            territoryScore: "12.8 mi²",
            localRank: "#1",
            territory: [
                .init(latitude: 30.2820, longitude: -97.7850),
                .init(latitude: 30.2890, longitude: -97.7510),
                .init(latitude: 30.2700, longitude: -97.7360),
                .init(latitude: 30.2580, longitude: -97.7680),
                .init(latitude: 30.2820, longitude: -97.7850)
            ],
            contributors: competitors
        ),
        Crew(
            id: UUID(),
            name: "Front Desk Crew",
            motto: "Clocked in. Locked in.",
            systemImage: "bell.fill",
            color: .orange,
            memberCount: 11,
            territoryScore: "9.6 mi²",
            localRank: "#2",
            territory: [
                .init(latitude: 30.2670, longitude: -97.7440),
                .init(latitude: 30.2730, longitude: -97.7180),
                .init(latitude: 30.2500, longitude: -97.7100),
                .init(latitude: 30.2410, longitude: -97.7380),
                .init(latitude: 30.2670, longitude: -97.7440)
            ],
            contributors: Array(competitors.dropFirst())
        ),
        Crew(
            id: UUID(),
            name: "Southside Striders",
            motto: "Every block counts.",
            systemImage: "bolt.fill",
            color: .purple,
            memberCount: 9,
            territoryScore: "7.3 mi²",
            localRank: "#3",
            territory: [
                .init(latitude: 30.2480, longitude: -97.7680),
                .init(latitude: 30.2520, longitude: -97.7400),
                .init(latitude: 30.2260, longitude: -97.7320),
                .init(latitude: 30.2200, longitude: -97.7600),
                .init(latitude: 30.2480, longitude: -97.7680)
            ],
            contributors: Array(competitors.reversed())
        )
    ]

    static let friendTerritories = [
        FriendTerritory(
            id: UUID(),
            ownerName: "Maya",
            relationship: "Friend · captured today",
            area: "0.7 mi²",
            color: .pink,
            coordinates: [
                .init(latitude: 30.2740, longitude: -97.7530),
                .init(latitude: 30.2790, longitude: -97.7400),
                .init(latitude: 30.2700, longitude: -97.7320),
                .init(latitude: 30.2640, longitude: -97.7460),
                .init(latitude: 30.2740, longitude: -97.7530)
            ]
        ),
        FriendTerritory(
            id: UUID(),
            ownerName: "Luke",
            relationship: "From contacts · captured yesterday",
            area: "0.5 mi²",
            color: .green,
            coordinates: [
                .init(latitude: 30.2590, longitude: -97.7600),
                .init(latitude: 30.2630, longitude: -97.7470),
                .init(latitude: 30.2530, longitude: -97.7390),
                .init(latitude: 30.2470, longitude: -97.7530),
                .init(latitude: 30.2590, longitude: -97.7600)
            ]
        )
    ]

    static func ranking(for city: RankedCity) -> CityRanking {
        switch city {
        case .austin:
            CityRanking(activePlayers: "1,284", claimedArea: "68%", seasonEnds: "12 days", individuals: cityCompetitors, crews: crews)
        case .chicago:
            CityRanking(activePlayers: "2,941", claimedArea: "74%", seasonEnds: "12 days", individuals: Array(cityCompetitors.dropFirst()) + [cityCompetitors[0]], crews: [crews[1], crews[2], crews[0]])
        case .denver:
            CityRanking(activePlayers: "1,806", claimedArea: "61%", seasonEnds: "12 days", individuals: Array(cityCompetitors.reversed()), crews: [crews[2], crews[0], crews[1]])
        case .seattle:
            CityRanking(activePlayers: "2,207", claimedArea: "70%", seasonEnds: "12 days", individuals: [cityCompetitors[1], cityCompetitors[0], cityCompetitors[3], cityCompetitors[2], cityCompetitors[4]], crews: [crews[0], crews[2], crews[1]])
        }
    }

    static let activities = [
        FitnessActivity(id: UUID(), title: "Derek defended Barton Springs", detail: "6.0 mi freestyle · Pool crown · via Apple Health", sport: .swimming, date: .now.addingTimeInterval(-1_800)),
        FitnessActivity(id: UUID(), title: "Maya captured South Congress", detail: "4.2 mi run · 0.7 mi² captured · via Strava", sport: .running, date: .now.addingTimeInterval(-10_800)),
        FitnessActivity(id: UUID(), title: "Luke moved into second", detail: "4.0 mi freestyle · Barton Springs · via Garmin", sport: .swimming, date: .now.addingTimeInterval(-86_400))
    ]

    static let territoryCoordinates = [
        CLLocationCoordinate2D(latitude: 30.2700, longitude: -97.7600),
        CLLocationCoordinate2D(latitude: 30.2755, longitude: -97.7420),
        CLLocationCoordinate2D(latitude: 30.2585, longitude: -97.7350),
        CLLocationCoordinate2D(latitude: 30.2500, longitude: -97.7540),
        CLLocationCoordinate2D(latitude: 30.2700, longitude: -97.7600)
    ]
}

extension MKCoordinateRegion {
    static let austin = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
}

