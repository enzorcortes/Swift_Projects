import PhotosUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct ProfileView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Binding var representedCity: RankedCity
    @State private var displayName = "Trailblazer"
    @State private var bio = "Running Austin one block at a time."
    @State private var favoriteSport = Sport.running
    @State private var selectedTab = ProfileContentTab.posts
    @State private var posts = SampleData.profilePosts
    @State private var addedGear: [ProfileGear] = []
    @State private var gearNotes: [String: String] = ["shoes": "Practice and easy miles only. Save race shoes for race day."]
    @State private var showingNewGear = false
    @State private var showingEditor = false
    @State private var showingNewPost = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profilePhotoData: Data?

    private func noteBinding(for key: String) -> Binding<String> {
        Binding(
            get: { gearNotes[key, default: ""] },
            set: { gearNotes[key] = $0 }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 24) {
                        ProfilePortraitHero(
                            displayName: displayName,
                            city: representedCity.cityName,
                            photoData: profilePhotoData,
                            selectedPhoto: $selectedPhoto
                        )

                        VStack(alignment: .leading, spacing: 22) {
                            HStack(spacing: 16) {
                                NavigationLink {
                                    SocialConnectionsView(title: "Followers", people: SampleData.followers)
                                } label: {
                                    ProfileHeroCount(value: "248", title: "Followers")
                                }
                                NavigationLink {
                                    SocialConnectionsView(title: "Following", people: SampleData.following)
                                } label: {
                                    ProfileHeroCount(value: "183", title: "Following")
                                }
                                NavigationLink {
                                    SocialConnectionsView(title: "Friends", people: SampleData.followers)
                                } label: {
                                    ProfileHeroCount(value: "14", title: "Friends")
                                }
                            }
                            .buttonStyle(.plain)

                            Divider().overlay(.white.opacity(0.12))

                            Text(bio)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)

                            Picker("Representing", selection: $representedCity) {
                                ForEach(RankedCity.allCases) { city in
                                    Text(city.title).tag(city)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)

                            Button {
                                showingEditor = true
                            } label: {
                                Label("Edit Profile", systemImage: "pencil")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .foregroundStyle(.white)
                                    .background(Color(red: 1, green: 0.25, blue: 0.08), in: .rect(cornerRadius: 4))
                            }
                            .buttonStyle(.plain)

                            ProfileAffiliationsView()
                            ProfileMetricsView(favoriteSport: favoriteSport)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Up next")
                                    .font(.caption.bold())
                                    .textCase(.uppercase)
                                    .tracking(2)
                                    .foregroundStyle(.secondary)
                                UpcomingSessionCard()
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.bottom, 18)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    HStack(spacing: 4) {
                        Color.clear
                            .frame(width: 44, height: 44)
                            .accessibilityHidden(true)
                        HStack(spacing: 12) {
                            ProfileTabButton(title: "Posts", symbol: "square.grid.3x3", tab: .posts, selection: $selectedTab)
                            ProfileTabButton(title: "Gear", symbol: "tshirt", tab: .gear, selection: $selectedTab)
                            ProfileTabButton(title: "Metrics", symbol: "chart.xyaxis.line", tab: .metrics, selection: $selectedTab)
                        }
                        .frame(maxWidth: .infinity)
                        Menu {
                            Button("New post", systemImage: "square.and.pencil") {
                                showingNewPost = true
                            }
                            Button("Add gear", systemImage: "tshirt") {
                                showingNewGear = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3.weight(.semibold))
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("Create post or add gear")
                    }
                    .listRowSeparator(.hidden)
                }

                if selectedTab == .posts {
                Section("Posts") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 4)], spacing: 4) {
                        ForEach(posts) { post in
                            VStack(spacing: 0) {
                                Text(post.caption)
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .padding(7)
                                    .background(.black.opacity(0.3))
                                Image(systemName: post.systemImage)
                                    .font(.system(size: 34))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .frame(maxWidth: .infinity, minHeight: 58, maxHeight: .infinity)
                                    .accessibilityHidden(true)
                            }
                            .frame(minHeight: 108)
                            .background(
                                LinearGradient(colors: post.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(.rect(cornerRadius: 10))
                        }
                    }
                    .padding(.vertical, 4)
                }


                } else if selectedTab == .metrics {
                    Section("Athlete overview") {
                        Label("Favorite sport: \(favoriteSport.title)", systemImage: favoriteSport.systemImage)
                            .foregroundStyle(favoriteSport.color)
                        ProfileAffiliationsView()
                        Text("Demo insights · Austin season")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ProfileDeepDiveSections()
                } else {
                Section("My gear · Running") {
                    ProfileGearWithNote(note: noteBinding(for: "shoes"), name: "Daily Trainer Shoes", detail: "Nike Pegasus · 214 miles", price: "$140", systemImage: "shoe.fill", tint: .orange)
                    ProfileGearWithNote(note: noteBinding(for: "hydration"), name: "Hydration", detail: "Nathan handheld bottle", price: "$35", systemImage: "waterbottle.fill", tint: .blue)
                    ProfileGearWithNote(note: noteBinding(for: "fuel"), name: "Run fuel", detail: "Maurten Gel 100", price: "$43 / box", systemImage: "bolt.fill", tint: .yellow)
                }

                Section("My gear · Swimming") {
                    ProfileGearWithNote(note: noteBinding(for: "goggles"), name: "Goggles", detail: "Speedo Vanquisher 2.0", price: "$25", systemImage: "eyeglasses", tint: .cyan)
                    ProfileGearWithNote(note: noteBinding(for: "suit"), name: "Training suit", detail: "Arena endurance jammer", price: "$55", systemImage: "figure.pool.swim", tint: .indigo)
                }


                    if !addedGear.isEmpty {
                        Section("More gear") {
                            ForEach($addedGear) { $item in
                                ProfileGearWithNote(note: $item.note, name: item.name, detail: item.detail, price: "", systemImage: "bag.fill", tint: .indigo)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.045, green: 0.045, blue: 0.055))
            .tint(.orange)
            .navigationTitle("Profile")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        ProfileSettingsView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingNewGear) {
                ProfileGearEditor { item in
                    addedGear.append(item)
                    selectedTab = .gear
                }
            }
            .sheet(isPresented: $showingEditor) {
                ProfileEditorView(displayName: $displayName, bio: $bio, favoriteSport: $favoriteSport)
            }
            .sheet(isPresented: $showingNewPost) {
                NewPostView { post in
                    posts.insert(post, at: 0)
                    selectedTab = .posts
                }
            }
            .task(id: selectedPhoto) {
                guard let selectedPhoto else { return }
                profilePhotoData = try? await selectedPhoto.loadTransferable(type: Data.self)
            }
        }
        .environment(\.colorScheme, .dark)
    }
}


