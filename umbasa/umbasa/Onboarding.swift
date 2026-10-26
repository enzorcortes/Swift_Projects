import AuthenticationServices
import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var authenticationError: String?

    var body: some View {
        ZStack {
            OnboardingTerritoryBackground()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 16) {
                        Text("UMBASA")
                            .font(.system(size: 54, weight: .heavy, design: .monospaced))
                            .tracking(7)
                            .italic()
                            .foregroundStyle(LinearGradient(colors: [.white, .cyan.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                            .shadow(color: .cyan.opacity(0.25), radius: 12)
                            .accessibilityLabel("Umbasa")
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .accessibilityAddTraits(.isHeader)
                        Text("Make your move.")
                            .font(.title2.bold())
                            .foregroundStyle(.orange)
                        Text("Turn workouts into territory. Find your crew, claim local crowns, and share the way you move.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundStyle(.white)
                    .padding(.top, 24)

                    HStack(spacing: 28) {
                        Image(systemName: "figure.run")
                        Image(systemName: "bicycle")
                        Image(systemName: "figure.pool.swim")
                    }
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Running, cycling, and swimming")

                    VStack(alignment: .leading, spacing: 18) {
                        OnboardingFeature(systemImage: "map.fill", title: "Your city. Your playground.", detail: "Explore territory, challenge rivals, and compete for venue crowns.")
                        OnboardingFeature(systemImage: "person.3.fill", title: "Better with your people.", detail: "Rally a crew, discover events, and share posts and gear advice.")
                        OnboardingFeature(systemImage: "sparkles", title: "Discover your next move.", detail: "Explore with Umbasa AI and follow your progress with deeper metrics.")
                    }
                    .padding(22)
                    .background(.black.opacity(0.72), in: .rect(cornerRadius: 22))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    }

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

                        Button {
                            hasCompletedOnboarding = true
                        } label: {
                            HStack {
                                Text("Explore the demo")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.orange, in: .rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)

                        Text("Demo mode uses sample workouts and does not create an account.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: 560)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
        }
        .environment(\.colorScheme, .dark)
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

private struct OnboardingTerritoryBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.035, blue: 0.055)
            Canvas { context, size in
                let colors: [Color] = [.orange, .cyan, .purple, .mint, .pink, .orange]
                let symbols = ["figure.run", "figure.outdoor.cycle", "figure.strengthtraining.traditional", "figure.pool.swim", "figure.yoga", "figure.walk"]
                let blockWidth: CGFloat = 46
                let blockHeight: CGFloat = 62
                let columns = Int(ceil(size.width / blockWidth))
                let rows = Int(ceil(size.height / blockHeight))

                // Adjacent claimed blocks form uneven, interlocking territories.
                for row in 0..<rows {
                    for column in 0..<columns {
                        let midpoint = columns / 2 + [0, 1, 1, -1, -1, 0][row % 6]
                        let band = min(2, row * 3 / max(rows, 1))
                        let owner = band * 2 + (column < midpoint ? 0 : 1)
                        let x = CGFloat(column) * blockWidth
                        let y = CGFloat(row) * blockHeight
                        let avenue: CGFloat = column % 4 == 0 ? 12 : 6
                        let rect = CGRect(x: x + avenue / 2, y: y + 4,
                                          width: blockWidth - avenue, height: blockHeight - 8)
                        let block = Path(roundedRect: rect, cornerRadius: 3)
                        context.fill(block, with: .color(colors[owner].opacity(0.13)))
                        context.stroke(block, with: .color(colors[owner].opacity(0.3)), lineWidth: 0.8)

                        // Small building footprints make the grid read as a city.
                        let building = Path(roundedRect: rect.insetBy(dx: 7, dy: 9), cornerRadius: 1)
                        context.fill(building, with: .color(.white.opacity(0.035)))
                    }
                }

                var boulevard = Path()
                boulevard.move(to: CGPoint(x: -20, y: size.height * 0.72))
                boulevard.addLine(to: CGPoint(x: size.width + 20, y: size.height * 0.31))
                context.stroke(boulevard, with: .color(Color(red: 0.025, green: 0.035, blue: 0.055)), lineWidth: 14)
                context.stroke(boulevard, with: .color(.white.opacity(0.12)), style: StrokeStyle(lineWidth: 1, dash: [5, 6]))

                for index in 0..<6 {
                    let x = index % 2 == 0 ? size.width * 0.065 : size.width * 0.935
                    let y = size.height * (CGFloat(index / 2) / 3 + 0.17)
                    let point = CGPoint(x: x, y: y)
                    // Short opposing routes suggest athletes advancing into nearby blocks.
                    let direction: CGFloat = index % 2 == 0 ? 1 : -1
                    var route = Path()
                    route.move(to: point)
                    route.addLine(to: CGPoint(x: x + direction * 28, y: y))
                    route.addLine(to: CGPoint(x: x + direction * 28, y: y + 34))
                    route.addLine(to: CGPoint(x: x + direction * 65, y: y + 34))
                    context.stroke(route, with: .color(colors[index].opacity(0.4)),
                                   style: StrokeStyle(lineWidth: 1.5, dash: [3, 4]))

                    let badge = Path(ellipseIn: CGRect(x: x - 16, y: y - 16, width: 32, height: 32))
                    context.fill(badge, with: .color(.black.opacity(0.75)))
                    context.stroke(badge, with: .color(colors[index].opacity(0.5)), lineWidth: 1)
                    context.draw(
                        Text(Image(systemName: symbols[index]))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(colors[index].opacity(0.65)),
                        at: point
                    )
                }
            }
            // Keep the central reading column quiet, including while content scrolls.
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.1), location: 0),
                    .init(color: .black.opacity(0.65), location: 0.18),
                    .init(color: .black.opacity(0.82), location: 0.5),
                    .init(color: .black.opacity(0.65), location: 0.82),
                    .init(color: .black.opacity(0.1), location: 1)
                ],
                startPoint: .leading, endPoint: .trailing
            )
            LinearGradient(colors: [.black.opacity(0.35), .clear, .black.opacity(0.4)],
                           startPoint: .top, endPoint: .bottom)
        }
        .allowsHitTesting(false)
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
                .foregroundStyle(.orange)
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

