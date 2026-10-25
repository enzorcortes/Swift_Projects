import SwiftUI

struct MainTabView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var representedCity = RankedCity.austin
    @State private var selectedTab = AppTab.home

    var body: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeFeedView()
            case .territory:
                TerritoryView()
            case .kingOfTheHill:
                VenuesView()
            case .lockerRoom:
                CrewsView(selectedCity: $representedCity)
            case .profile:
                ProfileView(hasCompletedOnboarding: $hasCompletedOnboarding, representedCity: $representedCity)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            DashboardNavigationBar(selection: $selectedTab)
        }
    }
}

private struct DashboardNavigationBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selection = tab
                } label: {
                    Image(systemName: tab.systemImage)
                        .font(.system(size: 27, weight: .semibold))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(tab == selection ? Color.cyan : Color.indigo.opacity(0.95))
                        .frame(width: 52, height: 52)
                        .overlay {
                            if tab == selection {
                                Circle()
                                    .stroke(Color.cyan, lineWidth: 3)
                                    .padding(3)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(tab == selection ? .isSelected : [])
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color(red: 0.16, green: 0.16, blue: 0.17).opacity(0.97))
        .overlay(alignment: .top) {
            Divider()
                .overlay(.white.opacity(0.12))
        }
    }
}

private enum AppTab: String, CaseIterable, Identifiable {
    case home
    case territory
    case kingOfTheHill
    case lockerRoom
    case profile

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .home: "Home"
        case .territory: "Territory"
        case .kingOfTheHill: "King of the Hill"
        case .lockerRoom: "Locker Room"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .territory: "map.fill"
        case .kingOfTheHill: "crown.fill"
        case .lockerRoom: "trophy.fill"
        case .profile: "person.crop.circle"
        }
    }
}
