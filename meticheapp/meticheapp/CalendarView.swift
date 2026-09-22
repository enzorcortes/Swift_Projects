import SwiftUI

struct CalendarView: View {
    let store: ConstellationStore
    @State private var selectedDate = Date.now
    @State private var isAddingEvent = false
    @State private var isShowingConnections = false

    private var selectedDayEvents: [SocialEvent] {
        store.events
            .filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) }
            .sorted { $0.startDate < $1.startDate }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    CalendarHero(
                        eventCount: store.upcomingEvents.count,
                        peopleCount: Set(store.upcomingEvents.flatMap(\.attendeeIDs)).count,
                        onAdd: { isAddingEvent = true },
                        onConnect: { isShowingConnections = true }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Browse dates") {
                    DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }

                Section("Selected day") {
                    if selectedDayEvents.isEmpty {
                        ContentUnavailableView("Nothing planned", systemImage: "calendar", description: Text("Add something for this circle or choose another date."))
                    } else {
                        ForEach(selectedDayEvents) { event in
                            NavigationLink(value: event.id) {
                                CalendarEventRow(event: event, group: event.groupID.flatMap(store.group(withID:)))
                            }
                        }
                    }
                }

                Section("Coming up") {
                    ForEach(store.upcomingEvents) { event in
                        NavigationLink(value: event.id) {
                            CalendarEventRow(event: event, group: event.groupID.flatMap(store.group(withID:)))
                        }
                    }
                }
            }
            .navigationTitle("Calendar")
            .navigationDestination(for: UUID.self) { eventID in
                CalendarEventDetail(store: store, eventID: eventID)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingEvent = true
                    } label: {
                        Label("Add event", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingEvent) {
                AddSocialEventView(store: store, initialDate: selectedDate)
            }
            .sheet(isPresented: $isShowingConnections) {
                CalendarConnectionsView()
            }
        }
    }
}

private struct CalendarHero: View {
    let eventCount: Int
    let peopleCount: Int
    let onAdd: () -> Void
    let onConnect: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.circle.fill")
                .font(.system(size: 64))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .blue)
            Text("Your Shared Calendar")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("Plans, events, notes, and the people involved—all in one place.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 24) {
                Label("\(eventCount) upcoming", systemImage: "calendar.badge.clock")
                Label("\(peopleCount) people", systemImage: "person.2.fill")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.blue)
            HStack {
                Button("New Event", systemImage: "plus", action: onAdd)
                Button("Calendars", systemImage: "arrow.triangle.2.circlepath", action: onConnect)
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
    }
}

