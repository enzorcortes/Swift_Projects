import SwiftUI
import MapKit

// MARK: - Find

struct FindOverlaySettings: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isEnabled: Bool
    @Binding var visibleCategories: Set<FindCategory>
    @Binding var hiddenItemIDs: Set<String>
    let items: [TrackedItem]
    let openFullFind: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Toggle(isOn: masterVisibilityBinding) {
                        Label {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Show Find My on Map")
                                    .font(.headline)
                                Text("Turn off the complete Find My layer.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image("FindMyLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                                .clipShape(Circle())
                        }
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))

                    if isEnabled {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Visible Categories")
                                .font(.headline)

                            ForEach(FindCategory.mapFilterCases) { category in
                                Toggle(isOn: categoryVisibilityBinding(for: category)) {
                                    Label(category.title, systemImage: category.symbol)
                                        .font(.body.weight(.medium))
                                }
                                .padding(.horizontal, 14)
                                .frame(minHeight: 50)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Individual Visibility")
                                .font(.headline)

                            ForEach(items) { item in
                                if visibleCategories.contains(item.category) {
                                    Toggle(isOn: visibilityBinding(for: item.id)) {
                                        Label {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.name)
                                                Text("\(item.category.title) · \(item.status)")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        } icon: {
                                            Image(systemName: item.symbol)
                                                .foregroundStyle(item.color)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .frame(minHeight: 54)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
                                }
                            }
                        }
                    }

                    Button(action: openFullFind) {
                        Label("Open Full Find Experience", systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(20)
            }
            .background(.ultraThinMaterial)
            .navigationTitle("Find My Filters")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.glass)
                    .accessibilityLabel("Close Find My filters")
                }
            }
        }
    }

    private var masterVisibilityBinding: Binding<Bool> {
        Binding(
            get: { isEnabled },
            set: { newValue in
                isEnabled = newValue
                if newValue, visibleCategories.isEmpty {
                    visibleCategories = Set(FindCategory.mapFilterCases)
                }
            }
        )
    }

    private func categoryVisibilityBinding(for category: FindCategory) -> Binding<Bool> {
        Binding(
            get: { visibleCategories.contains(category) },
            set: { isVisible in
                if isVisible {
                    visibleCategories.insert(category)
                } else {
                    visibleCategories.remove(category)
                }
            }
        )
    }

    private func visibilityBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { !hiddenItemIDs.contains(id) },
            set: { isVisible in
                if isVisible {
                    hiddenItemIDs.remove(id)
                } else {
                    hiddenItemIDs.insert(id)
                }
            }
        )
    }
}

struct FindView: View {
    @State private var cameraPosition = MapCameraPosition.region(.newYorkCity)
    @State private var selectedCategory: FindCategory
    @State private var selectedTrackedItem: TrackedItem?
    @State private var isSharingLocation = true
    @State private var demoTimestamp = Date()

    private let trackedItems = TrackedItem.samples

    init(
        initialCategory: FindCategory = .people,
        initialTrackedItem: TrackedItem? = nil
    ) {
        _selectedCategory = State(initialValue: initialCategory)
        _selectedTrackedItem = State(initialValue: initialTrackedItem)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            FindMap(
                cameraPosition: $cameraPosition,
                items: trackedItems,
                demoTimestamp: demoTimestamp,
                selectedCategory: selectedCategory,
                selectedItem: $selectedTrackedItem
            )
            .ignoresSafeArea()

            FindMapControls(
                onMapOptions: {},
                onLocate: {
                    withAnimation {
                        cameraPosition = .region(.newYorkCity)
                    }
                }
            )

            FindPanel(
                selectedCategory: $selectedCategory,
                items: trackedItems,
                isSharingLocation: $isSharingLocation,
                onSelect: focus
            )
        }
        .animation(.smooth, value: selectedCategory)
        .task {
            await runFindDemoClock()
        }
        .sheet(item: $selectedTrackedItem) { item in
            TrackedItemDetail(item: item)
                .presentationDetents([.height(330)])
                .presentationDragIndicator(.hidden)
        }
    }

    private func focus(_ item: TrackedItem) {
        selectedTrackedItem = item
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: item.demoCoordinate(at: demoTimestamp),
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                )
            )
        }
    }

    private func runFindDemoClock() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.linear(duration: 1)) {
                demoTimestamp = Date()
            }
        }
    }
}

