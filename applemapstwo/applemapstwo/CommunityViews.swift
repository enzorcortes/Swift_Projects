import SwiftUI

// MARK: - Community

struct CommunityView: View {
    @State private var selectedFilter = CommunityFilter.friends

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CommunityPrivacyBanner()

                    Picker("Review feed", selection: $selectedFilter) {
                        ForEach(CommunityFilter.allCases) { filter in
                            Text(filter.title)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)

                    CommunityFeed(reviews: CommunityReview.feed)
                }
                .padding()
            }
            .background(.quaternary.opacity(0.25))
            .navigationTitle("Community")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Community settings")
                }
            }
        }
    }
}

struct CommunityPrivacyBanner: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "person.2.badge.gearshape.fill")
                .font(.title)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 3) {
                Text("Your map, your circle")
                    .font(.headline)
                Text("Share visits and reviews with everyone, friends, or only you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct CommunityFeed: View {
    let reviews: [CommunityReview]

    var body: some View {
        LazyVStack(spacing: 14) {
            ForEach(reviews) { review in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(review.placeName, systemImage: "mappin.circle.fill")
                            .font(.headline)
                        Spacer()
                        Text(review.relativeDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    ReviewCard(review: review)

                    HStack {
                        Button {
                        } label: {
                            Label("Helpful", systemImage: "hand.thumbsup")
                        }

                        Spacer()

                        Button {
                        } label: {
                            Label("Save Place", systemImage: "bookmark")
                        }
                    }
                    .font(.subheadline.weight(.medium))
                }
                .padding()
                .background(.background, in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}
