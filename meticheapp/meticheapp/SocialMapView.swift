import SwiftUI

struct SocialMapView: View {
    let store: ConstellationStore
    @State private var selectedPersonID: UUID?
    @State private var hoveredPersonID: UUID?
    @State private var isPresentingComposer = false
    @State private var selectedPlaceID: UUID?

    private var focusedPersonID: UUID? {
        hoveredPersonID ?? selectedPersonID
    }

    private var selectedPlace: FriendGroup? {
        guard let selectedPlaceID else { return nil }
        return store.group(withID: selectedPlaceID)
    }

    private var visiblePeople: [Person] {
        guard let selectedPlace else { return store.people }
        return store.people.filter { selectedPlace.memberIDs.contains($0.id) }
    }

    private var visibleRelationships: [Relationship] {
        let ids = Set(visiblePeople.map(\.id))
        return store.relationships.filter { ids.contains($0.firstPersonID) && ids.contains($0.secondPersonID) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ConstellaHomeHeader()
                    if let selectedPlace {
                        PlaceDetailHeader(place: selectedPlace) {
                            withAnimation(.smooth) {
                                selectedPlaceID = nil
                                selectedPersonID = nil
                                hoveredPersonID = nil
                            }
                        }
                        SocialMapIntroduction()
                        SocialGraphDiagram(
                            people: visiblePeople,
                            relationships: visibleRelationships,
                            groups: [selectedPlace],
                            currentUserID: store.currentUserID,
                            selectedGroupID: selectedPlace.id,
                            focusedPersonID: focusedPersonID,
                            selectedPersonID: selectedPersonID,
                            eventCount: { store.posts(about: $0, in: selectedPlace.id).count },
                            onSelect: { personID in
                                withAnimation(.snappy) {
                                    selectedPersonID = selectedPersonID == personID ? nil : personID
                                }
                            },
                            onHover: { personID in
                                withAnimation(.easeOut(duration: 0.18)) {
                                    hoveredPersonID = personID
                                }
                            }
                        )
                        if let focusedPersonID,
                           let person = store.person(withID: focusedPersonID) {
                            FocusedPersonCard(
                                person: person,
                                connections: visibleRelationships.filter { $0.includes(focusedPersonID) },
                                people: visiblePeople,
                                relatedPosts: store.posts(about: focusedPersonID, in: selectedPlace.id)
                            )
                        }
                        SocialMapLegend()
                        AccessibleConnectionsList(people: visiblePeople, relationships: visibleRelationships)
                    } else {
                        SocialAtlasIntroduction()
                        SocialAtlasOverview(
                            groups: store.groups,
                            people: store.people,
                            currentUserID: store.currentUserID,
                            updateCount: { store.posts(for: $0).count },
                            onSelect: { groupID in
                                withAnimation(.smooth) { selectedPlaceID = groupID }
                            }
                        )
                        AtlasKey()
                    }
                }
                .padding()
            }
            .navigationTitle("Constella")
            .navigationDestination(for: Person.self) { person in
                RelationshipProfileView(store: store, person: person)
            }
            .toolbar {
                if selectedPlace != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            isPresentingComposer = true
                        } label: {
                            Label("Post update", systemImage: "square.and.pencil")
                        }
                    }
                }
            }
            .sheet(isPresented: $isPresentingComposer) {
                ComposePostView(store: store, destinationGroupID: selectedPlaceID)
            }
        }
    }
}

