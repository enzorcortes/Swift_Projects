import SwiftUI

struct RecordWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSport = Sport.running

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Picker("Sport", selection: $selectedSport) {
                    ForEach(Sport.allCases) { sport in
                        Label(sport.title, systemImage: sport.systemImage)
                            .tag(sport)
                    }
                }
                .pickerStyle(.segmented)

                Image(systemName: selectedSport.systemImage)
                    .font(.system(size: 68))
                    .foregroundStyle(selectedSport.color)

                Text(selectedSport == .swimming ? "Choose your pool, then record on Apple Watch for lap and stroke verification." : "Record with this iPhone or Apple Watch. Your GPS route can capture territory when it forms a closed loop.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button(selectedSport == .swimming ? "Start on Apple Watch" : "Start on iPhone", systemImage: selectedSport == .swimming ? "applewatch" : "iphone") { }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                if selectedSport != .swimming {
                    Button("Start on Apple Watch", systemImage: "applewatch") { }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Record Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

