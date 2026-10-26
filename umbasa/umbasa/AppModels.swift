import MapKit
import SwiftUI

struct FeedPost: Identifiable {
    let id: UUID
    let author: String
    let authorIcon: String
    let kind: FeedPostKind
    let title: String
    let detail: String
    let timestamp: Date
    let likeCount: Int
    let comments: [FeedComment]
    let tint: Color
    let territory: [CLLocationCoordinate2D]
}

struct FeedComment: Identifiable {
    let id: UUID
    let author: String
    let text: String
}

enum FeedPostKind {
    case workout
    case territory
    case achievement

    var title: String {
        switch self {
        case .workout: "Workout"
        case .territory: "Territory update"
        case .achievement: "Achievement"
        }
    }

    var systemImage: String {
        switch self {
        case .workout: "figure.run"
        case .territory: "map.fill"
        case .achievement: "trophy.fill"
        }
    }

}

struct SocialPerson: Identifiable {
    let id: UUID
    let name: String
    let subtitle: String
    let score: String
    let systemImage: String
    let tint: Color
}

struct TrainingAmenity: Identifiable {
    let id: UUID
    let name: String
    let kind: AmenityKind
    let coordinate: CLLocationCoordinate2D
    let distanceAway: String
    let detail: String
    let rating: String
    let recommendationCount: Int
    let recommendation: String
}

struct WorkoutDataProvider: Identifiable {
    let id: String
    let name: String
    let connectionDetail: String
    let systemImage: String
    let color: Color
    let workoutCount: String
    let lastSync: String
}

struct ProfilePost: Identifiable {
    let id: UUID
    let caption: String
    let systemImage: String
    let colors: [Color]
}

enum PostType: CaseIterable, Identifiable {
    case milestone
    case photo
    case activity

    var id: Self { self }

    var title: String {
        switch self {
        case .milestone: "Milestone"
        case .photo: "Photo"
        case .activity: "Activity invitation"
        }
    }

    var systemImage: String {
        switch self {
        case .milestone: "trophy.fill"
        case .photo: "photo.fill"
        case .activity: "calendar.badge.plus"
        }
    }
}

enum AmenityKind {
    case water
    case restroom
    case refuel

    var title: String {
        switch self {
        case .water: "Water refill"
        case .restroom: "Public restroom"
        case .refuel: "Food and refuel"
        }
    }

    var systemImage: String {
        switch self {
        case .water: "waterbottle.fill"
        case .restroom: "figure.dress.line.vertical.figure"
        case .refuel: "fork.knife"
        }
    }

    var color: Color {
        switch self {
        case .water: .blue
        case .restroom: .purple
        case .refuel: .orange
        }
    }
}

struct Venue: Identifiable {
    let id: UUID
    let name: String
    let sport: Sport
    let coordinate: CLLocationCoordinate2D
    let distanceAway: String
    let isOwned: Bool
    let leaderboard: [Competitor]

    var leaderName: String {
        leaderboard.first?.name ?? "Unclaimed"
    }

    var leaderScore: String {
        leaderboard.first?.score ?? "Be first"
    }
}

struct Competitor: Identifiable {
    let id: UUID
    let name: String
    let score: String
}

struct FitnessActivity: Identifiable {
    let id: UUID
    let title: String
    let detail: String
    let sport: Sport
    let date: Date
}

struct Crew: Identifiable {
    let id: UUID
    let name: String
    let motto: String
    let systemImage: String
    let color: Color
    let memberCount: Int
    let territoryScore: String
    let localRank: String
    let territory: [CLLocationCoordinate2D]
    let contributors: [Competitor]
}

struct FriendTerritory: Identifiable {
    let id: UUID
    let ownerName: String
    let relationship: String
    let area: String
    let color: Color
    let coordinates: [CLLocationCoordinate2D]
}

struct CityRanking {
    let activePlayers: String
    let claimedArea: String
    let seasonEnds: String
    let individuals: [Competitor]
    let crews: [Crew]
}

enum RankedCity: String, CaseIterable, Identifiable {
    case austin
    case chicago
    case denver
    case seattle

    var id: Self { self }

    var title: String {
        switch self {
        case .austin: "Austin, TX"
        case .chicago: "Chicago, IL"
        case .denver: "Denver, CO"
        case .seattle: "Seattle, WA"
        }
    }

    var cityName: String {
        switch self {
        case .austin: "Austin"
        case .chicago: "Chicago"
        case .denver: "Denver"
        case .seattle: "Seattle"
        }
    }

    var stateName: String {
        switch self {
        case .austin: "Texas"
        case .chicago: "Illinois"
        case .denver: "Colorado"
        case .seattle: "Washington"
        }
    }
}

enum TerritoryMode: CaseIterable, Identifiable {
    case individual
    case crews

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .individual: "Me"
        case .crews: "Crews"
        }
    }
}

enum Sport: String, CaseIterable, Identifiable {
    case running
    case cycling
    case swimming

    var id: Self { self }

    var title: String {
        switch self {
        case .running: "Running"
        case .cycling: "Cycling"
        case .swimming: "Swimming"
        }
    }

    var systemImage: String {
        switch self {
        case .running: "figure.run"
        case .cycling: "bicycle"
        case .swimming: "figure.pool.swim"
        }
    }

    var color: Color {
        switch self {
        case .running: .indigo
        case .cycling: .green
        case .swimming: .cyan
        }
    }
}