private struct SocialAtlasIntroduction: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your social atlas")
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)
            Text("Places, organizations, and moments that brought your people together. Select a hub to enter its relationship map.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SocialAtlasOverview: View {
    let groups: [FriendGroup]
    let people: [Person]
    let currentUserID: UUID
    let updateCount: (UUID) -> Int
    let onSelect: (UUID) -> Void

    var body: some View {
        GeometryReader { geometry in
            let positions = positions(in: geometry.size)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height * 0.52)
            ZStack {
                ForEach(groupLinks) { link in
                    if let start = positions[link.firstGroupID], let end = positions[link.secondGroupID] {
                        AtlasLink(
                            start: start,
                            end: end,
                            colors: link.sharedPersonIDs.compactMap { personID in
                                people.first(where: { $0.id == personID })?.color
                            }
                        )
                    }
                }
                ForEach(groups.filter { $0.memberIDs.contains(currentUserID) }) { group in
                    if let end = positions[group.id] {
                        UserCircleLink(start: center, end: end)
                    }
                }
                ForEach(groups) { group in
                    AtlasHub(
                        group: group,
                        memberColors: people.filter { group.memberIDs.contains($0.id) && $0.id != currentUserID }.map(\.color),
                        memberNames: memberNames(for: group),
                        updateCount: updateCount(group.id),
                        action: { onSelect(group.id) }
                    )
                    .position(positions[group.id] ?? .zero)
                }
                if let currentUser = people.first(where: { $0.id == currentUserID }) {
                    AtlasCurrentUser(person: currentUser)
                        .position(center)
                }
            }
        }
        .frame(minHeight: 540)
        .background(
            RadialGradient(colors: [Color.blue.opacity(0.07), Color.secondary.opacity(0.025)], center: .center, startRadius: 20, endRadius: 330),
            in: RoundedRectangle(cornerRadius: 28)
        )
        .overlay { RoundedRectangle(cornerRadius: 28).stroke(Color.secondary.opacity(0.12)) }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Social atlas of connected places")
    }

    private var groupLinks: [AtlasGroupLink] {
        var links: [AtlasGroupLink] = []
        for firstIndex in groups.indices {
            for secondIndex in groups.indices where secondIndex > firstIndex {
                let secondMembers = Set(groups[secondIndex].memberIDs).subtracting([currentUserID])
                let sharedPersonIDs = groups[firstIndex].memberIDs.filter {
                    $0 != currentUserID && secondMembers.contains($0)
                }
                if !sharedPersonIDs.isEmpty {
                    links.append(
                        AtlasGroupLink(
                            firstGroupID: groups[firstIndex].id,
                            secondGroupID: groups[secondIndex].id,
                            sharedPersonIDs: sharedPersonIDs
                        )
                    )
                }
            }
        }
        return links
    }

    private func positions(in size: CGSize) -> [UUID: CGPoint] {
        let layout: [CGPoint] = [
            CGPoint(x: 0.50, y: 0.16), CGPoint(x: 0.23, y: 0.39),
            CGPoint(x: 0.74, y: 0.38), CGPoint(x: 0.31, y: 0.76),
            CGPoint(x: 0.72, y: 0.76), CGPoint(x: 0.50, y: 0.52)
        ]
        return Dictionary(uniqueKeysWithValues: groups.enumerated().map { index, group in
            let point = layout[index % layout.count]
            return (group.id, CGPoint(x: point.x * size.width, y: point.y * size.height))
        })
    }

    private func memberNames(for group: FriendGroup) -> String {
        let names = people.filter { group.memberIDs.contains($0.id) }.prefix(3).map(\.name)
        return names.formatted(.list(type: .and))
    }
}

private struct UserCircleLink: View {
    let start: CGPoint
    let end: CGPoint

    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(Color.white.opacity(0.38), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        .accessibilityHidden(true)
    }
}

private struct AtlasGroupLink: Identifiable {
    let firstGroupID: UUID
    let secondGroupID: UUID
    let sharedPersonIDs: [UUID]
    var id: String { firstGroupID.uuidString + secondGroupID.uuidString }
}

private struct AtlasLink: View {
    let start: CGPoint
    let end: CGPoint
    let colors: [Color]

