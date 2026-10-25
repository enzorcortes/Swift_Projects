import SwiftUI

struct CrewsView: View {
    @Binding var selectedCity: RankedCity
    @State private var leaderboardMode = TerritoryMode.crews

    private var ranking: CityRanking {
        SampleData.ranking(for: selectedCity)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 16) {
                        Text("THE LOCKER ROOM")
                            .font(.system(.largeTitle, design: .rounded, weight: .black))
                            .tracking(1.5)
                            .frame(maxWidth: .infinity)

                        ZStack(alignment: .topTrailing) {
                            CityBannerView(city: selectedCity.cityName, state: selectedCity.stateName)
                                .frame(height: 210)

                            Picker("Representing city", selection: $selectedCity) {
                                ForEach(RankedCity.allCases) { city in
                                    Text(city.title).tag(city)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.menu)
                            .padding(10)
                            .background(.regularMaterial, in: .capsule)
                            .padding(12)
                        }

                        HStack(spacing: 14) {
                            LockerModeButton(title: "Me", systemImage: "person.fill", mode: .individual, selection: $leaderboardMode)
                            LockerModeButton(title: "Crews", systemImage: "person.3.fill", mode: .crews, selection: $leaderboardMode)
                        }
                        .frame(maxWidth: 430)
                        .padding(.horizontal, 20)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section {
                    HStack {
                        StatView(value: ranking.activePlayers, label: "Active", systemImage: "person.2.fill")
                        StatView(value: ranking.claimedArea, label: "Claimed", systemImage: "map.fill")
                        StatView(value: ranking.seasonEnds, label: "Season left", systemImage: "calendar")
                    }
                    .padding(.vertical, 8)
                }

                if leaderboardMode == .crews {
                    Section {
                        Text("CREW STANDINGS")
                            .font(.title2.bold())
                        ForEach(Array(ranking.crews.enumerated()), id: \.element.id) { index, crew in
                            NavigationLink {
                                CrewDetailView(crew: crew)
                            } label: {
                                CrewLeaderboardRow(position: index + 1, crew: crew)
                            }
                        }

                        CrewActionButton(title: "Create a Crew", subtitle: "Build your own team", systemImage: "sparkles", colors: [.indigo, .purple])
                        CrewActionButton(title: "Join a Crew", subtitle: "Enter an invite code", systemImage: "person.badge.plus", colors: [.orange, .pink])
                    }
                } else {
                    Section {
                        Text("SOLO STANDINGS")
                            .font(.title2.bold())
                        ForEach(Array(ranking.individuals.enumerated()), id: \.element.id) { index, competitor in
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline.monospacedDigit())
                                    .frame(width: 24)
                                Image(systemName: index == 0 ? "crown.fill" : "person.crop.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(index == 0 ? .orange : .indigo)
                                Text(competitor.name)
                                    .font(.title3.bold())
                                Spacer()
                                Text(competitor.score)
                                    .font(.subheadline.bold().monospacedDigit())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

            }
            .navigationTitle("")
        }
    }
}

struct CrewLeaderboardRow: View {
    let position: Int
    let crew: Crew

    var body: some View {
        HStack(spacing: 12) {
            Text("\(position)")
                .font(.headline.monospacedDigit())
                .frame(width: 24)

            Image(systemName: crew.systemImage)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(crew.color.gradient, in: .circle)

            VStack(alignment: .leading, spacing: 3) {
                Text(crew.name)
                    .font(.headline)
                Text("\(crew.memberCount) members")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(crew.territoryScore)
                    .font(.subheadline.bold())
                Text("controlled")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct LockerModeButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let mode: TerritoryMode
    @Binding var selection: TerritoryMode

    var body: some View {
        Button {
            selection = mode
        } label: {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(selection == mode ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(selection == mode ? AnyShapeStyle(Color.indigo.gradient) : AnyShapeStyle(.quaternary), in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

struct CrewActionButton: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let systemImage: String
    let colors: [Color]

    var body: some View {
        Button { } label: {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title2.bold())
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).opacity(0.85)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .padding()
            .background(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing), in: .rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .padding(.vertical, 3)
    }
}

struct CrewDetailView: View {
    let crew: Crew
    @State private var crewName: String
    @State private var motto: String
    @State private var favoriteSport = Sport.swimming
    @State private var showingEditor = false

    init(crew: Crew) {
        self.crew = crew
        _crewName = State(initialValue: crew.name)
        _motto = State(initialValue: crew.motto)
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 10) {
                    Image(systemName: crew.systemImage)
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                        .frame(width: 88, height: 88)
                        .background(crew.color.gradient, in: .circle)
                    Text(crewName)
                        .font(.title2.bold())
                    Text(motto)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 30) {
                        NavigationLink {
                            SocialConnectionsView(title: "Members", people: SampleData.followers)
                        } label: {
                            SocialCount(value: "\(crew.memberCount)", label: "Members")
                        }
                        .buttonStyle(.plain)
                        SocialCount(value: "1.8K", label: "Followers")
                        SocialCount(value: "24", label: "Following")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section("Season stats") {
                LabeledContent("Local rank", value: crew.localRank)
                LabeledContent("Territory controlled", value: crew.territoryScore)
                LabeledContent("Members", value: "\(crew.memberCount)")
                LabeledContent("Collective favorite", value: favoriteSport.title)
                LabeledContent("Most recently active", value: "Today · 6:42 PM")
            }

            Section("Top contributors") {
                ForEach(crew.contributors) { competitor in
                    NavigationLink {
                        AthleteProfileView(name: competitor.name, subtitle: "\(crewName) member", score: competitor.score)
                    } label: {
                        LabeledContent(competitor.name, value: competitor.score)
                    }
                }
            }
        }
        .navigationTitle(crewName)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Customize", systemImage: "paintbrush.fill") {
                    showingEditor = true
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            CrewEditorView(crewName: $crewName, motto: $motto, favoriteSport: $favoriteSport)
        }
    }
}

struct CrewEditorView: View {
    @Binding var crewName: String
    @Binding var motto: String
    @Binding var favoriteSport: Sport
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Crew identity") {
                    TextField("Crew name", text: $crewName)
                    TextField("Motto", text: $motto)
                    Picker("Featured sport", selection: $favoriteSport) {
                        ForEach(Sport.allCases) { sport in
                            Label(sport.title, systemImage: sport.systemImage).tag(sport)
                        }
                    }
                }
                Section {
                    Label("Visible to crew admins", systemImage: "lock.shield.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Customize Crew")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

