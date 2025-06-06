import SwiftUI
import PhotosUI

struct AddPlantForm: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: PlantStore
    
    // Required fields
    @State private var name: String
    @State private var scientificName: String?
    @State private var description: String?
    @State private var selectedImage: UIImage?
    
    // Optional fields
    @State private var age: String = ""
    @State private var temp: String = ""
    @State private var light: String = ""
    @State private var humidity: String = ""
    @State private var fertilizer: String = ""
    @State private var notes: String = ""
    
    // UI State
    @State private var showImagePicker = false
    @State private var showingDeleteAlert = false
    
    init(name: String, scientificName: String? = nil, description: String? = nil, image: UIImage? = nil) {
        _name = State(initialValue: name)
        _scientificName = State(initialValue: scientificName)
        _description = State(initialValue: description)
        _selectedImage = State(initialValue: image)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Plant Image Section
                Section {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                    }
                    
                    Button(selectedImage == nil ? "Add Photo" : "Change Photo") {
                        showImagePicker = true
                    }
                } header: {
                    Text("Plant Photo")
                }
                
                // Basic Information Section
                Section {
                    TextField("Plant Name", text: $name)
                    
                    if let scientificName = scientificName {
                        Text("Scientific Name: \(scientificName)")
                            .foregroundColor(.gray)
                    }
                    
                    if let description = description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Age (Optional)", text: $age)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Basic Information")
                }
                
                // Care Requirements Section
                Section {
                    TextField("Temperature", text: $temp)
                        .keyboardType(.decimalPad)
                    
                    TextField("Light Requirements", text: $light)
                    
                    TextField("Humidity", text: $humidity)
                        .keyboardType(.decimalPad)
                    
                    TextField("Fertilizer (Optional)", text: $fertilizer)
                } header: {
                    Text("Care Requirements")
                }
                
                // Notes Section
                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("Add New Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlant()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                PhotoPicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func savePlant() {
        var newPlant = Plant(
            name: name,
            scientificName: scientificName,
            description: description,
            age: age.isEmpty ? nil : age,
            temp: temp.isEmpty ? nil : temp,
            light: light.isEmpty ? nil : light,
            humidity: humidity.isEmpty ? nil : humidity,
            fertilizer: fertilizer.isEmpty ? nil : fertilizer,
            notes: notes.isEmpty ? nil : notes,
            careHistory: []
        )
        
        // Save the image if one was selected
        if let selectedImage = selectedImage {
            let imageName = "\(UUID().uuidString).jpg"
            if let savedPath = selectedImage.saveToDocuments(withName: imageName) {
                newPlant.imagePath = savedPath
            }
        }
        
        store.add(plant: newPlant)
        dismiss()
    }
}

// Helper struct for PHPickerViewController
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

struct AddPlantForm_Previews: PreviewProvider {
    static var previews: some View {
        AddPlantForm(
            name: "Monstera Deliciosa",
            scientificName: "Monstera deliciosa",
            description: "A popular houseplant known for its distinctive split leaves.",
            image: nil
        )
        .environmentObject(PlantStore())
    }
}

// Extension to UIImage for saving to Documents directory
extension UIImage {
    func saveToDocuments(withName name: String) -> String? {
        guard let data = self.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        
        do {
            try data.write(to: filename)
            return filename.path
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
} 