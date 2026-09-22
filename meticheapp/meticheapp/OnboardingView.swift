import SwiftUI

struct OnboardingView: View {
    let store: ConstellationStore
    @State private var name = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ConstellaSpaceBackground()
            ScrollView {
                VStack(spacing: 28) {
                    ConstellaLoginHero()
                    ConstellaLoginForm(name: $name) {
                        store.completeOnboarding(name: name)
                    }
                }
                .frame(maxWidth: 520)
                .padding(.horizontal, 28)
                .padding(.vertical, 44)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct ConstellaSpaceBackground: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.mint.opacity(0.18))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: -170, y: 260)
            Circle()
                .fill(.blue.opacity(0.2))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(x: 180, y: -260)
            Circle()
                .fill(.purple.opacity(0.2))
                .frame(width: 240, height: 240)
                .blur(radius: 80)
                .offset(x: 130, y: 290)
        }
        .accessibilityHidden(true)
    }
}

private struct ConstellaLoginHero: View {
    var body: some View {
        VStack(spacing: 18) {
            Image("ConstellaLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 48))
                .shadow(color: .blue.opacity(0.24), radius: 28)
                .accessibilityLabel("Constella logo")
            VStack(spacing: 8) {
                Text("Constella")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("Your people, in their natural orbit.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.leading)
            }
            Text("A private social atlas for the people, places, and moments that shape your world.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.62))
        }
        .foregroundStyle(.white)
    }
}

private struct ConstellaLoginForm: View {
    @Binding var name: String
    let onContinue: () -> Void
    @State private var isHoveringContinue = false

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                HStack(spacing: 7) {
                    Image(systemName: "sparkle")
                        .foregroundStyle(.mint)
                    Text("What should we call you?")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Image(systemName: "sparkle")
                        .foregroundStyle(.orange)
                }

                TextField("Your name", text: $name)
                    .textContentType(.name)
                    .textFieldStyle(.plain)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(width: 250, height: 48)
                    .background(.black.opacity(0.28), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [.mint.opacity(0.8), .blue.opacity(0.7), .purple.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                    .submitLabel(.continue)
                    .onSubmit(onContinue)
            }
            .foregroundStyle(.white)
            .padding(.vertical, 4)
            .frame(maxWidth: 330)

            Button(action: onContinue) {
                HStack {
                    Text("Enter your constellation")
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .accessibilityHidden(true)
                }
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: 360)
                .background(
                    LinearGradient(
                        colors: [.mint, .blue, .purple, .pink, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
            }
            .buttonStyle(.plain)
            .scaleEffect(isHoveringContinue ? 1.035 : 1)
            .brightness(isHoveringContinue ? 0.08 : 0)
            .shadow(
                color: isHoveringContinue ? Color.purple.opacity(0.5) : Color.clear,
                radius: isHoveringContinue ? 18 : 0,
                y: isHoveringContinue ? 6 : 0
            )
            .animation(.smooth(duration: 0.2), value: isHoveringContinue)
            .onHover { isHoveringContinue = $0 }

            Label("Private, intentional, and invite-only by default", systemImage: "lock.fill")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.58))
        }
        .frame(maxWidth: .infinity)
    }
}
