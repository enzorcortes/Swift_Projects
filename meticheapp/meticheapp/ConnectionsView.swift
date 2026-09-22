import SwiftUI

struct ConnectionsView: View {
    let store: ConstellationStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    ConnectionsIntro()
                    RelationshipDiagram(people: store.people, relationships: store.relationships)
                    RelationshipLegend()
                    RelationshipList(people: store.people, relationships: store.relationships)
                }
                .padding()
            }
            .navigationTitle("Connections")
        }
    }
}

private struct ConnectionsIntro: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("The social map")
                .font(.title2.bold())
            Text("Confirmed connections use solid lines. Unconfirmed context stays clearly marked and private to the group.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RelationshipDiagram: View {
    let people: [Person]
    let relationships: [Relationship]

    var body: some View {
        GeometryReader { geometry in
            let positions = nodePositions(in: geometry.size, count: people.count)
            ZStack {
                ForEach(relationships) { relationship in
                    if let firstIndex = people.firstIndex(where: { $0.id == relationship.firstPersonID }),
                       let secondIndex = people.firstIndex(where: { $0.id == relationship.secondPersonID }),
                       positions.indices.contains(firstIndex), positions.indices.contains(secondIndex) {
                        RelationshipLine(
                            start: positions[firstIndex],
                            end: positions[secondIndex],
                            color: relationship.status.color,
                            isConfirmed: relationship.isConfirmed
                        )
                    }
                }
                ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                    PersonNode(name: person.name, initials: person.initials, color: person.color)
                        .position(positions[index])
                }
            }
        }
        .frame(height: 320)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Relationship diagram")
    }

    private func nodePositions(in size: CGSize, count: Int) -> [CGPoint] {
        guard count > 0 else { return [] }
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) * 0.34
        return (0..<count).map { index in
            let angle = (Double(index) / Double(count)) * 2 * Double.pi - Double.pi / 2
            return CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
        }
    }
}

private struct RelationshipLine: View {
    let start: CGPoint
    let end: CGPoint
    let color: Color
    let isConfirmed: Bool

    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(color, style: StrokeStyle(lineWidth: 4, dash: isConfirmed ? [] : [7, 6]))
        .accessibilityHidden(true)
    }
}

private struct PersonNode: View {
    let name: String
    let initials: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text(initials)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(color.gradient, in: Circle())
            Text(name)
                .font(.caption.bold())
        }
        .accessibilityElement(children: .combine)
    }
}

