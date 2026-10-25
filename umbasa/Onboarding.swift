import AuthenticationServices
import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var authenticationError: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.indigo.opacity(0.95), .blue.opacity(0.75), .cyan.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 36)

                    Image(systemName: "map.fill")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(26)
                        .background(.ultraThinMaterial, in: .circle)
                        .accessibilityHidden(true)

                    VStack(spacing: 10) {
                        Text("Make your move.")
                            .font(.largeTitle.bold())
                        Text("Claim territory on your own or rally a crew to take over your city.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 18) {
                        OnboardingFeature(systemImage: "figure.run", title: "Move", detail: "Turn workouts into territory.")
                        OnboardingFeature(systemImage: "crown.fill", title: "Compete", detail: "Claim venues and climb local rankings.")
                        OnboardingFeature(systemImage: "person.3.fill", title: "Conquer together", detail: "Form a crew and paint the map your colors.")
                    }
                    .padding(22)
                    .background(.regularMaterial, in: .rect(cornerRadius: 24))

                    VStack(spacing: 12) {
                        SignInWithAppleButton(.continue) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            switch result {
                            case .success:
                                hasCompletedOnboarding = true
                            case .failure(let error):
                                authenticationError = error.localizedDescription
                            }
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 52)
                        .clipShape(.rect(cornerRadius: 12))

                        Button("Explore the demo") {
                            hasCompletedOnboarding = true
                        }
                        .font(.headline)
                        .foregroundStyle(.white)

                        Text("Demo mode uses sample workouts and does not create an account.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                .frame(maxWidth: 560)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
        }
        .alert("Couldn’t Sign In", isPresented: Binding(
            get: { authenticationError != nil },
            set: { if !$0 { authenticationError = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authenticationError ?? "Please try again.")
        }
    }
}

struct OnboardingFeature: View {
    let systemImage: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 34)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

