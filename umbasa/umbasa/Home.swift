import MapKit
import SwiftUI

struct HomeFeedView: View {
    @State private var posts = SampleData.feedPosts
    @State private var incomingUpdateIndex = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 18) {
                    HomeSearchView()
                    FeedHeroCard()
                    UpcomingSessionCard()

                    ForEach(posts) { post in
                        FeedPostCard(post: post)
                    }
                }
                .padding()
            }
            .refreshable {
                addIncomingUpdate()
            }
            .navigationTitle("Home")
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(15))
                    guard !Task.isCancelled else { return }
                    addIncomingUpdate()
                }
            }
        }
    }

    private func addIncomingUpdate() {
        guard !SampleData.incomingFeedPosts.isEmpty else { return }
        let update = SampleData.incomingFeedPosts[incomingUpdateIndex % SampleData.incomingFeedPosts.count]
        withAnimation {
            posts.removeAll { $0.id == update.id }
            posts.insert(update, at: 0)
        }
        incomingUpdateIndex += 1
    }
}

struct FeedHeroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Austin is moving", systemImage: "dot.radiowaves.left.and.right")
                .font(.headline)
                .foregroundStyle(.white)
            Text("14 territories changed hands today")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("The Bellyfloppers lead the city, but Front Desk Crew gained 1.8 mi² this morning.")
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: .rect(cornerRadius: 22)
        )
    }
}

struct UpcomingSessionCard: View {
    @State private var isJoining = false

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text("21").font(.title.bold())
                Text("SEP").font(.caption.bold())
            }
            .foregroundStyle(.white)
            .frame(width: 58, height: 64)
            .background(.orange.gradient, in: .rect(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text("Sunset 5K Training Run").font(.headline)
                Text("6:30 PM · Auditorium Shores").font(.subheadline).foregroundStyle(.secondary)
                Text("12 friends are interested").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(isJoining ? "Joined" : "Join") { isJoining.toggle() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: 20))
    }
}

struct FeedPostCard: View {
    let post: FeedPost
    @State private var isLiked = false
    @State private var showingComments = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: post.authorIcon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(post.tint.gradient, in: .circle)
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author)
                        .font(.headline)
                    Text(post.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: post.kind.systemImage)
                    .foregroundStyle(post.tint)
                    .accessibilityLabel(post.kind.title)
            }

            if post.kind == .territory {
                FeedMapSnapshot(post: post)
            }

            Text(post.title)
                .font(.title3.bold())
            Text(post.detail)
                .foregroundStyle(.secondary)

            HStack(spacing: 22) {
                Button {
                    isLiked.toggle()
                } label: {
                    Label("\(post.likeCount + (isLiked ? 1 : 0))", systemImage: isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(isLiked ? .red : .primary)
                }

                Button {
                    showingComments = true
                } label: {
                    Label("\(post.comments.count)", systemImage: "bubble.right")
                }

                Spacer()

                Button("Share", systemImage: "square.and.arrow.up") { }
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: 20))
        .sheet(isPresented: $showingComments) {
            CommentsView(post: post)
        }
    }
}

struct FeedMapSnapshot: View {
    let post: FeedPost

    var body: some View {
        ZStack {
            Map(initialPosition: .region(.austin)) {
                MapPolygon(coordinates: post.territory)
                    .foregroundStyle(post.tint.opacity(0.35))
                    .stroke(post.tint, lineWidth: 3)
            }
            .allowsHitTesting(false)

            VStack {
                Spacer()
                Text("Disputed territory")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: .capsule)
                    .padding(8)
            }
        }
        .frame(height: 190)
        .clipShape(.rect(cornerRadius: 16))
        .accessibilityLabel("Map showing disputed territory")
    }
}

struct CommentsView: View {
    let post: FeedPost
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var comments: [FeedComment]

    init(post: FeedPost) {
        self.post = post
        _comments = State(initialValue: post.comments)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List(comments) { comment in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.indigo)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(comment.author)
                                .font(.subheadline.bold())
                            Text(comment.text)
                        }
                    }
                }

                HStack {
                    TextField("Add a comment", text: $draft)
                        .textFieldStyle(.roundedBorder)
                    Button("Post") {
                        guard !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        comments.append(FeedComment(id: UUID(), author: "Trailblazer", text: draft))
                        draft = ""
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("Comments")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

