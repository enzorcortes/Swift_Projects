import SwiftUI

struct HomeProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    AccountProfileHeader(
                        name: "Ricardo Cortes",
                        email: "ricardo@icloud.com"
                    )

                    ProfileMenuSection(title: "Maps & Community") {
                        NavigationLink {
                            FindView()
                        } label: {
                            ProfileMenuRow(
                                title: "Find",
                                subtitle: "People, devices, and items",
                                symbol: "location.viewfinder",
                                color: .green
                            )
                        }

                        Divider()
                            .padding(.leading, 66)

                        NavigationLink {
                            CommunityView()
                        } label: {
                            ProfileMenuRow(
                                title: "Apple Community",
                                subtitle: "Reviews and photos from Apple Account users",
                                symbol: "person.2.fill",
                                color: .blue
                            )
                        }
                    }

                    ProfileMenuSection(title: "Your Maps") {
                        NavigationLink {
                            PlacesHistoryView()
                        } label: {
                            ProfileMenuRow(
                                title: "Places",
                                subtitle: "Recently visited and saved",
                                symbol: "clock.arrow.circlepath",
                                color: .orange
                            )
                        }

                        Divider()
                            .padding(.leading, 66)

                        NavigationLink {
                            ReportsView()
                        } label: {
                            ProfileMenuRow(
                                title: "Reports",
                                subtitle: "Issues and corrections you submitted",
                                symbol: "exclamationmark.bubble.fill",
                                color: .red
                            )
                        }

                        Divider()
                            .padding(.leading, 66)

                        NavigationLink {
                            OfflineMapsView()
                        } label: {
                            ProfileMenuRow(
                                title: "Offline Maps",
                                subtitle: "Download areas for offline use",
                                symbol: "arrow.down.circle.fill",
                                color: .indigo
                            )
                        }

                        Divider()
                            .padding(.leading, 66)

                        NavigationLink {
                            MapPreferencesView()
                        } label: {
                            ProfileMenuRow(
                                title: "Preferences",
                                subtitle: "Drive, walk, transit, cycle, and photo credit",
                                symbol: "slider.horizontal.3",
                                color: .gray
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 24)
            }
            .navigationTitle("Account")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.glass)
                    .accessibilityLabel("Close account")
                }
            }
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
        .padding(6)
    }
}

struct ProfileMenuSection<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 6)

            VStack(spacing: 0) {
                content
            }
            .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            }
        }
    }
}

struct AccountProfileHeader: View {
    let name: String
    let email: String

    var body: some View {
        VStack(spacing: 10) {
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
                    .font(.system(size: 42))
                    .foregroundStyle(.white)
            }
            .frame(width: 96, height: 96)
            .overlay {
                Circle()
                    .stroke(.white.opacity(0.22), lineWidth: 2)
            }

            Text(name)
                .font(.title2.bold())

            Text(email)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Apple Account")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.blue)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.blue.opacity(0.14), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct ProfileMenuRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .frame(width: 42, height: 42)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 11))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

extension View {
    func profileMenuStyle() -> some View {
        self
            .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 18))
            .buttonStyle(.plain)
    }
}

struct PlacesHistoryView: View {
    var body: some View {
        List {
            Section("Recently Visited") {
                PlaceHistoryRow(
                    title: "Ferry Building",
                    detail: "Yesterday · 10:42 AM",
                    symbol: "fork.knife",
                    color: .orange
                )
                PlaceHistoryRow(
                    title: "SFMOMA",
                    detail: "Monday · 2:18 PM",
                    symbol: "photo.artframe",
                    color: .pink
                )
                PlaceHistoryRow(
                    title: "Dolores Park",
                    detail: "Last Saturday · 5:31 PM",
                    symbol: "leaf.fill",
                    color: .green
                )
            }

            Section {
                Toggle("Keep Significant Locations", isOn: .constant(true))
            } footer: {
                Text("Your location history is private and stays associated with your Apple Account.")
            }
        }
        .navigationTitle("Places")
    }
}

struct PlaceHistoryRow: View {
    let title: String
    let detail: String
    let symbol: String
    let color: Color

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: symbol)
                .foregroundStyle(color)
        }
    }
}

struct ReportsView: View {
    var body: some View {
        List {
            Section {
                ReportRow(
                    title: "Road closure",
                    location: "Market Street",
                    status: "Resolved",
                    color: .green
                )
                ReportRow(
                    title: "Incorrect hours",
                    location: "Blue Bottle Coffee",
                    status: "Under Review",
                    color: .orange
                )
            } header: {
                Text("Your Reports")
            } footer: {
                Text("Reports help improve Maps for everyone. Your identity is not shown publicly.")
            }
        }
        .navigationTitle("Reports")
    }
}

struct ReportRow: View {
    let title: String
    let location: String
    let status: String
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(status)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
        }
    }
}

struct OfflineMapsView: View {
    @State private var automaticUpdates = true
    @State private var optimizeStorage = true
    @State private var hasDownloadedLosAngeles = false

    var body: some View {
        List {
            Section("Suggested Maps") {
                OfflineMapRow(
                    title: "Los Angeles",
                    size: "1.8 GB",
                    isDownloaded: hasDownloadedLosAngeles,
                    action: { hasDownloadedLosAngeles.toggle() }
                )
                OfflineMapRow(
                    title: "San Francisco Bay Area",
                    size: "1.2 GB",
                    isDownloaded: false,
                    action: {}
                )
            }

            Section("Downloads") {
                Toggle("Automatic Updates", isOn: $automaticUpdates)
                Toggle("Optimize Storage", isOn: $optimizeStorage)
            }
        }
        .navigationTitle("Offline Maps")
    }
}

