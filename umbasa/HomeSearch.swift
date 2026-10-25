import MapKit
import SwiftUI

struct HomeSearchView: View {
    @State private var query = ""
    @State private var matches: [HomeSearchEntry] = []
    @FocusState private var isFocused: Bool

    private var hasQuery: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search or ask with Umbasa AI", text: $query)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit { isFocused = false }
                    .accessibilityLabel("Search or ask with Umbasa AI")
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
                Image(systemName: "sparkles")
                    .foregroundStyle(.indigo)
                    .accessibilityHidden(true)
            }
            .padding(14)
            .background(.background.secondary, in: .rect(cornerRadius: 16))

            if isFocused && !hasQuery {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Try asking").font(.caption).foregroundStyle(.secondary)
                    Button("Who controls downtown Austin?") {
                        query = "Who controls downtown Austin?"
                        isFocused = false
                    }
                    Button("Find running events") {
                        query = "Find running events"
                        isFocused = false
                    }
                    Button("Shoes for practice") {
                        query = "Shoes for practice"
                        isFocused = false
                    }
                }
                .buttonStyle(.borderless)
                .font(.subheadline)
            }

            if hasQuery {
                Label("Umbasa AI · Demo", systemImage: "sparkles")
                    .font(.caption.bold())
                    .foregroundStyle(.indigo)
                if HomeSearchIndex.asksAboutDowntownControl(query) {
                    DowntownControlAnswer()
                }
                if matches.isEmpty {
                    ContentUnavailableView {
                        Label("No demo matches", systemImage: "magnifyingglass")
                    } description: {
                        Text("Try a name, running events, Nike, shoes, or downtown Austin.")
                    }
                } else {
                    Text("Explore results").font(.subheadline.bold())
                    ForEach(matches) { entry in
                        NavigationLink {
                            HomeSearchDestination(entry: entry)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: entry.symbol)
                                    .foregroundStyle(.indigo)
                                    .frame(width: 30)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(entry.title).font(.headline)
                                    Text(entry.category + " · " + entry.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 7)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .onChange(of: query) { _, value in
            matches = HomeSearchIndex.search(value)
        }
    }
}

private struct DowntownControlAnswer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who controls downtown Austin?")
                .font(.headline)
            Text("In this demo, Maya is the individual controller from your friends list, and Front Desk Crew holds crew control.")
                .font(.subheadline)
            NavigationLink {
                AthleteProfileView(name: "Maya", subtitle: "Friend · Downtown Austin controller", score: "7.9 mi²")
            } label: {
                Label("Maya · Friend · Individual controller", systemImage: "person.crop.circle.fill")
            }
            if let crew = SampleData.crews.first(where: { $0.name == "Front Desk Crew" }) {
                NavigationLink {
                    CrewDetailView(crew: crew)
                } label: {
                    Label("Front Desk Crew · Crew controller", systemImage: crew.systemImage)
                }
            }
            Text("Demo territory snapshot · Individual and crew standings are separate.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.indigo.opacity(0.08), in: .rect(cornerRadius: 16))
    }
}

struct HomeSearchEntry: Identifiable {
    let id: String
    let title: String
    let category: String
    let subtitle: String
    let symbol: String
    let keywords: String
    let detail: String
    var person: SocialPerson? = nil
    var crew: Crew? = nil
    var coordinate: CLLocationCoordinate2D? = nil
}