private struct ProfilePortraitHero: View {
    let displayName: String
    let city: String
    let photoData: Data?
    @Binding var selectedPhoto: PhotosPickerItem?
    @ScaledMetric(relativeTo: .largeTitle) private var nameSize = 44

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geometry in
                ZStack(alignment: .trailing) {
                    LinearGradient(
                        colors: [.black, .indigo.opacity(0.7), .cyan.opacity(0.3)],
                        startPoint: .leading, endPoint: .topTrailing
                    )
                    if photoData != nil {
                        ProfileAvatarView(photoData: photoData, accent: .cyan)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } else {
                        Image(systemName: "figure.run")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(
                                LinearGradient(colors: [.cyan, .indigo, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .padding(.vertical, 24)
                            .frame(width: geometry.size.width * 0.7)
                            .opacity(0.75)
                            .accessibilityHidden(true)
                    }
                    LinearGradient(
                        colors: [.clear, Color(red: 0.045, green: 0.045, blue: 0.055)],
                        startPoint: .top, endPoint: .bottom
                    )
                    LinearGradient(
                        colors: [.black.opacity(0.7), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Label(city, systemImage: "mappin")
                    .font(.caption.bold())
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.75))
                Text(displayName)
                    .font(.system(size: nameSize, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(22)
        }
        .frame(minHeight: 300)
        .overlay(alignment: .topTrailing) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "camera")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.black.opacity(0.4), in: .circle)
                    .overlay(Circle().stroke(.white.opacity(0.3)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choose profile picture")
            .padding(18)
        }
    }
}

private struct ProfileHeroCount: View {
    let value: String
    let title: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title.weight(.medium).monospacedDigit())
                .foregroundStyle(.white)
            Text(title)
                .font(.caption2.bold())
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

private struct ProfileTabButton: View {
    let title: LocalizedStringKey
    let symbol: String
    let tab: ProfileContentTab
    @Binding var selection: ProfileContentTab

    var body: some View {
        Button {
            selection = tab
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(selection == tab ? Color.orange : Color.secondary)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(selection == tab ? Color.white.opacity(0.06) : Color.clear, in: .rect(cornerRadius: 14))
                .overlay(alignment: .bottom) {
                    Capsule()
                        .fill(selection == tab ? Color.orange : Color.clear)
                        .frame(height: 3)
                        .padding(.horizontal, 8)
                }
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selection == tab ? .isSelected : [])
    }
}

private enum ProfileContentTab {
    case posts
    case gear
    case metrics
}

private struct ProfileAffiliationsView: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 10) {
                ProfileCrewBadge()
                ProfileRivalBadge()
            }
            VStack(spacing: 10) {
                ProfileCrewBadge()
                ProfileRivalBadge()
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ProfileCrewBadge: View {
    var body: some View {
        if let crew = SampleData.crews.first {
            NavigationLink {
                CrewDetailView(crew: crew)
            } label: {
                VStack(spacing: 4) {
                    Label(crew.name, systemImage: crew.systemImage)
                        .font(.caption.bold())
                    Text("Member · Austin #1")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(crew.color.opacity(0.1), in: .rect(cornerRadius: 14))
            }
        }
    }
}

private struct ProfileRivalBadge: View {
    var body: some View {
        NavigationLink {
            AthleteProfileView(name: "Maya", subtitle: "Friendly rival · Austin", score: "7.9 mi²")
        } label: {
            VStack(spacing: 4) {
                Label("Rivalry with Maya", systemImage: "bolt.fill")
                    .font(.caption.bold())
                Text("Leading by 0.8 mi² · 12 days")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(.pink.opacity(0.1), in: .rect(cornerRadius: 14))
        }
    }
}

private struct ProfileMetricsView: View {
    let favoriteSport: Sport

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 6) {
                Image(systemName: favoriteSport.systemImage)
                    .font(.title2)
                    .foregroundStyle(favoriteSport.color)
                Text(favoriteSport.title).font(.subheadline.bold())
                Text("Favorite sport").font(.caption2).foregroundStyle(.secondary)
                if favoriteSport == .running {
                    Text("4.2 mi · Today").font(.caption.bold())
                } else {
                    Label("Latest: 4.2 mi run today", systemImage: "figure.run")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(favoriteSport.color.opacity(0.08), in: .rect(cornerRadius: 18))
            .accessibilityElement(children: .combine)

            VStack(spacing: 6) {
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundStyle(.indigo)
                Text("8.7 mi²").font(.subheadline.bold())
                Text("Territory").font(.caption2).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                    Image(systemName: "crown.fill")
                    Image(systemName: "crown.fill")
                }
                .font(.caption)
                .foregroundStyle(.orange)
                .accessibilityLabel("3 venue crowns")
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(.indigo.opacity(0.08), in: .rect(cornerRadius: 18))
            .accessibilityElement(children: .combine)
        }
    }
}

private struct ProfileSettingsView: View {
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        List {
            Section("Account") {
                NavigationLink {
                    DataConnectionsView()
                } label: {
                    AccountRow(title: "Workout connections", detail: "Apple Health, Strava, Nike, Garmin, and more", systemImage: "arrow.triangle.2.circlepath", color: .green)
                }
                NavigationLink {
                    List {
                        NavigationLink("Friends") {
                            SocialConnectionsView(title: "Friends", people: SampleData.followers)
                        }
                        ForEach(SampleData.crews) { crew in
                            NavigationLink(crew.name) {
                                CrewDetailView(crew: crew)
                            }
                        }
                    }
                    .navigationTitle("Friends and Crews")
                } label: {
                    AccountRow(title: "Friends and crews", detail: "Manage connections and invitations", systemImage: "person.3.fill", color: .indigo)
                }
                AccountRow(title: "Privacy and visibility", detail: "Control routes, location, and profile access", systemImage: "hand.raised.fill", color: .blue)
            }
            Section {
                Button("Sign out", role: .destructive) {
                    hasCompletedOnboarding = false
                }
            }
        }
        .navigationTitle("Settings")
    }
}

private struct ProfileGear: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    var note: String
}

private struct ProfileGearWithNote: View {
    @Binding var note: String
    let name: String
    let detail: String
    let price: String
    let systemImage: String
    let tint: Color
    @State private var showingNoteEditor = false
    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GearItemRow(name: name, detail: detail, price: price, systemImage: systemImage, tint: tint)
            if !note.isEmpty {
                Label {
                    Text(note)
                } icon: {
                    Image(systemName: "note.text")
                }
                .font(.subheadline)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(tint.opacity(0.08), in: .rect(cornerRadius: 10))
            }
            Button(note.isEmpty ? "Add note" : "Edit note", systemImage: "square.and.pencil") {
                draft = note
                showingNoteEditor = true
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingNoteEditor) {
            NavigationStack {
                Form {
                    Section(name) {
                        TextField("How do you use this gear?", text: $draft, axis: .vertical)
                            .lineLimit(4...10)
                    }
                    Section {
                        Text("Share race-day recommendations, training advice, or fit tips. Clear the text to remove your note.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .navigationTitle("Gear Note")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingNoteEditor = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            note = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                            showingNoteEditor = false
                        }
                    }
                }
            }
#if os(macOS)
            .frame(minWidth: 400, minHeight: 350)
#endif
        }
    }
}

private struct ProfileGearEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var detail = ""
    @State private var note = ""
    let onAdd: (ProfileGear) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Gear name", text: $name)
                TextField("Brand or model", text: $detail)
                Section("Your note") {
                    TextField("Racing only, everyday training, sizing tips…", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Gear")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(ProfileGear(name: name.trimmingCharacters(in: .whitespacesAndNewlines), detail: detail, note: note.trimmingCharacters(in: .whitespacesAndNewlines)))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 400, minHeight: 300)
#endif
    }
}

struct CityBannerView: View {
    let city: String
    let state: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [.orange.opacity(0.8), .pink.opacity(0.7), .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)

