import MapKit
import SwiftUI

struct TerritoryView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.austin)
    @State private var showingRecordSheet = false
    @State private var showingAccomplishments = false
    @State private var selectedAmenity: TrainingAmenity?
    @State private var territoryMode = TerritoryMode.individual

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Map(position: $cameraPosition) {
                    if territoryMode == .individual {
                        MapPolygon(coordinates: SampleData.territoryCoordinates)
                            .foregroundStyle(.indigo.opacity(0.28))
                            .stroke(.indigo, lineWidth: 3)

                        ForEach(SampleData.friendTerritories) { territory in
                            MapPolygon(coordinates: territory.coordinates)
                                .foregroundStyle(territory.color.opacity(0.24))
                                .stroke(territory.color, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        }
                    } else {
                        ForEach(SampleData.crews) { crew in
                            MapPolygon(coordinates: crew.territory)
                                .foregroundStyle(crew.color.opacity(0.32))
                                .stroke(crew.color, lineWidth: 3)
                        }
                    }

                    ForEach(SampleData.venues) { venue in
                        Annotation(venue.name, coordinate: venue.coordinate) {
                            VenueMapMarker(isOwned: venue.isOwned)
                        }
                    }

                    ForEach(SampleData.amenities) { amenity in
                        Annotation(amenity.name, coordinate: amenity.coordinate) {
                            Button {
                                selectedAmenity = amenity
                            } label: {
                                Image(systemName: amenity.kind.systemImage)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white)
                                    .frame(width: 34, height: 34)
                                    .background(amenity.kind.color, in: .circle)
                                    .overlay(Circle().stroke(.white, lineWidth: 2))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }

                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        Button {
                            showingRecordSheet = true
                        } label: {
                            Label("Record", systemImage: "record.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 18)
                                .frame(height: 52)
                                .background(.red.gradient, in: .capsule)
                                .shadow(radius: 8, y: 4)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 10) {
                            if showingAccomplishments {
                                if territoryMode == .individual {
                                    AccomplishmentsPanel(friendTerritories: SampleData.friendTerritories)
                                        .transition(.move(edge: .trailing).combined(with: .opacity))
                                } else {
                                    CrewMapLegend(crews: SampleData.crews)
                                        .transition(.move(edge: .trailing).combined(with: .opacity))
                                }
                            }

                            MapUserLocationButton()
                                .frame(width: 44, height: 44)
                                .background(.regularMaterial, in: .circle)
                                .shadow(radius: 6, y: 3)

                            Button {
                                withAnimation(.snappy) {
                                    showingAccomplishments.toggle()
                                }
                            } label: {
                                Image(systemName: showingAccomplishments ? "chevron.right" : "trophy.fill")
                                    .font(.headline)
                                    .frame(width: 44, height: 44)
                                    .background(.regularMaterial, in: .circle)
                                    .shadow(radius: 6, y: 3)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(showingAccomplishments ? "Hide accomplishments" : "Show accomplishments")

                            HStack(spacing: 10) {
                                TerritoryModeButton(mode: .individual, selectedMode: $territoryMode, systemImage: "person.fill")
                                TerritoryModeButton(mode: .crews, selectedMode: $territoryMode, systemImage: "person.3.fill")
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Territory")
            .sheet(isPresented: $showingRecordSheet) {
                RecordWorkoutView()
            }
            .sheet(item: $selectedAmenity) { amenity in
                AmenityDetailView(amenity: amenity)
            }
        }
    }

}

struct TerritoryModeButton: View {
    let mode: TerritoryMode
    @Binding var selectedMode: TerritoryMode
    let systemImage: String

    var body: some View {
        Button {
            selectedMode = mode
        } label: {
            VStack(spacing: 3) {
                Image(systemName: systemImage)
                    .font(.headline)
                Text(mode.title)
                    .font(.caption2.bold())
            }
            .foregroundStyle(selectedMode == mode ? .white : .primary)
            .frame(width: 58, height: 52)
            .background(selectedMode == mode ? AnyShapeStyle(Color.indigo.gradient) : AnyShapeStyle(.regularMaterial), in: .rect(cornerRadius: 14))
            .shadow(radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct AmenityDetailView: View {
    let amenity: TrainingAmenity
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: amenity.kind.systemImage)
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .background(amenity.kind.color.gradient, in: .circle)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(amenity.name).font(.headline)
                            Text(amenity.kind.title).foregroundStyle(.secondary)
                            Label(amenity.distanceAway, systemImage: "location.fill")
                                .font(.caption)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Training notes") {
                    Label(amenity.detail, systemImage: "checkmark.seal.fill")
                    LabeledContent("Community rating", value: amenity.rating)
                    LabeledContent("Recommendations", value: "\(amenity.recommendationCount)")
                }

                Section("Latest recommendation") {
                    Text(amenity.recommendation)
                    Text("Shared by a local athlete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("Recommend this stop", systemImage: "hand.thumbsup.fill") { }
            }
            .navigationTitle("Nearby Stop")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct AccomplishmentsPanel: View {
    let friendTerritories: [FriendTerritory]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your season")
                .font(.headline)

            HStack(spacing: 12) {
                StatView(value: "12", label: "Territories", systemImage: "flag.fill")
                StatView(value: "3", label: "Crowns", systemImage: "crown.fill")
                StatView(value: "#8", label: "City rank", systemImage: "chart.bar.fill")
            }

            Divider()

            Text("Nearby challengers")
                .font(.subheadline.bold())

            ForEach(friendTerritories) { territory in
                HStack {
                    Circle()
                        .fill(territory.color)
                        .frame(width: 10, height: 10)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(territory.ownerName)
                            .font(.subheadline.weight(.medium))
                        Text(territory.relationship)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(territory.area)
                        .font(.caption.monospacedDigit())
                }
            }
        }
        .padding()
        .frame(maxWidth: 310)
        .background(.regularMaterial, in: .rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.14), radius: 12, y: 5)
    }
}

struct VenueMapMarker: View {
    let isOwned: Bool

    var body: some View {
        Image(systemName: isOwned ? "crown.fill" : "mappin")
            .font(.headline)
            .foregroundStyle(.white)
            .padding(10)
            .background(isOwned ? Color.orange : Color.indigo, in: .circle)
            .shadow(radius: 3, y: 2)
            .accessibilityLabel(isOwned ? "Owned venue" : "Available venue")
    }
}

struct StatView: View {
    let value: String
    let label: LocalizedStringKey
    let systemImage: String

    var body: some View {
        VStack(spacing: 4) {
            Label(value, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.indigo)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CrewMapLegend: View {
    let crews: [Crew]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Crew control")
                .font(.headline)

            ForEach(crews.prefix(3)) { crew in
                HStack {
                    Circle()
                        .fill(crew.color)
                        .frame(width: 10, height: 10)
                    Text(crew.name)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(crew.territoryScore)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 5)
    }
}

