import SwiftUI
import PhotosUI

struct IdentifyPlantView: View {
    @EnvironmentObject var store: PlantStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedImage: UIImage? = nil
    @State private var isLoading = false
    @State private var suggestions: [Suggestion] = []
    @State private var selectedSuggestion: Suggestion? = nil
    @State private var showAddForm = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert = false
    @State private var showingSourceTypeSelection = false
    @State private var selectedSourceType: UIImagePickerController.SourceType? = nil
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Identify Your Plant")
                        .font(.largeTitle.bold())
                        .padding(.top)
                    
                    Text("Take a clear photo of your plant's leaves for the best results.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Image Preview
                    ZStack {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        } else {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 300)
                                .overlay(
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.gray)
                                        Text("Tap to add photo")
                                            .foregroundColor(.gray)
                                            .padding(.top, 8)
                                    }
                                )
                        }
                    }
                    .onTapGesture {
                        showingSourceTypeSelection = true
                    }

                    // Action Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            showingSourceTypeSelection = true
                        }) {
                            Label("Take Photo", systemImage: "camera")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if selectedImage != nil {
                            Button(action: {
                                selectedImage = nil
                                suggestions = []
                                selectedSuggestion = nil
                            }) {
                                Label("Clear", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.horizontal)

                    // Loading State
                    if isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Analyzing plant...")
                                .foregroundColor(.gray)
                                .padding(.top)
                        }
                        .padding()
                    }

                    // Results
                    if !suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Suggestions")
                                .font(.title2.bold())
                                .padding(.horizontal)
                            
                            ForEach(suggestions.prefix(3)) { suggestion in
                                SuggestionCard(suggestion: suggestion, selectedImage: selectedImage)
                                    .onTapGesture {
                                        selectedSuggestion = suggestion
                                    }
                            }
                        }
                        .padding(.top)
                    }
                }
                .padding()
            }
            .navigationTitle("Identify Plant")
            .navigationBarTitleDisplayMode(.inline)
            
            // Action Sheet
            .actionSheet(isPresented: $showingSourceTypeSelection) {
                ActionSheet(
                    title: Text("Choose Image Source"),
                    message: Text("Select where to get your plant photo from"),
                    buttons: [
                        .default(Text("Camera")) {
                            selectedSourceType = .camera
                            showImagePicker = true
                        },
                        .default(Text("Photo Library")) {
                            selectedSourceType = .photoLibrary
                            showImagePicker = true
                        },
                        .cancel()
                    ]
                )
            }
            
            // Image Picker
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: selectedSourceType ?? .photoLibrary) { uiImage in
                    if let uiImage = uiImage {
                        selectedImage = uiImage
                        identifyPlant(image: uiImage)
                    }
                }
            }
            
            // Navigation to Add Plant Form
            .navigationDestination(item: $selectedSuggestion) { suggestion in
                AddPlantForm(
                    name: suggestion.name,
                    scientificName: suggestion.details.scientificName,
                    description: suggestion.details.description,
                    image: selectedImage
                )
            }
            
            // Error Alert
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }
    
    private func identifyPlant(image: UIImage) {
        isLoading = true
        suggestions = []
        errorMessage = nil
        
        Task {
            do {
                let results = try await PlantIDService.identifyPlant(image: image)
                await MainActor.run {
                    suggestions = results
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    isLoading = false
                }
            }
        }
    }
}

struct SuggestionCard: View {
    let suggestion: Suggestion
    let selectedImage: UIImage?
    
    var body: some View {
        HStack(spacing: 15) {
            // Plant Image
            if let imageUrl = suggestion.images.first?.url,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                    .frame(width: 80, height: 80)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.name)
                    .font(.headline)
                
                if let commonNames = suggestion.details.commonNames,
                   !commonNames.isEmpty {
                    Text(commonNames.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text("\(Int(suggestion.probability * 100))% match")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct IdentifyPlantView_Previews: PreviewProvider {
    static var previews: some View {
        IdentifyPlantView()
            .environmentObject(PlantStore())
    }
} 