            HStack(alignment: .bottom, spacing: 5) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 58))
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 38))
                Image(systemName: "building.fill")
                    .font(.system(size: 72))
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 48))
            }
            .foregroundStyle(.black.opacity(0.35))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 18)

            VStack(alignment: .leading, spacing: 2) {
                Text("REPRESENTING")
                    .font(.caption2.bold())
                Text(city)
                    .font(.title.bold())
                Text(state)
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding(18)
        }
        .clipShape(.rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}

struct ProfileAvatarView: View {
    let photoData: Data?
    let accent: Color

    var body: some View {
        if let photoData, let image = platformImage(from: photoData) {
            image
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFill()
                .foregroundStyle(.white, accent.gradient)
        }
    }

    private func platformImage(from data: Data) -> Image? {
#if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        return Image(uiImage: image)
#elseif canImport(AppKit)
        guard let image = NSImage(data: data) else { return nil }
        return Image(nsImage: image)
#else
        return nil
#endif
    }
}

struct AccountRow: View {
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    let systemImage: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(color.gradient, in: .rect(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.title3.weight(.semibold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 10)
    }
}

struct GearItemRow: View {
    let name: String
    let detail: String
    let price: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(tint.gradient, in: .rect(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 3) {
                Text(name).font(.headline)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(price).font(.subheadline.bold())
                Button("Find it") { }
                    .font(.caption)
            }
        }
        .padding(.vertical, 5)
    }
}

