import SwiftUI

struct PlantDetailView: View {
    @State var plant: Plant
    var onUpdate: ((Plant) -> Void)? = nil
    var onDelete: ((Plant) -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    @State private var showEdit = false
    @State private var showDeleteAlert = false
    @State private var showLogCare = false
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding([.horizontal, .top])
            
            // Plant Name & Age
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.largeTitle.bold())
                Text(plant.age)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Display Next Care Date
                if let nextCareDate = plant.nextCareDate {
                    Text("Next Care: \(nextCareDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Plant Image
            if let uiImage = plant.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                    .padding(.vertical, 8)
            } else if let imageUrl = plant.imageUrl, let url = URL(string: imageUrl), imageUrl.hasPrefix("http") {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(height: 220)
                .padding(.vertical, 8)
            } else {
                Image(systemName: "leaf")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                    .foregroundColor(.green)
                    .padding(.vertical, 8)
            }
            
            // Care Stats
            VStack(spacing: 16) {
                StatCardView(title: "Temp", value: plant.temp, icon: "thermometer")
                StatCardView(title: "Light", value: plant.light, icon: "sun.max")
                StatCardView(title: "Humidity", value: plant.humidity, icon: "humidity")
                StatCardView(title: "Fertilizer", value: plant.fertilizer, icon: "leaf")
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Care History
            VStack(alignment: .leading, spacing: 8) {
                Text("Care History")
                    .font(.headline)
                    .padding(.top)
                if plant.careHistory.isEmpty {
                    Text("No care events yet.")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(plant.careHistory.sorted { $0.date > $1.date }) { event in
                        HStack {
                            Text(event.type.rawValue)
                                .font(.subheadline.bold())
                            Spacer()
                            Text(event.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let note = event.note, !note.isEmpty {
                                Text(note)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
            
            // Actions
            HStack(spacing: 24) {
                Button(action: { showEdit = true }) {
                    Label("Edit", systemImage: "pencil")
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                Button(action: { showDeleteAlert = true }) {
                    Label("Delete", systemImage: "trash")
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
                Button(action: { showLogCare = true }) {
                    Label("Log Care", systemImage: "plus")
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 24)
            
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(.systemGreen).opacity(0.08), Color(.systemBackground)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .sheet(isPresented: $showEdit) {
            EditPlantForm(plant: $plant) { updated in
                plant = updated
                onUpdate?(updated)
            }
        }
        .sheet(isPresented: $showLogCare) {
            LogCareForm { event, date in
                plant.careHistory.append(event)
                plant.nextCareDate = date
                onUpdate?(plant)
            }
        }
        .alert("Delete Plant?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { onDelete?(plant); dismiss() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

struct LogCareForm: View {
    @Environment(\.dismiss) var dismiss
    @State private var type: CareType = .watering
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var setNextCareDate = false
    @State private var nextCareDate: Date = Date().addingTimeInterval(86400 * 7)
    var onSave: (CareEvent, Date?) -> Void
    var body: some View {
        NavigationView {
            Form {
                Picker("Type", selection: $type) {
                    ForEach(CareType.allCases) {
                        Text($0.description).tag($0)
                    }
                }
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Note (optional)", text: $note)

                Section {
                    Toggle("Set Next Care Date", isOn: $setNextCareDate.animation())

                    if setNextCareDate {
                        DatePicker("Next Care Date", selection: $nextCareDate, in: Date()..., displayedComponents: .date)
                    }
                }

            }
            .navigationTitle("Log Care")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let event = CareEvent(type: type, date: date, note: note.isEmpty ? nil : note)
                        onSave(event, setNextCareDate ? nextCareDate : nil)
                        dismiss()
                    }
                    .disabled(false)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct EditPlantForm: View {
    @Environment(\.dismiss) var dismiss
    @Binding var plant: Plant
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var imageUrl: String = ""
    @State private var imagePath: String? = nil
    var onSave: ((Plant) -> Void)? = nil
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Age", text: $age)
                TextField("Image URL", text: $imageUrl)
            }
            .navigationTitle("Edit Plant")
            .onAppear {
                name = plant.name
                age = plant.age
                imageUrl = plant.imageUrl ?? ""
                imagePath = plant.imagePath
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updated = Plant(
                            id: plant.id,
                            name: name,
                            age: age,
                            imageUrl: imageUrl.isEmpty ? nil : imageUrl,
                            imagePath: imagePath,
                            temp: plant.temp,
                            light: plant.light,
                            humidity: plant.humidity,
                            fertilizer: plant.fertilizer,
                            careHistory: plant.careHistory,
                            nextCareDate: plant.nextCareDate
                        )
                        plant = updated
                        onSave?(updated)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct PlantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PlantDetailView(
            plant: Plant(
                name: "Bell pepper",
                age: "26 weeks",
                imageUrl: "https://images.unsplash.com/photo-1501004318641-b39e641bec6",
                temp: "24°C",
                light: "76%",
                humidity: "60%",
                fertilizer: "87%",
                careHistory: [
                    CareEvent(type: .watering, date: Date().addingTimeInterval(-86400), note: "200ml"),
                    CareEvent(type: .fertilizing, date: Date().addingTimeInterval(-604800), note: "Organic")
                ],
                nextCareDate: Date().addingTimeInterval(86400 * 3)
            )
        )
    }
} 