struct OfflineMapRow: View {
    let title: String
    let size: String
    let isDownloaded: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "map.fill")
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(size)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: action) {
                Image(systemName: isDownloaded ? "checkmark.circle.fill" : "arrow.down.circle")
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
    }
}

struct MapPreferencesView: View {
    @State private var travelMode = TravelPreference.driving
    @State private var avoidTolls = false
    @State private var avoidHighways = false
    @State private var walkingAvoidHills = false
    @State private var walkingAvoidBusyRoads = false
    @State private var walkingAvoidStairs = false
    @State private var cyclingAvoidHills = false
    @State private var cyclingAvoidBusyRoads = false
    @State private var preferredTransit: Set<TransitPreference> = Set(TransitPreference.allCases)
    @State private var photoCreditEnabled = false
    @State private var photoNickname = ""

    var body: some View {
        Form {
            Section("Preferred Travel") {
                Picker("Travel Mode", selection: $travelMode) {
                    ForEach(TravelPreference.allCases) { mode in
                        Label(mode.title, systemImage: mode.symbol)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            RouteAvoidanceSection(
                travelMode: travelMode,
                avoidTolls: $avoidTolls,
                avoidHighways: $avoidHighways,
                walkingAvoidHills: $walkingAvoidHills,
                walkingAvoidBusyRoads: $walkingAvoidBusyRoads,
                walkingAvoidStairs: $walkingAvoidStairs,
                cyclingAvoidHills: $cyclingAvoidHills,
                cyclingAvoidBusyRoads: $cyclingAvoidBusyRoads
            )

            TransitPreferencesSection(preferredTransit: $preferredTransit)

            Section {
                Toggle(isOn: $photoCreditEnabled) {
                    Label("Enable Photo Credit", systemImage: "camera.fill")
                }

                if photoCreditEnabled {
                    TextField("Public nickname", text: $photoNickname)
                }
            } header: {
                Text("Photo Credit")
            } footer: {
                Text("Get public credit by a nickname you choose for all your photos on Maps. Changes may take a few days to apply.")
            }
        }
        .navigationTitle("Preferences")
    }
}

struct RouteAvoidanceSection: View {
    let travelMode: TravelPreference
    @Binding var avoidTolls: Bool
    @Binding var avoidHighways: Bool
    @Binding var walkingAvoidHills: Bool
    @Binding var walkingAvoidBusyRoads: Bool
    @Binding var walkingAvoidStairs: Bool
    @Binding var cyclingAvoidHills: Bool
    @Binding var cyclingAvoidBusyRoads: Bool

    var body: some View {
        Section("Avoid When Routing") {
            switch travelMode {
            case .driving:
                Toggle(isOn: $avoidTolls) {
                    Label("Tolls", systemImage: "dollarsign.circle")
                }
                Toggle(isOn: $avoidHighways) {
                    Label("Highways", systemImage: "road.lanes")
                }
            case .walking:
                Toggle(isOn: $walkingAvoidHills) {
                    Label("Hills", systemImage: "mountain.2")
                }
                Toggle(isOn: $walkingAvoidBusyRoads) {
                    Label("Busy Roads", systemImage: "car.2.fill")
                }
                Toggle(isOn: $walkingAvoidStairs) {
                    Label("Stairs", systemImage: "stairs")
                }
            case .transit:
                Text("Choose preferred transit types below.")
                    .foregroundStyle(.secondary)
            case .cycling:
                Toggle(isOn: $cyclingAvoidHills) {
                    Label("Hills", systemImage: "mountain.2")
                }
                Toggle(isOn: $cyclingAvoidBusyRoads) {
                    Label("Busy Roads", systemImage: "car.2.fill")
                }
            }
        }
    }
}

struct TransitPreferencesSection: View {
    @Binding var preferredTransit: Set<TransitPreference>

    var body: some View {
        Section("Preferred Transit Types") {
            ForEach(TransitPreference.allCases) { transit in
                Button {
                    if preferredTransit.contains(transit) {
                        preferredTransit.remove(transit)
                    } else {
                        preferredTransit.insert(transit)
                    }
                } label: {
                    HStack {
                        Label(transit.title, systemImage: transit.symbol)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: preferredTransit.contains(transit) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(preferredTransit.contains(transit) ? .blue : .secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

enum TravelPreference: String, CaseIterable, Identifiable {
    case driving
    case walking
    case transit
    case cycling

    var id: String { rawValue }

    var title: String {
        switch self {
        case .driving: "Drive"
        case .walking: "Walk"
        case .transit: "Transit"
        case .cycling: "Cycle"
        }
    }

    var symbol: String {
        switch self {
        case .driving: "car.fill"
        case .walking: "figure.walk"
        case .transit: "tram.fill"
        case .cycling: "bicycle"
        }
    }
}

enum TransitPreference: String, CaseIterable, Identifiable {
    case bus
    case subway
    case lightRail
    case commuterRail
    case ferry

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bus: "Bus"
        case .subway: "Subway"
        case .lightRail: "Light Rail"
        case .commuterRail: "Commuter Rail"
        case .ferry: "Ferry"
        }
    }

    var symbol: String {
        switch self {
        case .bus: "bus.fill"
        case .subway: "tram.fill"
        case .lightRail: "lightrail.fill"
        case .commuterRail: "train.side.front.car"
        case .ferry: "ferry.fill"
        }
    }
}

enum HomeSheet: String, Identifiable {
    case profile
    case community
    case find

    var id: String { rawValue }
}

struct ModalCloseButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.glass)
        .accessibilityLabel("Close")
    }
}