struct NewPostView: View {
    var onPublish: (ProfilePost) -> Void = { _ in }
    @Environment(\.dismiss) private var dismiss
    @State private var caption = ""
    @State private var postType = PostType.milestone
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("Share") {
                    Picker("Post type", selection: $postType) {
                        ForEach(PostType.allCases) { type in
                            Label(type.title, systemImage: type.systemImage).tag(type)
                        }
                    }
                    .padding(.vertical, 8)
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(selectedPhoto == nil ? "Add a photo" : "Photo selected", systemImage: "photo.badge.plus")
                    }
                    .padding(.vertical, 8)
                    TextField("Write a caption…", text: $caption, axis: .vertical)
                        .lineLimit(4...8)
                        .padding(.vertical, 10)
                }
                Section("Visibility") {
                    Label("Followers and friends", systemImage: "person.2.fill")
                        .padding(.vertical, 8)
                    Label("Workout source attribution included", systemImage: "checkmark.seal.fill")
                        .padding(.vertical, 8)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publish") {
                        onPublish(ProfilePost(id: UUID(), caption: caption.trimmingCharacters(in: .whitespacesAndNewlines), systemImage: postType.systemImage, colors: [.indigo, .purple]))
                        dismiss()
                    }
                        .disabled(caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 480, minHeight: 600)
