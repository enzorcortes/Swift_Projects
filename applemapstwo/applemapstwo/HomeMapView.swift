import SwiftUI
import MapKit

struct MapHomeView: View {
    @State private var cameraPosition = MapCameraPosition.region(.newYorkCity)
    @State private var presentedSheet: HomeSheet?
    @State private var initialFindCategory = FindCategory.people
    @State private var initialFindTrackedItem: TrackedItem?
    @State private var selectedPlace: Place?
    @State private var selectedEvent: CityEvent?
    @State private var searchText = ""
    @State private var isShowingMapOptions = false
    @State private var isFindOverlayMenuPresented = false
    @State private var isFindOverlayEnabled = true
    @State private var visibleFindCategories: Set<FindCategory> = [.people, .devices, .items]
    @State private var hiddenTrackedItemIDs: Set<String> = []
    @State private var isEventFilterPresented = false
    @State private var isEventOverlayEnabled = true
    @State private var visibleEventSources: Set<EventSource> = Set(EventSource.allCases)
    @State private var hiddenEventIDs: Set<String> = []
    @State private var demoTimestamp = Date()

    private let places = Place.samples
    private let trackedItems = TrackedItem.samples
    private let events = CityEvent.samples

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $cameraPosition) {
                ForEach(places) { place in
                    Annotation(place.name, coordinate: place.coordinate) {
                        Button {
                            selectedPlace = place
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(place.color.gradient)
                                    .frame(width: 38, height: 38)
                                Image(systemName: place.symbol)
                                    .foregroundStyle(.white)
                            }
                            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                        }
                        .accessibilityLabel("\(place.name), \(place.rating.formatted()) stars")
                    }
                }

                if isEventOverlayEnabled {
                    ForEach(events) { event in
                        if visibleEventSources.contains(event.source), !hiddenEventIDs.contains(event.id) {
                            Annotation(event.title, coordinate: event.coordinate) {
                                Button {
                                    selectedEvent = event
                                } label: {
                                    EventMarker(event: event)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(event.title), \(event.timing)")
                            }
                        }
                    }
                }

                if isFindOverlayEnabled {
                    ForEach(trackedItems) { item in
                        if visibleFindCategories.contains(item.category), !hiddenTrackedItemIDs.contains(item.id) {
                            Annotation(item.name, coordinate: item.demoCoordinate(at: demoTimestamp)) {
                                Button {
                                    initialFindCategory = item.category
                                    initialFindTrackedItem = nil
                                    presentedSheet = .find
                                } label: {
                                    TrackerMarker(
                                        initials: item.initials,
                                        symbol: item.symbol,
                                        color: item.color,
                                        isPerson: item.category == .people
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Open \(item.name) in Find My, \(item.status)")
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapCompass()
            }
            .ignoresSafeArea()

            HomeMapControls(
                isFindEnabled: isFindOverlayEnabled,
                isEventsEnabled: isEventOverlayEnabled,
                onMapOptions: { isShowingMapOptions = true },
                onLocate: {
                    withAnimation {
                        cameraPosition = .region(.newYorkCity)
                    }
                },
                onEventFilter: {
                    isEventFilterPresented = true
                },
                onFindFilter: {
                    isFindOverlayMenuPresented = true
                },
                onFind: {
                    initialFindCategory = .people
                    initialFindTrackedItem = nil
                    presentedSheet = .find
                }
            )

            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HomeInlineSearchResults(
                    searchText: searchText,
                    places: places,
                    trackedItems: trackedItems,
                    onSelectPlace: { place in
                        selectedPlace = place
                        searchText = ""
                        withAnimation {
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: place.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
                                )
                            )
                        }
                    },
                    onSelectTrackedItem: { item in
                        searchText = ""
                        initialFindCategory = item.category
                        initialFindTrackedItem = item
                        presentedSheet = .find
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            HomeSearchDock(
                searchText: $searchText,
                onProfile: { presentedSheet = .profile }
            )
        }
        .animation(.smooth, value: searchText.isEmpty)
        .task {
            await runFindDemoClock()
        }
        .confirmationDialog("Map Options", isPresented: $isShowingMapOptions) {
            Button("Explore") {
                cameraPosition = .region(.newYorkCity)
            }
            Button("Transit") {
                cameraPosition = .region(.newYorkCityTransit)
            }
            Button(isFindOverlayEnabled ? "Hide Find My Layer" : "Show Find My Layer") {
                withAnimation(.smooth) {
                    isFindOverlayEnabled.toggle()
                }
            }
            Button(isEventOverlayEnabled ? "Hide Events Layer" : "Show Events Layer") {
                withAnimation(.smooth) {
                    isEventOverlayEnabled.toggle()
                }
            }
            Button("Event Filters") {
                isEventFilterPresented = true
            }
            Button("Find My Visibility") {
                isFindOverlayMenuPresented = true
            }
            Button("Cancel", role: .cancel) {
            }
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .profile:
                HomeProfileSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(.clear)
            case .community:
                CommunityView()
                    .overlay(alignment: .topTrailing) {
                        ModalCloseButton()
                            .padding()
                    }
            case .find:
                FindView(
                    initialCategory: initialFindCategory,
                    initialTrackedItem: initialFindTrackedItem
                )
                    .overlay(alignment: .topTrailing) {
                        ModalCloseButton()
                            .padding()
                    }
            }
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailView(place: place)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $isEventFilterPresented) {
            EventFilterView(
                isEnabled: $isEventOverlayEnabled,
                visibleSources: $visibleEventSources,
                hiddenEventIDs: $hiddenEventIDs,
                events: events
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(.ultraThinMaterial)
        }
        .sheet(isPresented: $isFindOverlayMenuPresented) {
            FindOverlaySettings(
                isEnabled: $isFindOverlayEnabled,
                visibleCategories: $visibleFindCategories,
                hiddenItemIDs: $hiddenTrackedItemIDs,
                items: trackedItems,
                openFullFind: {
                    isFindOverlayMenuPresented = false
                    Task { @MainActor in
                        presentedSheet = .find
                    }
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .presentationBackground(.ultraThinMaterial)
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

struct HomeMapControls: View {
    let isFindEnabled: Bool
    let isEventsEnabled: Bool
    let onMapOptions: () -> Void
    let onLocate: () -> Void
    let onEventFilter: () -> Void
    let onFindFilter: () -> Void
    let onFind: () -> Void

    var body: some View {
        GlassEffectContainer(spacing: 10) {
            VStack(spacing: 10) {
                Button(action: onMapOptions) {
                    Image(systemName: "map.fill")
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Map options")

                Button(action: onLocate) {
                    Image(systemName: "location.fill")
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Center on your location")

                Button(action: onEventFilter) {
                    Image(systemName: isEventsEnabled ? "calendar.badge.clock" : "calendar")
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.glass)
                .tint(isEventsEnabled ? .orange : .secondary)
                .accessibilityLabel("Filter events map layer")

                Button(action: onFindFilter) {
                    Image(systemName: isFindEnabled ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.glass)
                .tint(isFindEnabled ? .green : .secondary)
                .accessibilityLabel("Filter Find My map layer")

                Button(action: onFind) {
                    Image("FindMyLogo")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Find people, devices, and items")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
        }
        .shadow(color: .black.opacity(0.24), radius: 10, y: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.trailing, 16)
        .padding(.bottom, 108)
    }
}
