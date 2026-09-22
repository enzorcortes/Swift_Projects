import SwiftUI

struct ContentView: View {
    @State private var store = ConstellationStore()

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                MainTabView(store: store)
            } else {
                OnboardingView(store: store)
            }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
