import SwiftUI

struct MainTabView: View {
    let store: ConstellationStore

    var body: some View {
        TabView {
            Tab("Social Map", systemImage: "point.3.connected.trianglepath.dotted") {
                SocialMapView(store: store)
            }
            Tab("Bulletin", systemImage: "text.bubble.fill") {
                BulletinView(store: store)
            }
            Tab("Circles", systemImage: "bubble.left.and.bubble.right.fill") {
                GroupsView(store: store)
            }
            Tab("Calendar", systemImage: "calendar") {
                CalendarView(store: store)
            }
            Tab("Profile", systemImage: "person.crop.circle.fill") {
                ProfileView(store: store)
            }
        }
    }
}

struct BulletinView: View {
    let store: ConstellationStore
    @State private var isPresentingComposer = false

    var body: some View {
        NavigationStack {
            List {
                if let group = store.selectedGroup {
                    GroupHeader(
                        name: group.name,
                        tagline: group.tagline,
                        memberCount: group.memberIDs.count,
                        updateCount: store.selectedGroupPosts.count,
                        symbol: group.symbol,
                        groups: store.groups,
                        onSelectGroup: { store.selectedGroupID = $0 },
                        onPost: { isPresentingComposer = true }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Latest updates") {
                    ForEach(store.selectedGroupPosts) { post in
                        NavigationLink(value: post.id) {
                            PostRow(
                                authorName: store.person(withID: post.authorID)?.name ?? "Unknown",
                                contentText: post.body,
                                createdAt: post.createdAt,
                                isAnonymous: post.isAnonymous,
                                isPinned: post.isPinned,
                                locationName: post.locationName,
                                reactions: post.reactions,
                                commentCount: post.comments.count
                            )
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                store.togglePin(for: post.id)
                            } label: {
                                Label(post.isPinned ? "Unpin" : "Pin", systemImage: "pin.fill")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
            .navigationTitle("The Bulletin")
            .navigationDestination(for: UUID.self) { postID in
                PostDetailView(store: store, postID: postID)
            }
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
                ComposePostView(store: store)
            }
        }
    }
}

private struct GroupHeader: View {
    let name: String
    let tagline: String
    let memberCount: Int
    let updateCount: Int
    let symbol: String
    let groups: [FriendGroup]
    let onSelectGroup: (UUID) -> Void
    let onPost: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .frame(width: 82, height: 82)
                .background(.purple.gradient, in: RoundedRectangle(cornerRadius: 24))
                .shadow(color: .purple.opacity(0.25), radius: 12)
                .accessibilityHidden(true)
            Text(name)
                .font(.title2.bold())
            Text(tagline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 22) {
                Label("\(memberCount)", systemImage: "person.2.fill")
                Label("\(updateCount)", systemImage: "text.bubble.fill")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.purple)
            HStack {
                Menu {
                    ForEach(groups) { group in
                        Button(group.name, systemImage: group.symbol) { onSelectGroup(group.id) }
                    }
                } label: {
                    Label("Switch Circle", systemImage: "arrow.triangle.2.circlepath")
                }
                Button(action: onPost) {
                    Label("Share Update", systemImage: "square.and.pencil")
                }
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }
}

private struct PostRow: View {
    let authorName: String
    let contentText: String
    let createdAt: Date
    let isAnonymous: Bool
    let isPinned: Bool
    let locationName: String?
    let reactions: Int
    let commentCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(isAnonymous ? "Anonymous member" : authorName,
                      systemImage: isAnonymous ? "theatermasks.fill" : "person.crop.circle.fill")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(.orange)
                        .accessibilityLabel("Pinned")
                }
                Text(createdAt, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(contentText)
                .font(.body)
                .lineLimit(4)
            HStack(spacing: 16) {
                if let locationName {
                    Label(locationName, systemImage: "mappin.and.ellipse")
                }
                Label("\(reactions)", systemImage: "sparkles")
                Label("\(commentCount)", systemImage: "bubble.left")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

struct ComposePostView: View {
    let store: ConstellationStore
    var destinationGroupID: UUID? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var bodyText = ""
    @State private var locationName = ""
    @State private var isAnonymous = false
    @State private var taggedPersonID: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ComposePostHeader()
                }
                .listRowBackground(Color.clear)

                Section("The update") {
                    ComposeUpdateEditor(text: $bodyText)
                }

                Section("People and privacy") {
                    Picker("Who is this about?", selection: $taggedPersonID) {
                        Text("No one in particular").tag(nil as UUID?)
                        ForEach(store.people) { person in
                            Text(person.name).tag(person.id as UUID?)
                        }
                    }
                    Toggle("Post anonymously", isOn: $isAnonymous)
                }

                Section("Optional context") {
                    TextField("Place or neighborhood (optional)", text: $locationName)
                    Label("Locations are entered manually and are visible only to this group.", systemImage: "location.slash.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if isAnonymous {
                    Section("Anonymous posting") {
                        Label("Your identity is hidden from members, but the service retains it for safety and moderation.", systemImage: "shield.lefthalf.filled")
                            .font(.footnote)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Update")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        store.addPost(
                            body: bodyText,
                            isAnonymous: isAnonymous,
                            locationName: locationName,
                            taggedPersonID: taggedPersonID,
                            groupID: destinationGroupID
                        )
                        dismiss()
                    }
                    .disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .composeSheetPresentation()
    }
}

private struct ComposeUpdateEditor: View {
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("Share an update with your group")
                    .foregroundStyle(.secondary.opacity(0.62))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 140, alignment: .topLeading)
                .accessibilityLabel("Share an update with your group")
        }
    }
}

private struct ComposePostHeader: View {
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "square.and.pencil.circle.fill")
                .font(.system(.largeTitle))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .orange)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("Post to the bulletin")
                    .font(.title2.bold())
                Text("Share the update, tag who it involves, and add only the context your circle needs.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

private extension View {
    @ViewBuilder
    func composeSheetPresentation() -> some View {
        #if os(macOS)
        self
            .frame(minWidth: 520, minHeight: 650)
            .presentationSizing(.form)
        #else
        self
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationSizing(.form)
        #endif
    }
}

struct PostDetailView: View {
    let store: ConstellationStore
    let postID: UUID
    @State private var commentText = ""

    private var post: BulletinPost? {
        store.posts.first { $0.id == postID }
    }

    var body: some View {
        List {
            if let post {
                Section {
                    PostDetailHeader(
                        authorName: store.person(withID: post.authorID)?.name ?? "Unknown",
                        contentText: post.body,
                        createdAt: post.createdAt,
                        isAnonymous: post.isAnonymous,
                        locationName: post.locationName
                    )
                }
                Section("Conversation") {
                    if post.comments.isEmpty {
                        ContentUnavailableView("No comments yet", systemImage: "bubble.left", description: Text("Start the conversation."))
                    } else {
                        ForEach(post.comments) { comment in
                            CommentRow(authorName: comment.authorName, contentText: comment.body)
                        }
                    }
                }
                Section {
                    HStack {
                        TextField("Add a comment", text: $commentText)
                        Button("Send") {
                            store.addComment(commentText, to: postID)
                            commentText = ""
                        }
                        .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    Button {
                        store.toggleReaction(for: postID)
                    } label: {
                        Label("React with sparkle (\(post.reactions))", systemImage: "sparkles")
                    }
                    Button(role: .destructive) {} label: {
                        Label("Report this update", systemImage: "exclamationmark.bubble")
                    }
                }
            } else {
                ContentUnavailableView("Update unavailable", systemImage: "questionmark.bubble")
            }
        }
        .navigationTitle("Update")
    }
}

private struct PostDetailHeader: View {
    let authorName: String
    let contentText: String
    let createdAt: Date
    let isAnonymous: Bool
    let locationName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(isAnonymous ? "Anonymous member" : authorName,
                  systemImage: isAnonymous ? "theatermasks.fill" : "person.crop.circle.fill")
                .font(.headline)
            Text(contentText)
                .font(.title3)
            if let locationName {
                Label(locationName, systemImage: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)
            }
            Text(createdAt, format: .dateTime.weekday().month().day().hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

private struct CommentRow: View {
    let authorName: String
    let contentText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(authorName)
                .font(.subheadline.bold())
            Text(contentText)
        }
    }
}
