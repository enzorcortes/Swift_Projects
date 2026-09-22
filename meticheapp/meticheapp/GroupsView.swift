import SwiftUI

struct GroupsView: View {
    let store: ConstellationStore
    @State private var isCreatingGroup = false
    @State private var isImportingEvent = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    CirclesHeroHeader(
                        circleCount: store.groups.count,
                        eventCount: store.groups.filter(\.isTemporary).count,
                        onCreate: { isCreatingGroup = true },
                        onImport: { isImportingEvent = true }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Your circles") {
                    ForEach(store.groups) { group in
                        NavigationLink(value: group.id) {
                            GroupChannelRow(group: group, updateCount: store.posts(for: group.id).count)
                        }
                    }
                }
            }
            .navigationTitle("Circles")
            .navigationDestination(for: UUID.self) { groupID in
                if let group = store.group(withID: groupID) {
                    GroupChannelView(store: store, group: group)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Create a circle", systemImage: "person.3.fill") {
                            isCreatingGroup = true
                        }
                        Button("Import an event", systemImage: "link.badge.plus") {
                            isImportingEvent = true
                        }
                    } label: {
                        Label("Add circle", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isCreatingGroup) {
                CreateGroupView(store: store)
            }
            .sheet(isPresented: $isImportingEvent) {
                EventImportView(store: store)
            }
        }
    }
}

private struct CirclesHeroHeader: View {
    let circleCount: Int
    let eventCount: Int
    let onCreate: () -> Void
    let onImport: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 46))
                .foregroundStyle(.white)
                .frame(width: 86, height: 86)
                .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 25))
                .shadow(color: .blue.opacity(0.25), radius: 12)
            Text("Your Circles")
                .font(.largeTitle.bold())
            Text("The places and moments that brought your people together")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 22) {
                Label("\(circleCount) circles", systemImage: "person.3.fill")
                Label("\(eventCount) live", systemImage: "calendar.badge.clock")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.blue)
            HStack {
                Button("Create", systemImage: "plus", action: onCreate)
                Button("Import Event", systemImage: "link.badge.plus", action: onImport)
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
}

private struct GroupChannelRow: View {
    let group: FriendGroup
    let updateCount: Int

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: group.symbol)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(.orange.gradient, in: Circle())
                .shadow(color: .orange.opacity(0.35), radius: 8)
            VStack(alignment: .leading, spacing: 3) {
                Text(group.name).font(.headline)
                Text(group.tagline).font(.subheadline).foregroundStyle(.secondary)
                Text("\(group.memberIDs.count) members · \(updateCount) updates")
                    .font(.caption)
                    .foregroundStyle(.purple)
                if let provider = group.externalProvider {
                    Label("From \(provider.rawValue)", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption2.bold())
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct EventImportView: View {
    let store: ConstellationStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var linkText = ""
    @State private var endsAt = Date.now.addingTimeInterval(60 * 60 * 24)

    private var eventURL: URL? {
        guard let url = URL(string: linkText.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http" else { return nil }
        return url
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event source") {
                    TextField("Paste event link", text: $linkText)
                        .textContentType(.URL)
                        .autocorrectionDisabled()
                    if let eventURL {
                        Label("Recognized as \(ExternalEventProvider.detect(from: eventURL).rawValue)", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                }
                Section("Event details") {
                    TextField("Event name", text: $title)
                    DatePicker("Ends", selection: $endsAt, in: Date.now...)
                }
                Section {
                    Text("Constella keeps the original source link and clearly labels imported information. Automatic refresh depends on the provider offering an authorized API or calendar feed.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Import Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        guard let eventURL else { return }
                        store.importEvent(title: title, link: eventURL, endsAt: endsAt)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || eventURL == nil)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct GroupChannelView: View {
    let store: ConstellationStore
    let group: FriendGroup
    @State private var isPresentingComposer = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Label(group.name, systemImage: group.symbol)
                        .font(.title2.bold())
                    Text(group.tagline).foregroundStyle(.secondary)
                    Text("This group acts as its own sun on your social map.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                .padding(.vertical, 8)
            }
            Section("Channel updates") {
                let updates = store.posts(for: group.id)
                if updates.isEmpty {
                    ContentUnavailableView("No updates yet", systemImage: "text.bubble", description: Text("Start this group’s conversation."))
                } else {
                    ForEach(updates) { post in
                        VStack(alignment: .leading, spacing: 7) {
                            Text(post.isAnonymous ? "Anonymous member" : (store.person(withID: post.authorID)?.name ?? "Unknown"))
                                .font(.subheadline.bold())
                            Text(post.body)
                            Text(post.createdAt, format: .relative(presentation: .named))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle(group.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingComposer = true
                } label: {
                    Label("Post update", systemImage: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $isPresentingComposer) {
            ComposePostView(store: store, destinationGroupID: group.id)
        }
    }
}

private struct CreateGroupView: View {
    let store: ConstellationStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var tagline = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("New circle") {
                    TextField("Group name", text: $name)
                    TextField("What is this channel for?", text: $tagline, axis: .vertical)
                }
                Section {
                    Label("New groups begin with you as the first member. Invitations can be added next.", systemImage: "person.badge.plus")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Create Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        store.createGroup(name: name, tagline: tagline)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