    var body: some View {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let length = max(hypot(deltaX, deltaY), 1)
        let normalX = -deltaY / length
        let normalY = deltaX / length

        ZStack {
            ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                let strandOffset = (CGFloat(index) - CGFloat(colors.count - 1) / 2) * 4
                Path { path in
                    path.move(to: CGPoint(x: start.x + normalX * strandOffset, y: start.y + normalY * strandOffset))
                    path.addLine(to: CGPoint(x: end.x + normalX * strandOffset, y: end.y + normalY * strandOffset))
                }
                .stroke(
                    color.opacity(0.82),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [6, 7])
                )
                .shadow(color: color.opacity(0.24), radius: 2)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct AtlasHub: View {
    let group: FriendGroup
    let memberColors: [Color]
    let memberNames: String
    let updateCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    OrbitingMembers(colors: memberColors, isTemporary: group.isTemporary)
                    Circle()
                        .fill(group.isTemporary ? AnyShapeStyle(Color.orange.gradient) : AnyShapeStyle(LinearGradient(colors: [.gray, .blue.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing)))
                        .frame(width: group.isTemporary ? 82 : 94, height: group.isTemporary ? 82 : 94)
                        .shadow(color: (group.isTemporary ? Color.orange : Color.gray).opacity(0.3), radius: 12)
                    Image(systemName: group.symbol)
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    if updateCount > 0 {
                        Text("\(updateCount)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(.red, in: Circle())
                            .offset(x: 36, y: -36)
                    }
                }
                Text(group.name)
                    .font(.caption.bold())
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 120)
                if group.isTemporary {
                    Label(group.externalProvider.map { "From \($0.rawValue)" } ?? "Live event", systemImage: "clock.fill")
                        .font(.caption2.bold())
                        .foregroundStyle(.orange)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(group.name)
        .accessibilityValue("\(group.memberIDs.count) people including \(memberNames), \(updateCount) updates")
        .accessibilityHint("Opens this circle’s three dimensional relationship map")
    }
}

private struct OrbitingMembers: View {
    let colors: [Color]
    let isTemporary: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { context in
            let phase = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate * (isTemporary ? 0.72 : 0.42)
            ZStack {
                Circle()
                    .stroke((isTemporary ? Color.orange : Color.secondary).opacity(0.34), lineWidth: 1)
                    .frame(width: 122, height: 76)
                ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                    let angle = phase + Double(index) / Double(max(colors.count, 1)) * 2 * Double.pi
                    Circle()
                        .fill(color.gradient)
                        .frame(width: index.isMultiple(of: 3) ? 11 : 8, height: index.isMultiple(of: 3) ? 11 : 8)
                        .shadow(color: color.opacity(0.65), radius: 4)
                        .offset(x: cos(angle) * 61, y: sin(angle) * 38)
                }
            }
        }
        .frame(width: 132, height: 92)
        .accessibilityHidden(true)
    }
}

private struct AtlasCurrentUser: View {
    let person: Person

    var body: some View {
        VStack(spacing: 4) {
            AvatarView(imageData: person.avatarData, initials: person.initials, color: person.color, size: 78)
                .overlay { Circle().stroke(.white, lineWidth: 4) }
                .shadow(color: .white.opacity(0.28), radius: 14)
            Text("You")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("You, at the center of your circles")
    }
}

private struct PlaceDetailHeader: View {
    let place: FriendGroup
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onClose) {
                Image(systemName: "arrow.down.right.and.arrow.up.left")
                    .font(.headline)
                    .frame(width: 40, height: 40)
                    .background(Color.secondary.opacity(0.1), in: Circle())
            }
            .accessibilityLabel("Return to social atlas")
            Image(systemName: place.symbol)
                .foregroundStyle(place.isTemporary ? .orange : .purple)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name).font(.headline)
                Text("\(place.memberIDs.count) people · \(place.tagline)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let provider = place.externalProvider {
                    Text("Event information from \(provider.rawValue)")
                        .font(.caption2.bold())
                        .foregroundStyle(.orange)
                }
            }
            Spacer()
        }
    }
}

