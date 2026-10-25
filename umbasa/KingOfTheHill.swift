import MapKit
import SwiftUI

struct VenuesView: View {
    @State private var wishlist: Set<UUID> = []

    private var conquered: [Venue] { SampleData.venues.filter(\.isOwned) }
    private var contested: [Venue] { SampleData.venues.filter { !$0.isOwned } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("KING OF THE HILL")
                        .font(.system(.largeTitle, design: .rounded, weight: .black))
                        .tracking(1.2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .listRowBackground(Color.clear)

                Section("Recommended challenge") {
                    RecommendedVenueCard(venue: SampleData.venues[1], isSaved: wishlist.contains(SampleData.venues[1].id)) {
                        toggleWishlist(SampleData.venues[1])
                    }
                }

                Section("Conquered") {
                    ForEach(conquered) { venue in
                        VenueListItem(venue: venue, isSaved: wishlist.contains(venue.id)) {
                            toggleWishlist(venue)
                        }
                    }
                }

                Section("Contested Venues") {
                    ForEach(contested) { venue in
                        VenueListItem(venue: venue, isSaved: wishlist.contains(venue.id)) {
                            toggleWishlist(venue)
                        }
                    }
                }
            }
            .navigationTitle("")
        }
    }

    private func toggleWishlist(_ venue: Venue) {
        if wishlist.contains(venue.id) {
            wishlist.remove(venue.id)
        } else {
            wishlist.insert(venue.id)
        }
    }
}

struct VenueListItem: View {
    let venue: Venue
    let isSaved: Bool
    let toggleSaved: () -> Void

    var body: some View {
        HStack {
            NavigationLink {
                VenueDetailView(venue: venue)
            } label: {
                VenueRow(venue: venue)
            }
            Button(action: toggleSaved) {
                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                    .font(.title3)
                    .foregroundStyle(isSaved ? .indigo : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isSaved ? "Remove from wishlist" : "Add to wishlist")
        }
    }
}

struct RecommendedVenueCard: View {
    let venue: Venue
    let isSaved: Bool
    let toggleSaved: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VenueBannerView(venue: venue)
                .frame(height: 145)
            Text("Luke just beat Maya’s personal record here.")
                .font(.headline)
            Text("The crown is moving fast—jump into the action before the weekend leaderboard closes.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                NavigationLink("View challenge") {
                    VenueDetailView(venue: venue)
                }
                .buttonStyle(.borderedProminent)
                Button(isSaved ? "Saved" : "Want to Visit", systemImage: isSaved ? "bookmark.fill" : "bookmark", action: toggleSaved)
                    .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 8)
    }
}

struct VenueRow: View {
    let venue: Venue

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: venue.sport.systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(venue.sport.color.gradient, in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(venue.name)
                    .font(.headline)
                Text(venue.sport.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Label(venue.distanceAway, systemImage: "location.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(venue.isOwned ? .orange : .secondary)
                Text(venue.leaderName)
                    .font(.caption.weight(.semibold))
                Text(venue.leaderScore)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct VenueDetailView: View {
    let venue: Venue

    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    VenueBannerView(venue: venue)
                        .frame(height: 190)
                    Text(venue.name)
                        .font(.title2.bold())
                    Label(venue.distanceAway, systemImage: "location.fill")
                        .foregroundStyle(.secondary)
                    Button("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill") {
                        let location = CLLocation(latitude: venue.coordinate.latitude, longitude: venue.coordinate.longitude)
                        let item = MKMapItem(location: location, address: nil)
                        item.name = venue.name
                        item.openInMaps()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section("This month's leaders") {
                ForEach(Array(venue.leaderboard.enumerated()), id: \.element.id) { index, competitor in
                    HStack {
                        Text("\(index + 1)")
                            .font(.headline.monospacedDigit())
                            .frame(width: 28)
                        Image(systemName: index == 0 ? "crown.fill" : "person.crop.circle.fill")
                            .foregroundStyle(index == 0 ? .orange : .secondary)
                        Text(competitor.name)
                        Spacer()
                        Text(competitor.score)
                            .fontWeight(.semibold)
                    }
                }
            }

            Section("How to claim") {
                Text("Complete a verified \(venue.sport.title.lowercased()) workout at this venue. Recent activity is weighted more heavily so every crown stays competitive.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Leaderboard")
    }
}

struct VenueBannerView: View {
    let venue: Venue

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [venue.sport.color, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: venue.sport.systemImage)
                .font(.system(size: 82))
                .foregroundStyle(.white.opacity(0.25))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            VStack(alignment: .leading, spacing: 3) {
                Text(venue.name).font(.headline)
                Text(venue.isOwned ? "Official venue profile" : "Community venue")
                    .font(.caption)
            }
            .foregroundStyle(.white)
            .padding()
        }
        .clipShape(.rect(cornerRadius: 16))
    }
}