struct FindMap: View {
    @Binding var cameraPosition: MapCameraPosition
    let items: [TrackedItem]
    let demoTimestamp: Date
    let selectedCategory: FindCategory
    @Binding var selectedItem: TrackedItem?

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(items) { item in
                if item.category == selectedCategory {
                    Annotation(item.name, coordinate: item.demoCoordinate(at: demoTimestamp)) {
                        Button {
                            selectedItem = item
                        } label: {
                            TrackerMarker(
                                initials: item.initials,
                                symbol: item.symbol,
                                color: item.color,
                                isPerson: item.category == .people
                            )
                        }
                        .accessibilityLabel("\(item.name), \(item.status)")
                    }
                }
            }

            if selectedCategory == .me {
                Annotation("My Location", coordinate: .findDemoLocation) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 34, height: 34)
                        Circle()
                            .fill(.blue)
                            .frame(width: 25, height: 25)
                    }
                    .shadow(radius: 4)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
        }
    }
}

struct FindMapControls: View {
    let onMapOptions: () -> Void
    let onLocate: () -> Void

    var body: some View {
        GlassEffectContainer(spacing: 8) {
            VStack(spacing: 8) {
                Button(action: onMapOptions) {
                    Image(systemName: "map.fill")
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Map options")

                Button(action: onLocate) {
                    Image(systemName: "location.fill")
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Center map")
            }
            .font(.system(size: 17, weight: .semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(.top, 58)
        .padding(.trailing, 16)
    }
}

struct TrackerMarker: View {
    let initials: String
    let symbol: String
    let color: Color
    let isPerson: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(.background)
                .frame(width: 52, height: 52)
                .shadow(color: .black.opacity(0.22), radius: 5, y: 2)

            Circle()
                .fill(color.gradient)
                .frame(width: 44, height: 44)

            if isPerson {
                Text(initials)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            } else {
                Image(systemName: symbol)
                    .foregroundStyle(.white)
            }
        }
    }
}

struct FindPanel: View {
    @Binding var selectedCategory: FindCategory
    let items: [TrackedItem]
    @Binding var isSharingLocation: Bool
    let onSelect: (TrackedItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.white.opacity(0.38))
                .frame(width: 38, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 8)

            FindPanelHeader(title: "Find My")

            ScrollView {
                FindCategoryAccordion(
                    selectedCategory: $selectedCategory,
                    items: items,
                    isSharingLocation: $isSharingLocation,
                    onSelect: onSelect
                )
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
            .frame(minHeight: 190, maxHeight: 360)
        }
        .frame(maxWidth: 620)
        .background(.clear)
        .glassEffect(.regular, in: .rect(cornerRadius: 34))
        .padding(.horizontal, 10)
        .padding(.bottom, 6)
    }
}

struct FindCategoryAccordion: View {
    @Binding var selectedCategory: FindCategory
    let items: [TrackedItem]
    @Binding var isSharingLocation: Bool
    let onSelect: (TrackedItem) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(FindCategory.allCases) { category in
                DisclosureGroup(
                    isExpanded: expansionBinding(for: category)
                ) {
                    FindCategoryContent(
                        selectedCategory: category,
                        items: items,
                        isSharingLocation: $isSharingLocation,
                        onSelect: onSelect
                    )
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: category.symbol)
                            .foregroundStyle(selectedCategory == category ? .blue : .primary)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.title)
                                .font(.headline)
                            Text(category.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, 10)
                }
                .tint(.primary)
                .padding(.horizontal, 12)
                .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private func expansionBinding(for category: FindCategory) -> Binding<Bool> {
        Binding(
            get: { selectedCategory == category },
            set: { isExpanded in
                if isExpanded {
                    withAnimation(.smooth) {
                        selectedCategory = category
                    }
                }
            }
        )
    }
}

struct FindPanelHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle.bold())

            Spacer()

            Button {
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.medium))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.glass)
            .accessibilityLabel("Add")
        }
        .padding(.leading, 18)
        .padding(.trailing, 68)
        .padding(.bottom, 6)
    }
}