private struct CalendarEventRow: View {
    let event: SocialEvent
    let group: FriendGroup?

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(event.startDate, format: .dateTime.day())
                    .font(.title2.bold())
                Text(event.startDate, format: .dateTime.month(.abbreviated))
                    .font(.caption.bold())
                    .textCase(.uppercase)
            }
            .foregroundStyle(.white)
            .frame(width: 54, height: 58)
            .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title).font(.headline)
                Text(event.startDate, format: .dateTime.hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    if let group {
                        Label(group.name, systemImage: group.symbol)
                    }
                    Label(event.sourceName, systemImage: "arrow.triangle.2.circlepath")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct CalendarEventDetail: View {
    let store: ConstellationStore
    let eventID: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var checklistText = ""
    @State private var isConfirmingDelete = false

    private var event: SocialEvent? {
        store.events.first { $0.id == eventID }
    }

    var body: some View {
        List {
            if let event {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(event.title).font(.title.bold())
                        Label {
                            Text(event.startDate, format: .dateTime.weekday(.wide).month(.wide).day().hour().minute())
                        } icon: { Image(systemName: "calendar") }
                        if let locationName = event.locationName {
                            Label(locationName, systemImage: "mappin.and.ellipse")
                        }
                        Label("From \(event.sourceName)", systemImage: "arrow.triangle.2.circlepath")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                if !event.notes.isEmpty {
                    Section("Notes") {
                        Text(event.notes)
                    }
                }
                Section("People") {
                    ForEach(event.attendeeIDs, id: \.self) { personID in
                        if let person = store.person(withID: personID) {
                            HStack(spacing: 10) {
                                AvatarView(imageData: person.avatarData, initials: person.initials, color: person.color, size: 36)
                                Text(person.name)
                                Spacer()
                                Button {
                                    store.toggleAttendee(personID, in: eventID)
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Remove \(person.name) from event")
                            }
                        }
                    }
                    Menu("Add Person", systemImage: "person.badge.plus") {
                        ForEach(store.people.filter { !event.attendeeIDs.contains($0.id) }) { person in
                            Button(person.name) { store.toggleAttendee(person.id, in: eventID) }
                        }
                    }
                }
                Section("Bring & prepare") {
                    ForEach(event.checklist) { item in
                        Button {
                            store.toggleChecklistItem(item.id, in: eventID)
                        } label: {
                            Label(item.title, systemImage: item.isComplete ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isComplete ? .green : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                    HStack {
                        TextField("Add checklist item", text: $checklistText)
                        Button("Add") {
                            store.addChecklistItem(checklistText, to: eventID)
                            checklistText = ""
                        }
                        .disabled(checklistText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                Section {
                    Button("Delete from Constella", systemImage: "trash", role: .destructive) {
                        isConfirmingDelete = true
                    }
                }
            }
        }
        .navigationTitle("Event")
        .confirmationDialog("Delete this event from Constella?", isPresented: $isConfirmingDelete) {
            Button("Delete Event", role: .destructive) {
                store.deleteEvent(eventID)
                dismiss()
            }
        }
    }
}

private struct AddSocialEventView: View {
    let store: ConstellationStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var locationName = ""
    @State private var notes = ""
    @State private var groupID: UUID?
    @State private var attendeeIDs = Set<UUID>()

    init(store: ConstellationStore, initialDate: Date) {
        self.store = store
        let start = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: initialDate) ?? initialDate
        _startDate = State(initialValue: start)
        _endDate = State(initialValue: start.addingTimeInterval(60 * 60 * 2))
        _attendeeIDs = State(initialValue: [store.currentUserID])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event") {
                    TextField("Event name", text: $title)
                    DatePicker("Starts", selection: $startDate)
                    DatePicker("Ends", selection: $endDate, in: startDate...)
                    TextField("Location", text: $locationName)
                    Picker("Circle", selection: $groupID) {
                        Text("No circle").tag(nil as UUID?)
                        ForEach(store.groups) { group in
                            Text(group.name).tag(group.id as UUID?)
                        }
                    }
                }
                Section("Notes") {
                    TextField("Details, dietary needs, reminders…", text: $notes, axis: .vertical)
                        .lineLimit(3...7)
                }
                Section("People") {
                    ForEach(store.people) { person in
                        Button {
                            if attendeeIDs.contains(person.id) {
                                attendeeIDs.remove(person.id)
                            } else {
                                attendeeIDs.insert(person.id)
                            }
                        } label: {
                            HStack {
                                Text(person.name)
                                Spacer()
                                if attendeeIDs.contains(person.id) {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addEvent(
                            title: title,
                            startDate: startDate,
                            endDate: endDate,
                            locationName: locationName,
                            notes: notes,
                            groupID: groupID,
                            attendeeIDs: Array(attendeeIDs)
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.large])
    }
}

private struct CalendarConnectionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var message: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Available connections") {
                    connectionRow(name: "Apple Calendar", subtitle: "Device calendars through EventKit", symbol: "apple.logo")
                    connectionRow(name: "Google Calendar", subtitle: "Account sync through Google OAuth", symbol: "g.circle.fill")
                }
                Section {
                    Text("Calendar access is always optional. Constella should import only calendars and events you explicitly choose, and circle members see only events shared with them.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Connected Calendars")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .alert("Connection Setup", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
                Button("OK") { message = nil }
            } message: {
                Text(message ?? "")
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func connectionRow(name: String, subtitle: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.title2)
                .frame(width: 36)
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button("Connect") {
                message = "This prototype has the connection point ready. Production setup requires provider credentials and the appropriate calendar permission description."
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }
}