#else
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
#endif
    }
}

struct DataConnectionsView: View {
    @State private var connectedProviders: Set<String> = ["Apple Health", "Strava"]

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bring every workout together")
                        .font(.title2.bold())
                    Text("Imported activities keep their original source attribution and can contribute to territory after verification.")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("Connected stats") {
                LabeledContent("Imported workouts", value: "128")
                LabeledContent("Imported distance", value: "742.6 mi")
                LabeledContent("Last sync", value: "2 min ago")
            }

            Section("Apps and devices") {
                ForEach(SampleData.dataProviders) { provider in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Image(systemName: provider.systemImage)
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(provider.color.gradient, in: .rect(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(provider.name)
                                    .font(.headline)
                                Text(provider.connectionDetail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(connectedProviders.contains(provider.name) ? "Connected" : "Connect") {
                                if connectedProviders.contains(provider.name) {
                                    connectedProviders.remove(provider.name)
                                } else {
                                    connectedProviders.insert(provider.name)
                                }
                            }
                            .buttonStyle(.bordered)
                        }

                        if connectedProviders.contains(provider.name) {
                            HStack {
                                Label(provider.workoutCount, systemImage: "figure.run")
                                Spacer()
                                Text(provider.lastSync)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }

            Section("Import behavior") {
                Label("Duplicate workouts are merged before scoring", systemImage: "checkmark.seal.fill")
                Label("Source labels remain visible on activities", systemImage: "tag.fill")
                Label("Only verified routes can claim territory", systemImage: "shield.checkered")
            }
        }
        .navigationTitle("Workout Connections")
    }
}

struct SocialCount: View {
    let value: String
    let label: LocalizedStringKey

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ProfileMetric: View {
    let systemImage: String
    let tint: Color
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(tint.gradient, in: .rect(cornerRadius: 10))
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }
}

struct ProfileEditorView: View {
    @Binding var displayName: String
    @Binding var bio: String
    @Binding var favoriteSport: Sport
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Public profile") {
                    TextField("Display name", text: $displayName)
                        .padding(.vertical, 10)
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(.vertical, 10)
                }
                Section("Featured metric") {
                    Picker("Favorite sport", selection: $favoriteSport) {
                        ForEach(Sport.allCases) { sport in
                            Label(sport.title, systemImage: sport.systemImage).tag(sport)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 480, minHeight: 560)
#else
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
#endif
    }
}

struct SocialConnectionsView: View {
    let title: String
    let people: [SocialPerson]

    var body: some View {
        List(people) { person in
            NavigationLink {
                AthleteProfileView(name: person.name, subtitle: person.subtitle, score: person.score)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: person.systemImage)
                        .font(.title2)
                        .foregroundStyle(person.tint)
                    VStack(alignment: .leading) {
                        Text(person.name).font(.headline)
                        Text(person.subtitle).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(person.score).font(.caption.bold())
                }
            }
        }
        .navigationTitle(title)
    }
}

struct AthleteProfileView: View {
    let name: String
    let subtitle: String
    let score: String

    var body: some View {
        List {
            Section {
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.indigo)
                    Text(name).font(.title2.bold())
                    Text(subtitle).foregroundStyle(.secondary)
                    Button("Following", systemImage: "person.badge.checkmark") { }
                        .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            Section("Season") {
                LabeledContent("Territory", value: score)
                LabeledContent("Favorite sport", value: "Running")
                LabeledContent("Last active", value: "Today")
            }
        }
        .navigationTitle(name)
    }
}