struct FindCategoryContent: View {
    let selectedCategory: FindCategory
    let items: [TrackedItem]
    @Binding var isSharingLocation: Bool
    let onSelect: (TrackedItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            switch selectedCategory {
            case .people, .devices:
                ForEach(items) { item in
                    if item.category == selectedCategory {
                        FindListRow(
                            name: item.name,
                            detail: item.status,
                            trailing: item.category == .people ? "Nearby" : "With You",
                            initials: item.initials,
                            symbol: item.symbol,
                            color: item.color,
                            isPerson: item.category == .people,
                            action: { onSelect(item) }
                        )
                    }
                }
            case .items:
                ForEach(items) { item in
                    if item.category == .items {
                        FindListRow(
                            name: item.name,
                            detail: item.status,
                            trailing: "With You",
                            initials: item.initials,
                            symbol: item.symbol,
                            color: item.color,
                            isPerson: false,
                            action: { onSelect(item) }
                        )
                    }
                }

                Button {
                } label: {
                    Label("Identify Found Item", systemImage: "magnifyingglass.circle.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 18)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            case .me:
                FindMeContent(isSharingLocation: $isSharingLocation)
            }
        }
    }
}

struct FindListRow: View {
    let name: String
    let detail: String
    let trailing: String
    let initials: String
    let symbol: String
    let color: Color
    let isPerson: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Circle()
                    .fill(color.gradient)
                    .frame(width: 48, height: 48)
                    .overlay {
                        if isPerson {
                            Text(initials)
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        } else {
                            Image(systemName: symbol)
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(trailing)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

        Divider()
            .padding(.leading, 62)
    }
}

struct FindMeContent: View {
    @Binding var isSharingLocation: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("San Francisco, CA")
                .font(.title3)

            VStack(spacing: 0) {
                Label("My Location", systemImage: "location.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 16)

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Shared From")
                        Text("This iPhone")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "iphone")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 16)

                Divider()

                Toggle(isOn: $isSharingLocation) {
                    Label("Share My Location", systemImage: "person.wave.2.fill")
                }
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 16)
            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 22))
        }
    }
}

struct FindTabBar: View {
    @Binding var selectedCategory: FindCategory

    var body: some View {
        HStack(spacing: 4) {
            ForEach(FindCategory.allCases) { category in
                Button {
                    selectedCategory = category
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: category.symbol)
                            .font(.title3)
                        Text(category.title)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(selectedCategory == category ? .blue : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(
                        selectedCategory == category ? .black.opacity(0.26) : .clear,
                        in: Capsule()
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .glassEffect(.regular, in: .capsule)
    }
}

struct TrackedItemCard: View {
    let name: String
    let status: String
    let symbol: String
    let initials: String
    let color: Color
    let isPerson: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Circle()
                .fill(color.gradient)
                .frame(width: 42, height: 42)
                .overlay {
                    if isPerson {
                        Text(initials)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: symbol)
                            .foregroundStyle(.white)
                    }
                }

            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(status)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 130, alignment: .leading)
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct TrackedItemDetail: View {
    let item: TrackedItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                TrackerMarker(
                    initials: item.initials,
                    symbol: item.symbol,
                    color: item.color,
                    isPerson: item.category == .people
                )

                VStack(spacing: 4) {
                    Text(item.name)
                        .font(.title2.bold())
                    Text(item.status)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Button {
                    } label: {
                        Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                    } label: {
                        Label(item.category == .people ? "Contact" : "Play Sound", systemImage: item.category == .people ? "message.fill" : "speaker.wave.2.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .controlSize(.large)
            }
            .padding()
            .navigationTitle(item.category.title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close item details")
                }
            }
        }
    }
}
