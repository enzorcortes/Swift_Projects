import SwiftUI

struct HomeSearchDock: View {
    @Binding var searchText: String
    let onProfile: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 11) {
                Image(systemName: "magnifyingglass")
                    .font(.title3.weight(.semibold))

                TextField("Search places and Find My", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.title3)

                if searchText.isEmpty {
                    Image(systemName: "mic.fill")
                        .font(.title3)
                } else {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(height: 56)
            .background(.thinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }

            Button(action: onProfile) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                .frame(width: 54, height: 54)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open account and app features")
        }
        .padding(10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.14), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.32), radius: 20, y: 10)
        .frame(maxWidth: 610)
        .padding(.horizontal, 22)
        .padding(.bottom, 18)
    }
}

struct HomeInlineSearchResults: View {
    let searchText: String
    let places: [Place]
    let trackedItems: [TrackedItem]
    let onSelectPlace: (Place) -> Void
    let onSelectTrackedItem: (TrackedItem) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Maps & Find My Results")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                ForEach(places) { place in
                    HomePlaceSearchResult(
                        place: place,
                        isVisible: place.matches(searchText),
                        action: { onSelectPlace(place) }
                    )
                }

                ForEach(trackedItems) { item in
                    HomeTrackedSearchResult(
                        item: item,
                        isVisible: item.matches(searchText),
                        action: { onSelectTrackedItem(item) }
                    )
                }
            }
        }
        .frame(maxWidth: 566, maxHeight: 390)
        .background(.clear)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
        .padding(.horizontal, 34)
        .padding(.bottom, 98)
    }
}

struct HomePlaceSearchResult: View {
    let place: Place
    let isVisible: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if isVisible {
                Button(action: action) {
                    HStack(spacing: 12) {
                        Image(systemName: place.symbol)
                            .frame(width: 38, height: 38)
                            .background(place.color.gradient, in: Circle())
                            .foregroundStyle(.white)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(place.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("\(place.category) · \(place.rating.formatted(.number.precision(.fractionLength(1)))) ★ · \(place.reviewCount) Apple reviews")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.leading, 64)
            }
        }
    }
}

struct HomeTrackedSearchResult: View {
    let item: TrackedItem
    let isVisible: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if isVisible {
                Button(action: action) {
                    HStack(spacing: 12) {
                        TrackerMarker(
                            initials: item.initials,
                            symbol: item.symbol,
                            color: item.color,
                            isPerson: item.category == .people
                        )
                        .scaleEffect(0.72)
                        .frame(width: 38, height: 38)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Find My · \(item.category.title) · \(item.status)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.leading, 64)
            }
        }
    }
}

struct HomeSearchSheet: View {
    let places: [Place]
    let onOpenCommunity: () -> Void
    @State private var searchText = ""
    @State private var selectedPlace: Place?

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search places, people, and items", text: $searchText)
                    Image(systemName: "mic.fill")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(.quaternary, in: Capsule())

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Popular nearby")
                            .font(.headline)
                        Spacer()
                        Button("Community", action: onOpenCommunity)
                    }

                    ForEach(places) { place in
                        Button {
                            selectedPlace = place
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: place.symbol)
                                    .frame(width: 42, height: 42)
                                    .background(place.color.gradient, in: Circle())
                                    .foregroundStyle(.white)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(place.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("\(place.category) · \(place.rating.formatted(.number.precision(.fractionLength(1)))) ★")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    ModalCloseButton()
                }
            }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
            }
        }
    }
}