private struct RelationshipLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Legend")
                .font(.headline)
            ViewThatFits {
                HStack(spacing: 16) {
                    ForEach(Relationship.Status.allCases) { status in
                        LegendItem(title: status.rawValue, color: status.color)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Relationship.Status.allCases) { status in
                        LegendItem(title: status.rawValue, color: status.color)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct LegendItem: View {
    let title: String
    let color: Color

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Circle().fill(color).frame(width: 10, height: 10)
        }
        .font(.caption)
    }
}

private struct RelationshipList: View {
    let people: [Person]
    let relationships: [Relationship]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What connects them")
                .font(.headline)
            ForEach(relationships) { relationship in
                let firstName = people.first { $0.id == relationship.firstPersonID }?.name ?? "Unknown"
                let secondName = people.first { $0.id == relationship.secondPersonID }?.name ?? "Unknown"
                RelationshipCard(
                    firstName: firstName,
                    secondName: secondName,
                    status: relationship.status,
                    note: relationship.note,
                    isConfirmed: relationship.isConfirmed
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RelationshipCard: View {
    let firstName: String
    let secondName: String
    let status: Relationship.Status
    let note: String?
    let isConfirmed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("\(firstName) + \(secondName)")
                    .font(.subheadline.bold())
                Spacer()
                Text(isConfirmed ? "Confirmed" : "Unconfirmed")
                    .font(.caption)
                    .foregroundStyle(isConfirmed ? .green : .secondary)
            }
            Label(status.rawValue, systemImage: "link")
                .foregroundStyle(status.color)
            if let note {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct DigestView: View {
    let store: ConstellationStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DigestHero()
                    DigestStats(postCount: store.selectedGroupPosts.count, memberCount: store.selectedGroup?.memberIDs.count ?? 0)
                    DigestHighlights(posts: Array(store.selectedGroupPosts.prefix(3)))
                }
                .padding()
            }
            .navigationTitle("Weekly Digest")
        }
    }
}

private struct DigestHero: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Friday edition", systemImage: "calendar.badge.clock")
                .font(.headline)
                .foregroundStyle(.purple)
            Text("Previously, in your circle…")
                .font(.largeTitle.bold())
            Text("A quick recap of the updates your group shared this week.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DigestStats: View {
    let postCount: Int
    let memberCount: Int

    var body: some View {
        HStack(spacing: 12) {
            StatCard(value: postCount, label: "Updates", symbol: "text.bubble")
            StatCard(value: memberCount, label: "Insiders", symbol: "person.2")
        }
    }
}

private struct StatCard: View {
    let value: Int
    let label: String
    let symbol: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .foregroundStyle(.purple)
            Text("\(value)")
                .font(.title.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct DigestHighlights: View {
    let posts: [BulletinPost]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Highlights")
                .font(.title2.bold())
            ForEach(posts) { post in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: post.isPinned ? "pin.fill" : "sparkles")
                        .foregroundStyle(post.isPinned ? .orange : .purple)
                        .frame(width: 24)
                    Text(post.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

struct ProfileView: View {
    let store: ConstellationStore
    @State private var appearsInIntroductions = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 16) {
                        if let currentUser = store.person(withID: store.currentUserID) {
                            EditableAvatarView(store: store, person: currentUser, size: 112)
                        }
                        Text(store.displayName.isEmpty ? "Sam" : store.displayName)
                            .font(.largeTitle.bold())
                        Text("Your Constella Account")
                            .foregroundStyle(.secondary)
                        HStack(spacing: 0) {
                            ProfileMetric(value: "\(store.groups.count)", label: "Circles")
                                .frame(maxWidth: .infinity)
                            Divider().frame(height: 34)
                            ProfileMetric(value: "\(store.relationships(for: store.currentUserID).count)", label: "Connections")
                                .frame(maxWidth: .infinity)
                            Divider().frame(height: 34)
                            ProfileMetric(value: "\(store.posts.count)", label: "Updates")
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .listRowInsets(EdgeInsets(top: 18, leading: 22, bottom: 18, trailing: 22))

                Section("Constella Account") {
                    NavigationLink(value: ProfileDestination.personalInformation) {
                        ProfileMenuLabel(title: "Personal Information", subtitle: "Name, photo, and contact card", symbol: "person.text.rectangle", color: .blue)
                    }
                    NavigationLink(value: ProfileDestination.circlesAndSharing) {
                        ProfileMenuLabel(title: "Circles & Sharing", subtitle: "Who can see your relationships", symbol: "person.2.circle.fill", color: .purple)
                    }
                    NavigationLink(value: ProfileDestination.connectedServices) {
                        ProfileMenuLabel(title: "Connected Services", subtitle: "Calendars and event providers", symbol: "link.circle.fill", color: .orange)
                    }
                }
                .profileSettingsRowSpacing()

                Section("Discoverability") {
                    Toggle(isOn: $appearsInIntroductions) {
                        ProfileMenuLabel(title: "Mutual Introductions", subtitle: "Let trusted circles show how you connect", symbol: "point.3.connected.trianglepath.dotted", color: .mint)
                    }
                    .toggleStyle(.switch)
                    NavigationLink(value: ProfileDestination.notifications) {
                        ProfileMenuLabel(title: "Notifications", subtitle: "Bulletins, events, and circle activity", symbol: "bell.badge.fill", color: .red)
                    }
                }
                .profileSettingsRowSpacing()

                Section("Privacy & Safety") {
                    NavigationLink(value: ProfileDestination.privacy) {
                        ProfileMenuLabel(title: "Privacy & Safety", subtitle: "Visibility, blocks, and reports", symbol: "lock.shield.fill", color: .green)
                    }
                    NavigationLink(value: ProfileDestination.data) {
                        ProfileMenuLabel(title: "Your Data", subtitle: "Export or remove your information", symbol: "internaldrive.fill", color: .gray)
                    }
                }
                .profileSettingsRowSpacing()
            }
            .navigationTitle("Account")
            .navigationDestination(for: ProfileDestination.self) { destination in
                ProfileSettingsDetail(destination: destination)
            }
        }
    }
}

private enum ProfileDestination: String, Hashable {
    case personalInformation = "Personal Information"
    case circlesAndSharing = "Circles & Sharing"
    case connectedServices = "Connected Services"
    case notifications = "Notifications"
    case privacy = "Privacy & Safety"
    case data = "Your Data"
}

private struct ProfileMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.title2.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct ProfileMenuLabel: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 3)
        .contentShape(Rectangle())
    }
}

private extension View {
    func profileSettingsRowSpacing() -> some View {
        listRowInsets(EdgeInsets(top: 9, leading: 18, bottom: 9, trailing: 18))
    }
}

private struct ProfileSettingsDetail: View {
    let destination: ProfileDestination

    var body: some View {
        List {
            Section {
                ContentUnavailableView(
                    destination.rawValue,
                    systemImage: symbol,
                    description: Text("This prototype is ready for the account service that will power these settings.")
                )
            }
        }
        .navigationTitle(destination.rawValue)
    }

    private var symbol: String {
        switch destination {
        case .personalInformation: "person.text.rectangle"
        case .circlesAndSharing: "person.2.circle.fill"
        case .connectedServices: "link.circle.fill"
        case .notifications: "bell.badge.fill"
        case .privacy: "lock.shield.fill"
        case .data: "internaldrive.fill"
        }
    }
}
