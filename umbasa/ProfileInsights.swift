import Charts
import SwiftUI

struct ProfileDeepDiveSections: View {
    var body: some View {
        Section("Running performance") {
            ProfileSpeedTrend()
        }
        Section("Territory · this season") {
            InsightValueRow(title: "Area held", value: "8.7 mi²", detail: "+24.3% from 7.0 mi² last season", systemImage: "map.fill")
            InsightValueRow(title: "Successful defenses", value: "80%", detail: "8 of 10 challenges defended", systemImage: "shield.fill")
            InsightValueRow(title: "Rivalry lead", value: "0.8 mi²", detail: "10.1% more territory than Maya’s 7.9 mi²", systemImage: "bolt.fill")
            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Season goal", value: "87%")
                ProgressView(value: 8.7, total: 10)
                    .tint(.indigo)
                Text("8.7 of 10 mi² · 1.3 mi² to go")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
        Section("Locations crowned · 3") {
            ProfileCrownRow(name: "Butler Trail", sport: "Running", detail: "Captured 18 days ago · 4 successful defenses", symbol: "figure.run")
            ProfileCrownRow(name: "Barton Springs Pool", sport: "Swimming", detail: "Captured 9 days ago · 3 successful defenses", symbol: "figure.pool.swim")
            ProfileCrownRow(name: "Auditorium Shores", sport: "Running", detail: "Captured 3 days ago · 1 successful defense", symbol: "figure.run")
        }
        Section("Training · last 4 weeks") {
            InsightValueRow(title: "Distance", value: "84 mi", detail: "+20% compared with 70 mi in the prior 4 weeks", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
            InsightValueRow(title: "Workouts", value: "20", detail: "+25% compared with 16 in the prior 4 weeks", systemImage: "figure.run")
            InsightValueRow(title: "Plan completion", value: "90%", detail: "18 of 20 planned sessions completed", systemImage: "checkmark.circle.fill")
        }
        Section("Workout mix · last 4 weeks") {
            ProfileSportShare(sport: .running, count: 14, total: 20)
            ProfileSportShare(sport: .swimming, count: 4, total: 20)
            ProfileSportShare(sport: .cycling, count: 2, total: 20)
        }
    }
}

private struct InsightValueRow: View {
    let title: LocalizedStringKey
    let value: String
    let detail: LocalizedStringKey
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                Text(value).font(.headline.monospacedDigit())
            }
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

private struct ProfileSpeedSample: Identifiable {
    let week: Int
    let speed: Double
    var id: Int { week }

    // Weekly average running speeds in mph for the demo.
    static let history: [Self] = [
        .init(week: 1, speed: 6.0), .init(week: 2, speed: 6.1),
        .init(week: 3, speed: 6.15), .init(week: 4, speed: 6.3),
        .init(week: 5, speed: 6.25), .init(week: 6, speed: 6.4),
        .init(week: 7, speed: 6.5), .init(week: 8, speed: 6.6),
        .init(week: 9, speed: 6.65), .init(week: 10, speed: 6.8),
        .init(week: 11, speed: 6.9), .init(week: 12, speed: 7.2)
    ]
}

private struct ProfileSpeedTrend: View {
    @State private var weekCount = 12

    private var samples: [ProfileSpeedSample] {
        Array(ProfileSpeedSample.history.suffix(weekCount))
    }

    private var improvement: Double {
        guard let first = samples.first, let last = samples.last, first.speed > 0 else { return 0 }
        return (last.speed - first.speed) / first.speed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Trend period", selection: $weekCount) {
                Text("4 weeks").tag(4)
                Text("12 weeks").tag(12)
            }
            .pickerStyle(.segmented)

            HStack(alignment: .firstTextBaseline) {
                Text(improvement, format: .percent.precision(.fractionLength(1)))
                    .font(.title.bold())
                    .foregroundStyle(.indigo)
                Text("faster over this period")
                    .font(.subheadline)
            }

            Chart(samples) { sample in
                LineMark(
                    x: .value("Week", sample.week),
                    y: .value("Average speed (mph)", sample.speed)
                )
                .foregroundStyle(.indigo)
                .symbol(.circle)
            }
            .chartXAxisLabel("Training week")
            .chartYAxisLabel("mph")
            .chartYScale(domain: 0...8)
            .frame(height: 190)
            .accessibilityLabel("Weekly average running speed")

            if let first = samples.first, let last = samples.last {
                LabeledContent("Average speed") {
                    Text("\(first.speed, specifier: "%.2f") → \(last.speed, specifier: "%.2f") mph")
                }
                LabeledContent("Equivalent pace") {
                    Text("\(pace(for: first.speed)) → \(pace(for: last.speed)) /mi")
                }
            }
            Text("Compares the first and latest weekly average in the selected period. Higher speed means a lower time per mile.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    private func pace(for speed: Double) -> String {
        let seconds = Int((3600 / speed).rounded())
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

private struct ProfileCrownRow: View {
    let name: String
    let sport: LocalizedStringKey
    let detail: LocalizedStringKey
    let symbol: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.title2)
                .foregroundStyle(.orange)
                .padding(10)
                .background(.orange.opacity(0.1), in: .circle)
            VStack(alignment: .leading, spacing: 5) {
                Text(name).font(.headline)
                Label(sport, systemImage: symbol).font(.caption.bold())
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

private struct ProfileSportShare: View {
    let sport: Sport
    let count: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(sport.title, systemImage: sport.systemImage)
                Spacer()
                Text(Double(count) / Double(total), format: .percent.precision(.fractionLength(0)))
                    .font(.headline)
            }
            ProgressView(value: Double(count), total: Double(total))
                .tint(sport.color)
            Text("\(count) of \(total) workouts")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}
