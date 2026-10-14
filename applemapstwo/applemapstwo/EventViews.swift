import SwiftUI
import MapKit

struct EventMarker: View {
    let event: CityEvent

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(.background)
                    .frame(width: 48, height: 48)
                    .shadow(color: .black.opacity(0.22), radius: 5, y: 2)

                Circle()
                    .fill(event.source.color.gradient)
                    .frame(width: 40, height: 40)

                Image(systemName: event.symbol)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            Text(event.timing.components(separatedBy: " · ").first ?? event.timing)
                .font(.caption2.bold())
                .foregroundStyle(.primary)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(.regularMaterial, in: Capsule())
        }
    }
}

struct EventDetailView: View {
    let event: CityEvent
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    EventDetailHero(event: event)
                    EventSourceCard(source: event.source)

                    if !event.attendees.isEmpty {
                        EventAttendeesSection(attendees: event.attendees)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label(event.venue, systemImage: "mappin.and.ellipse")
                            .font(.headline)
                        Text(event.address)
                            .foregroundStyle(.secondary)
                        Label(event.proximity, systemImage: "figure.walk")
                            .foregroundStyle(.blue)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 18))

                    Text(event.summary)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 12) {
                        Button {
                        } label: {
                            Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                        } label: {
                            Label("Save", systemImage: "bookmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .controlSize(.large)
                }
                .padding(20)
            }
            .navigationTitle("Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.glass)
                    .accessibilityLabel("Close event details")
                }
            }
        }
    }
}

struct EventDetailHero: View {
    let event: CityEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: event.symbol)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(event.source.color.gradient, in: Circle())

                Spacer()

                Text(event.category)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
            }

            Text(event.title)
                .font(.title.bold())

            Label(event.timing, systemImage: "calendar.badge.clock")
                .font(.headline)
                .foregroundStyle(event.source.color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EventSourceCard: View {
    let source: EventSource

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: source.symbol)
                .font(.title3)
                .foregroundStyle(source.color)
                .frame(width: 38, height: 38)
                .background(source.color.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(source.attribution)
                    .font(.headline)
                Text(source.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.green)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct EventAttendeesSection: View {
    let attendees: [EventAttendee]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Going with you")
                .font(.headline)

            HStack(spacing: -8) {
                ForEach(attendees) { attendee in
                    Circle()
                        .fill(attendee.color.gradient)
                        .frame(width: 46, height: 46)
                        .overlay {
                            Text(attendee.initials)
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                        .overlay {
                            Circle()
                                .stroke(.background, lineWidth: 3)
                        }
                        .accessibilityLabel(attendee.name)
                }

                Spacer()

                Text(attendees.map(\.name).formatted())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: 210, alignment: .trailing)
            }
        }
        .padding(16)
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct EventFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isEnabled: Bool
    @Binding var visibleSources: Set<EventSource>
    @Binding var hiddenEventIDs: Set<String>
    let events: [CityEvent]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Toggle(isOn: masterVisibilityBinding) {
                        Label {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Show Events on Map")
                                    .font(.headline)
                                Text("Turn off all event suggestions and calendar plans.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title2)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))

                    if isEnabled {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Event Sources")
                                .font(.headline)

                            ForEach(EventSource.allCases) { source in
                                Toggle(isOn: sourceVisibilityBinding(for: source)) {
                                    Label(source.title, systemImage: source.symbol)
                                        .foregroundStyle(source.color)
                                }
                                .tint(source.color)
                                .padding(.horizontal, 14)
                                .frame(minHeight: 50)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Individual Events")
                                .font(.headline)

                            ForEach(events) { event in
                                if visibleSources.contains(event.source) {
                                    Toggle(isOn: eventVisibilityBinding(for: event.id)) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(event.title)
                                                .font(.body.weight(.medium))
                                            Text("\(event.timing) · \(event.source.title)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .tint(event.source.color)
                                    .padding(.horizontal, 14)
                                    .frame(minHeight: 58)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(.ultraThinMaterial)
            .navigationTitle("Event Filters")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.glass)
                    .accessibilityLabel("Close event filters")
                }
            }
        }
    }

    private var masterVisibilityBinding: Binding<Bool> {
        Binding(
            get: { isEnabled },
            set: { newValue in
                isEnabled = newValue
                if newValue, visibleSources.isEmpty {
                    visibleSources = Set(EventSource.allCases)
                }
            }
        )
    }

    private func sourceVisibilityBinding(for source: EventSource) -> Binding<Bool> {
        Binding(
            get: { visibleSources.contains(source) },
            set: { isVisible in
                if isVisible {
                    visibleSources.insert(source)
                } else {
                    visibleSources.remove(source)
                }
            }
        )
    }

    private func eventVisibilityBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { !hiddenEventIDs.contains(id) },
            set: { isVisible in
                if isVisible {
                    hiddenEventIDs.remove(id)
                } else {
                    hiddenEventIDs.insert(id)
                }
            }
        )
    }
}