private struct AtlasKey: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Lines show people shared between circles", systemImage: "point.3.connected.trianglepath.dotted")
            Label("Orange hubs are temporary events", systemImage: "party.popper.fill")
            Label("Tap any hub to explore its people and relationships", systemImage: "viewfinder")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ConstellaHomeHeader: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("ConstellaLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 92, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .shadow(color: .blue.opacity(0.22), radius: 16)
                .accessibilityHidden(true)
            Text("Constella")
                .font(.largeTitle.bold())
            Text("Your private social atlas")
                .foregroundStyle(.secondary)
            HStack(spacing: 18) {
                Label("Places", systemImage: "mappin.and.ellipse")
                Label("People", systemImage: "person.2.fill")
                Label("Events", systemImage: "calendar")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.purple)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

private struct SocialMapIntroduction: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("The social map")
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)
            Text("Drag to rotate your social universe. Select an orbit, then tap a person to follow their connections.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct GroupOrbitSelector: View {
    let groups: [FriendGroup]
    @Binding var selection: UUID?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 9) {
                orbitButton(title: "All orbits", symbol: "circle.grid.cross.fill", id: nil)
                ForEach(groups) { group in
                    orbitButton(title: group.name, symbol: group.symbol, id: group.id)
                }
            }
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("Choose a social orbit")
    }

    private func orbitButton(title: String, symbol: String, id: UUID?) -> some View {
        Button {
            withAnimation(.snappy) { selection = id }
        } label: {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selection == id ? Color.purple.opacity(0.2) : Color.secondary.opacity(0.08), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selection == id ? .isSelected : [])
    }
}

private struct SocialGraphDiagram: View {
    let people: [Person]
    let relationships: [Relationship]
    let groups: [FriendGroup]
    let currentUserID: UUID
    let selectedGroupID: UUID?
    let focusedPersonID: UUID?
    let selectedPersonID: UUID?
    let eventCount: (UUID) -> Int
    let onSelect: (UUID) -> Void
    let onHover: (UUID?) -> Void
    @State private var yaw: CGFloat = 0
    @State private var pitch: CGFloat = 0.18
    @GestureState private var dragOffset = CGSize.zero

