import SwiftUI
import MapKit

// MARK: - Place details and reviews

struct PlaceDetailView: View {
    let place: Place
    @Environment(\.dismiss) private var dismiss
    @State private var isWritingReview = false
    @State private var isSaved = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    PlaceHero(
                        name: place.name,
                        category: place.category,
                        symbol: place.symbol,
                        color: place.color
                    )

                    PlaceRatingSummary(
                        rating: place.rating,
                        reviewCount: place.reviewCount,
                        friendCount: place.friendCount
                    )

                    PlaceActions(
                        isSaved: $isSaved,
                        onReview: { isWritingReview = true }
                    )

                    ReviewSection(reviews: place.reviews)
                }
                .padding()
            }
            .navigationTitle(place.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.glass)
                    .accessibilityLabel("Close location details")
                }
            }
            .sheet(isPresented: $isWritingReview) {
                ReviewComposer(placeName: place.name)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        }
    }
}

struct PlaceHero: View {
    let name: String
    let category: String
    let symbol: String
    let color: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(color.gradient)

            Image(systemName: symbol)
                .font(.system(size: 86))
                .foregroundStyle(.white.opacity(0.35))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding(24)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.title.bold())
                Text(category)
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding(20)
        }
        .frame(height: 180)
    }
}

struct PlaceRatingSummary: View {
    let rating: Double
    let reviewCount: Int
    let friendCount: Int

    var body: some View {
        HStack(spacing: 0) {
            RatingMetric(
                value: rating.formatted(.number.precision(.fractionLength(1))),
                label: "\(reviewCount) reviews",
                symbol: "star.fill",
                color: .orange
            )

            Divider()
                .frame(height: 46)

            RatingMetric(
                value: "\(friendCount)",
                label: "friends visited",
                symbol: "person.2.fill",
                color: .blue
            )

            Divider()
                .frame(height: 46)

            RatingMetric(
                value: "92%",
                label: "recommend",
                symbol: "hand.thumbsup.fill",
                color: .green
            )
        }
        .padding()
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct RatingMetric: View {
    let value: String
    let label: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .foregroundStyle(color)
                Text(value)
                    .fontWeight(.bold)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PlaceActions: View {
    @Binding var isSaved: Bool
    let onReview: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button {
            } label: {
                Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button(action: onReview) {
                Label("Review", systemImage: "square.and.pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                isSaved.toggle()
            } label: {
                Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .controlSize(.large)
    }
}

struct ReviewSection: View {
    let reviews: [CommunityReview]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("From the community")
                    .font(.title3.bold())
                Spacer()
                Button("See All") {
                }
            }

            ForEach(reviews) { review in
                ReviewCard(review: review)
            }
        }
    }
}

struct ReviewCard: View {
    let review: CommunityReview

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(review.color.gradient)
                    .frame(width: 38, height: 38)
                    .overlay {
                        Text(review.initials)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text(review.author)
                            .font(.subheadline.weight(.semibold))
                        if review.isFriend {
                            Text("Friend")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.12), in: Capsule())
                        }
                    }
                    Text(review.relativeDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Label(review.rating.formatted(), systemImage: "star.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
            }

            Text(review.text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ReviewComposer: View {
    let placeName: String
    @Environment(\.dismiss) private var dismiss
    @State private var rating = 5
    @State private var reviewText = ""
    @State private var visibility = ReviewVisibility.everyone
    @State private var useAlias = false
    @State private var aliasName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        Spacer(minLength: 0)
                        ForEach(1...5, id: \.self) { value in
                            Button {
                                rating = value
                            } label: {
                                Image(systemName: value <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(.orange)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 12)

                    TextField(
                        "",
                        text: $reviewText,
                        prompt: Text("What should people know?")
                            .foregroundStyle(.tertiary),
                        axis: .vertical
                    )
                    .multilineTextAlignment(.leading)
                    .environment(\.layoutDirection, .leftToRight)
                    .lineLimit(5...10)
                    .frame(minHeight: 130, alignment: .topLeading)
                    .padding(.vertical, 6)
                    .accessibilityLabel("Write your review")
                } header: {
                    Text("Your experience")
                }

                Section {
                    Picker("Who can see this?", selection: $visibility) {
                        ForEach(ReviewVisibility.allCases) { option in
                            Label(option.title, systemImage: option.symbol)
                                .tag(option)
                        }
                    }

                    Toggle("Post with an alias", isOn: $useAlias)

                    if useAlias {
                        TextField(
                            "Alias",
                            text: $aliasName,
                            prompt: Text("Choose an alias")
                                .foregroundStyle(.tertiary)
                        )
                        .multilineTextAlignment(.leading)
                        .environment(\.layoutDirection, .leftToRight)

                        Text("Your alias will appear instead of your Apple Account name on this review.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("You control whether a review is public, shared with friends, or kept only for you.")
                }
                .animation(.smooth, value: useAlias)
            }
            .formStyle(.grouped)
            .contentMargins(.horizontal, 18)
            .navigationTitle("Review \(placeName)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close review")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canPost)
                }
            }
        }
    }

    private var canPost: Bool {
        let hasReview = !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasRequiredAlias = !useAlias
            || !aliasName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasReview && hasRequiredAlias
    }
}