enum HomeSearchIndex {
    static let entries: [HomeSearchEntry] = {
        var items = SampleData.followers.map { person in
            HomeSearchEntry(
                id: "person-" + person.name, title: person.name, category: "People",
                subtitle: person.subtitle + " · Follower", symbol: person.systemImage,
                keywords: "people person followers follower " + (person.subtitle.contains("Friend") ? "friends friend " : "") + person.name,
                detail: person.score, person: person
            )
        }
        items += SampleData.crews.map { crew in
            HomeSearchEntry(id: "crew-" + crew.name, title: crew.name, category: "Crews",
                            subtitle: crew.motto, symbol: crew.systemImage,
                            keywords: "crew crews team teams", detail: crew.territoryScore, crew: crew)
        }
        items += SampleData.venues.map { venue in
            HomeSearchEntry(id: "venue-" + venue.name, title: venue.name, category: "Map areas",
                            subtitle: venue.sport.title + " · " + venue.distanceAway,
                            symbol: "mappin.and.ellipse",
                            keywords: "map areas area locations location venues venue " + venue.sport.title,
                            detail: "Explore this training location in Austin.", coordinate: venue.coordinate)
        }
        items += [
            HomeSearchEntry(id: "sunset-5k", title: "Sunset 5K Training Run", category: "Events",
                            subtitle: "6:30 PM · Auditorium Shores", symbol: "calendar",
                            keywords: "events event runs running run training upcoming sunset 5k friends",
                            detail: "A social training run with 12 friends interested. Meet at Auditorium Shores."),
            HomeSearchEntry(id: "pegasus", title: "Nike Pegasus", category: "Gear",
                            subtitle: "Daily trainer shoes · $140", symbol: "shoe.fill",
                            keywords: "gear shoes shoe sneakers footwear practice practicing training running nike",
                            detail: "Trailblazer’s note: Practice and easy miles only. Save race shoes for race day."),
            HomeSearchEntry(id: "bottle", title: "Nathan handheld bottle", category: "Gear",
                            subtitle: "Hydration · $35", symbol: "waterbottle.fill",
                            keywords: "gear water hydration bottle nathan running",
                            detail: "Handheld hydration for training runs."),
            HomeSearchEntry(id: "fuel", title: "Maurten Gel 100", category: "Gear",
                            subtitle: "Run fuel · $43 / box", symbol: "bolt.fill",
                            keywords: "gear nutrition gels energy fuel maurten running",
                            detail: "Run fuel from Trailblazer’s gear collection."),
            HomeSearchEntry(id: "goggles", title: "Speedo Vanquisher 2.0", category: "Gear",
                            subtitle: "Swimming goggles · $25", symbol: "eyeglasses",
                            keywords: "gear goggles swimming swim speedo",
                            detail: "Pool training goggles from Trailblazer’s collection."),
            HomeSearchEntry(id: "suit", title: "Arena endurance jammer", category: "Gear",
                            subtitle: "Training suit · $55", symbol: "figure.pool.swim",
                            keywords: "gear swimwear suit swimming swim arena",
                            detail: "Training swimwear from Trailblazer’s collection."),
            HomeSearchEntry(id: "downtown", title: "Downtown Austin", category: "Map areas",
                            subtitle: "Maya · Front Desk Crew", symbol: "map.fill",
                            keywords: "downtown austin map areas area territory control controls owns owner rules leads",
                            detail: "Demo control snapshot: Maya is the individual controller from your friends list. Front Desk Crew holds crew control.",
                            coordinate: .init(latitude: 30.2672, longitude: -97.7431))
        ]
        for company in ["Nike", "Nathan", "Maurten", "Speedo", "Arena", "Garmin", "Strava"] {
            items.append(HomeSearchEntry(id: "company-" + company, title: company, category: "Companies",
                                        subtitle: "Sports and fitness", symbol: "building.2",
                                        keywords: "company companies brands brand " + company,
                                        detail: company + " appears in Umbasa’s demo gear and workout ecosystem."))
        }
        return items
    }()

    static func normalized(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US"))
    }

    static func asksAboutDowntownControl(_ query: String) -> Bool {
        let words = Set(normalized(query).split { !$0.isLetter && !$0.isNumber }.map(String.init))
        return words.contains("downtown")
            && !words.isDisjoint(with: ["control", "controls", "owns", "owner", "rules", "leads", "holding"])
            && words.isDisjoint(with: ["chicago", "denver", "seattle"])
    }

    static func search(_ query: String) -> [HomeSearchEntry] {
        let stopWords: Set<String> = ["a", "an", "the", "who", "what", "where", "when", "is", "are", "do", "does", "my", "me", "i", "in", "at", "for", "of", "to", "and", "or", "with", "find", "show", "search", "some", "please", "which"]
        let tokens = Set(normalized(query).split { !$0.isLetter && !$0.isNumber }.map(String.init)).subtracting(stopWords)
        guard !tokens.isEmpty else { return [] }
        return entries.compactMap { entry -> (HomeSearchEntry, Int)? in
            let haystack = normalized(entry.title + " " + entry.category + " " + entry.subtitle + " " + entry.keywords)
            let score = tokens.reduce(0) { $0 + (haystack.contains($1) ? 1 : 0) }
            guard score > 0 else { return nil }
            return (entry, score)
        }
        .sorted { $0.1 == $1.1 ? $0.0.title < $1.0.title : $0.1 > $1.1 }
        .map { $0.0 }
    }
}

private struct HomeSearchDestination: View {
    let entry: HomeSearchEntry

    var body: some View {
        Group {
            if let person = entry.person {
                AthleteProfileView(name: person.name, subtitle: person.subtitle, score: person.score)
            } else if let crew = entry.crew {
                CrewDetailView(crew: crew)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Label(entry.category, systemImage: entry.symbol)
                            .font(.headline)
                            .foregroundStyle(.indigo)
                        Text(entry.subtitle).font(.title3.bold())
                        Text(entry.detail)
                        if entry.id == "sunset-5k" {
                            UpcomingSessionCard()
                        }
                        if let coordinate = entry.coordinate {
                            Map(initialPosition: .region(MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
                            ))) {
                                Marker(entry.title, coordinate: coordinate)
                            }
                            .frame(height: 260)
                            .clipShape(.rect(cornerRadius: 16))
                        }
                        Text("Demo search result").font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .navigationTitle(entry.title)
            }
        }
    }
}