    var body: some View {
        GeometryReader { geometry in
            let activeYaw = yaw + dragOffset.width * 0.012
            let activePitch = clampedPitch(pitch - dragOffset.height * 0.006)
            let positions = positions(in: geometry.size, yaw: activeYaw, pitch: activePitch)
            ZStack {
                ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                    OrbitRing(
                        name: group.name,
                        color: orbitColor(index),
                        radius: orbitRadius(index, in: geometry.size),
                        pitch: activePitch,
                        isSelected: selectedGroupID == nil || selectedGroupID == group.id
                    )
                }
                ForEach(relationships) { relationship in
                    if let start = positions[relationship.firstPersonID]?.point,
                       let end = positions[relationship.secondPersonID]?.point {
                        SocialGraphLine(
                            start: start,
                            end: end,
                            color: relationship.status.color,
                            isMutual: relationship.isConfirmed,
                            isEmphasized: isEmphasized(relationship),
                            isDimmed: isDimmed(relationship)
                        )
                    }
                }
                ForEach(people) { person in
                    SocialGraphPersonButton(
                        person: person,
                        isCurrentUser: person.id == currentUserID,
                        bodyRole: celestialRole(for: person.id),
                        isSelected: selectedPersonID == person.id,
                        isDimmed: isPersonDimmed(person.id) || isOutsideSelectedOrbit(person.id),
                        connectionCount: relationships.filter { $0.includes(person.id) }.count,
                        eventCount: eventCount(person.id),
                        onSelect: { onSelect(person.id) },
                        onHover: { isHovering in onHover(isHovering ? person.id : nil) }
                    )
                    .scaleEffect(positions[person.id]?.scale ?? 1)
                    .position(positions[person.id]?.point ?? .zero)
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 5)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        yaw += value.translation.width * 0.012
                        pitch = clampedPitch(pitch - value.translation.height * 0.006)
                    }
            )
        }
        .frame(minHeight: 520)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Interactive three dimensional social map")
        .accessibilityHint("Drag to rotate the map, or select a person")
    }

    private func positions(in size: CGSize, yaw: CGFloat, pitch: CGFloat) -> [UUID: ProjectedPosition] {
        guard !people.isEmpty else { return [:] }
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        var result = [currentUserID: ProjectedPosition(point: center, scale: 1.08)]
        var assignedIDs = Set<UUID>()

        for (groupIndex, group) in groups.enumerated() {
            let members = people.filter {
                $0.id != currentUserID && group.memberIDs.contains($0.id) && !assignedIDs.contains($0.id)
            }
            let radius = orbitRadius(groupIndex, in: size)
            let inclination = CGFloat(groupIndex - 1) * 0.34
            for (memberIndex, person) in members.enumerated() {
                let angle = CGFloat(memberIndex) / CGFloat(max(members.count, 1)) * 2 * .pi - .pi / 2 + CGFloat(groupIndex) * 0.45
                let baseX = cos(angle) * radius
                let baseY = sin(angle) * radius * cos(inclination)
                let baseZ = sin(angle) * radius * sin(inclination)
                let rotatedX = baseX * cos(yaw) + baseZ * sin(yaw)
                let rotatedZ = -baseX * sin(yaw) + baseZ * cos(yaw)
                let rotatedY = baseY * cos(pitch) - rotatedZ * sin(pitch)
                let depth = baseY * sin(pitch) + rotatedZ * cos(pitch)
                let perspective = min(max(1 + depth / max(size.width, size.height) * 0.38, 0.76), 1.22)
                result[person.id] = ProjectedPosition(
                    point: CGPoint(x: center.x + rotatedX * perspective, y: center.y + rotatedY * perspective),
                    scale: perspective
                )
                assignedIDs.insert(person.id)
            }
        }
        return result
    }

    private func orbitRadius(_ index: Int, in size: CGSize) -> CGFloat {
        let shortestSide = min(size.width, size.height)
        let count = max(groups.count, 1)
        let inner = shortestSide * 0.19
        let outer = shortestSide * 0.43
        guard count > 1 else { return shortestSide * 0.32 }
        return inner + (outer - inner) * CGFloat(index) / CGFloat(count - 1)
    }

    private func orbitColor(_ index: Int) -> Color {
        [.purple, .cyan, .orange, .pink, .green][index % 5]
    }

    private func clampedPitch(_ value: CGFloat) -> CGFloat {
        min(max(value, -0.72), 0.72)
    }

    private func isOutsideSelectedOrbit(_ personID: UUID) -> Bool {
        guard personID != currentUserID,
              let selectedGroupID,
              let group = groups.first(where: { $0.id == selectedGroupID }) else { return false }
        return !group.memberIDs.contains(personID)
    }

    private func celestialRole(for personID: UUID) -> CelestialRole {
        if personID == currentUserID { return .sun }
        if let direct = relationships.first(where: { $0.includes(currentUserID) && $0.includes(personID) }) {
            return direct.status == .closeFriends ? .planet : .moon
        }
        return relationships.filter { $0.includes(personID) }.count > 1 ? .moon : .asteroid
    }

    private func isEmphasized(_ relationship: Relationship) -> Bool {
        guard let focusedPersonID else { return false }
        return relationship.includes(focusedPersonID)
    }

    private func isDimmed(_ relationship: Relationship) -> Bool {
        guard let focusedPersonID else { return false }
        return !relationship.includes(focusedPersonID)
    }

    private func isPersonDimmed(_ personID: UUID) -> Bool {
        guard let focusedPersonID else { return false }
        if personID == focusedPersonID { return false }
        return !relationships.contains { $0.includes(focusedPersonID) && $0.includes(personID) }
    }
}

private struct ProjectedPosition {
    let point: CGPoint
    let scale: CGFloat
}

private struct OrbitRing: View {
    let name: String
    let color: Color
    let radius: CGFloat
    let pitch: CGFloat
    let isSelected: Bool

