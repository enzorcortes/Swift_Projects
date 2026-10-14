import SwiftUI
import MapKit

// MARK: - Explore

struct ExploreView: View {
    @State private var cameraPosition = MapCameraPosition.region(.sanFrancisco)
    @State private var selectedPlace: Place?
    @State private var searchText = ""

    private let places = Place.samples

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ExploreMap(
                    cameraPosition: $cameraPosition,
                    places: places,
                    selectedPlace: $selectedPlace
                )

                NearbyPlacesCarousel(
                    places: places,
                    onSelect: { place in
                        selectedPlace = place
                        withAnimation {
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: place.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
                                )
                            )
                        }
                    }
                )
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Maps")
            .searchable(text: $searchText, prompt: "Search places, people, and items")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("Account")
                }

                ToolbarItem(placement: .automatic) {
                    Button {
                        cameraPosition = .region(.sanFrancisco)
                    } label: {
                        Image(systemName: "location.fill")
                    }
                    .accessibilityLabel("Center map")
                }
            }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct ExploreMap: View {
    @Binding var cameraPosition: MapCameraPosition
    let places: [Place]
    @Binding var selectedPlace: Place?

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(places) { place in
                Annotation(place.name, coordinate: place.coordinate) {
                    Button {
                        selectedPlace = place
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.blue)
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

                            Image(systemName: place.symbol)
                                .foregroundStyle(.white)
                        }
                    }
                    .accessibilityLabel("\(place.name), rated \(place.rating.formatted()) out of 5")
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapPitchToggle()
        }
    }
}

struct NearbyPlacesCarousel: View {
    let places: [Place]
    let onSelect: (Place) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Popular nearby")
                    .font(.headline)

                Spacer()

                Text("Apple Community")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 18)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(places) { place in
                        Button {
                            onSelect(place)
                        } label: {
                            PlaceCard(
                                name: place.name,
                                category: place.category,
                                rating: place.rating,
                                reviewCount: place.reviewCount,
                                symbol: place.symbol,
                                color: place.color
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
            }
        }
        .padding(.vertical, 14)
        .background(.regularMaterial)
    }
}

struct PlaceCard: View {
    let name: String
    let category: String
    let rating: Double
    let reviewCount: Int
    let symbol: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.gradient)

                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(category)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Text(rating, format: .number.precision(.fractionLength(1)))
                        .fontWeight(.semibold)
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                    Text("(\(reviewCount))")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
        .frame(width: 215, alignment: .leading)
        .padding(10)
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
    }
}