    var body: some View {
        Ellipse()
            .stroke(color.opacity(isSelected ? 0.34 : 0.08), style: StrokeStyle(lineWidth: isSelected ? 2 : 1, dash: [7, 7]))
            .frame(width: radius * 2, height: max(radius * 0.68, radius * 2 * abs(cos(pitch)) * 0.62))
            .overlay(alignment: .top) {
                Text(name)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(color.opacity(isSelected ? 0.9 : 0.3))
                    .padding(.horizontal, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .accessibilityHidden(true)
    }
}

private enum CelestialRole: String {
    case sun = "Sun"
    case planet = "Planet"
    case moon = "Moon"
    case asteroid = "Asteroid"

    var size: CGFloat {
        switch self {
        case .sun: 78
        case .planet: 62
        case .moon: 52
        case .asteroid: 44
        }
    }
}

private struct SocialGraphLine: View {
    let start: CGPoint
    let end: CGPoint
    let color: Color
    let isMutual: Bool
    let isEmphasized: Bool
    let isDimmed: Bool

    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(
            color.opacity(isDimmed ? 0.12 : 0.9),
            style: StrokeStyle(
                lineWidth: isEmphasized ? 6 : 4,
                lineCap: .round,
                dash: isMutual ? [] : [7, 6]
            )
        )
        .accessibilityHidden(true)
    }
}

private struct SocialGraphPersonButton: View {
    let person: Person
    let isCurrentUser: Bool
    let bodyRole: CelestialRole
    let isSelected: Bool
    let isDimmed: Bool
    let connectionCount: Int
    let eventCount: Int
    let onSelect: () -> Void
    let onHover: (Bool) -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                AvatarView(
                    imageData: person.avatarData,
                    initials: person.initials,
                    color: person.color,
                    size: isSelected ? bodyRole.size + 8 : bodyRole.size
                )
                    .overlay {
                        Circle().stroke(.white, lineWidth: isSelected ? 4 : 0)
                    }
                    .shadow(color: isCurrentUser ? .yellow.opacity(0.7) : person.color.opacity(isSelected ? 0.55 : 0.25), radius: isCurrentUser ? 18 : (isSelected ? 12 : 5))
                    .overlay(alignment: .topTrailing) {
                        if eventCount > 0 {
                            Text("\(eventCount)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(6)
                                .background(.red, in: Circle())
                                .offset(x: 5, y: -5)
                                .accessibilityHidden(true)
                        }
                    }
                Text(person.name)
                    .font(.caption.bold())
                if isCurrentUser {
                    Text("You")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .opacity(isDimmed ? 0.28 : 1)
            .scaleEffect(isSelected ? 1.05 : 1)
        }
        .buttonStyle(.plain)
        .onHover(perform: onHover)
        .accessibilityLabel(person.name)
        .accessibilityValue("\(bodyRole.rawValue), \(connectionCount) visible connections, \(eventCount) relevant updates\(isSelected ? ", selected" : "")")
        .accessibilityHint("Select to highlight this person’s relationships")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct FocusedPersonCard: View {
    let person: Person
    let connections: [Relationship]
    let people: [Person]
    let relatedPosts: [BulletinPost]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(person.name)
                        .font(.title3.bold())
                    Text("\(connections.count) visible connections")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                NavigationLink(value: person) {
                    Label("View profile", systemImage: "arrow.right.circle.fill")
                }
            }
            ForEach(connections.prefix(3)) { relationship in
                if let otherID = relationship.otherPersonID(than: person.id),
                   let other = people.first(where: { $0.id == otherID }) {
                    HStack {
                        Circle().fill(relationship.status.color).frame(width: 9, height: 9)
                        Text(other.name)
                            .fontWeight(.semibold)
                        Text("· \(relationship.status.rawValue)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(relationship.isConfirmed ? "Mutual" : "One perspective")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if let latestPost = relatedPosts.first {
                Divider()
                Label("Latest update", systemImage: "text.bubble.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.red)
                Text(latestPost.body)
                    .font(.subheadline)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.purple.opacity(0.09), in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct SocialMapLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Legend")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            ViewThatFits {
                HStack(spacing: 16) {
                    ForEach(Relationship.Status.allCases) { status in
                        SocialMapLegendItem(status: status)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Relationship.Status.allCases) { status in
                        SocialMapLegendItem(status: status)
                    }
                }
            }
            Text("Solid lines are mutual. Dashed lines show one shared perspective.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SocialMapLegendItem: View {
    let status: Relationship.Status

    var body: some View {
        Label {
            Text(status.rawValue)
        } icon: {
            Circle().fill(status.color).frame(width: 10, height: 10)
        }
        .font(.caption)
    }
}

private struct AccessibleConnectionsList: View {
    let people: [Person]
    let relationships: [Relationship]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Browse every connection")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            ForEach(people) { person in
                NavigationLink(value: person) {
                    HStack {
                        Text(person.name)
                        Spacer()
                        Text("\(relationships.filter { $0.includes(person.id) }.count)")
                            .foregroundStyle(.secondary)
                    }
                }
                Divider()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RelationshipProfileView: View {
    let store: ConstellationStore
    let person: Person
    @State private var isEditingPerspective = false

    var body: some View {
        List {
            Section {
                RelationshipProfileHeader(person: person)
            }
            Section("Relationship perspectives") {
                ForEach(store.relationships(for: person.id)) { relationship in
                    RelationshipPerspectiveCard(
                        focusPersonID: person.id,
                        relationship: relationship,
                        people: store.people
                    )
                }
            }
            Section("Privacy") {
                Label("Only each author can edit their perspective", systemImage: "person.badge.key.fill")
                Label("Referenced people can report or hide a connection", systemImage: "hand.raised.fill")
            }
        }
        .navigationTitle(person.name)
        .toolbar {
            if person.id != store.currentUserID {
                ToolbarItem(placement: .primaryAction) {
                    Button("My perspective") {
                        isEditingPerspective = true
                    }
                }
            }
        }
        .sheet(isPresented: $isEditingPerspective) {
            PerspectiveEditorView(store: store, otherPerson: person)
        }
    }
}

private struct RelationshipProfileHeader: View {
    let person: Person

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(
                imageData: person.avatarData,
                initials: person.initials,
                color: person.color,
                size: 64
            )
            VStack(alignment: .leading, spacing: 3) {
                Text(person.name)
                    .font(.title2.bold())
                Text(person.handle)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

private struct RelationshipPerspectiveCard: View {
    let focusPersonID: UUID
    let relationship: Relationship
    let people: [Person]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let otherID = relationship.otherPersonID(than: focusPersonID),
               let other = people.first(where: { $0.id == otherID }) {
                HStack {
                    Text("With \(other.name)")
                        .font(.headline)
                    Spacer()
                    Text(relationship.isConfirmed ? "Mutual" : "One perspective")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            ForEach(relationship.perspectives) { perspective in
                PerspectiveStatement(perspective: perspective, people: people)
            }
        }
        .padding(.vertical, 5)
    }
}

private struct PerspectiveStatement: View {
    let perspective: RelationshipPerspective
    let people: [Person]

    var body: some View {
        let authorName = people.first { $0.id == perspective.authorID }?.name ?? "Unknown"
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(perspective.status.rawValue, systemImage: "quote.bubble.fill")
                    .foregroundStyle(perspective.status.color)
                Spacer()
                Label(perspective.visibility.rawValue, systemImage: "eye.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !perspective.note.isEmpty {
                Text(perspective.note)
            }
            Text("Written by \(authorName) · Updated \(perspective.updatedAt, format: .relative(presentation: .named))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }
}

private struct PerspectiveEditorView: View {
    let store: ConstellationStore
    let otherPerson: Person
    @Environment(\.dismiss) private var dismiss
    @State private var status: Relationship.Status
    @State private var note: String
    @State private var visibility: RelationshipPerspective.Visibility

    init(store: ConstellationStore, otherPerson: Person) {
        self.store = store
        self.otherPerson = otherPerson
        let existing = store.relationships
            .first { $0.includes(store.currentUserID) && $0.includes(otherPerson.id) }?
            .perspectives.first { $0.authorID == store.currentUserID }
        _status = State(initialValue: existing?.status ?? .friends)
        _note = State(initialValue: existing?.note ?? "")
        _visibility = State(initialValue: existing?.visibility ?? .onlyMe)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("How do you describe this connection?") {
                    Picker("Relationship", selection: $status) {
                        ForEach(Relationship.Status.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    TextField("Add context in your own words", text: $note, axis: .vertical)
                        .lineLimit(3...7)
                }
                Section("Who can see it?") {
                    Picker("Visibility", selection: $visibility) {
                        ForEach(RelationshipPerspective.Visibility.allCases) { visibility in
                            Text(visibility.rawValue).tag(visibility)
                        }
                    }
                    Label("Only you can edit this perspective. \(otherPerson.name) may write a separate one.", systemImage: "lock.shield.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("My perspective on \(otherPerson.name)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.savePerspective(about: otherPerson.id, status: status, note: note, visibility: visibility)
                        dismiss()
                    }
                }
            }
        }
    }
}
