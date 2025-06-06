import SwiftUI

struct AddPlantSelectionView: View {
    @State private var showingIdentifySheet = false
    @State private var showingManualEntry = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("Add New Plant")
                        .font(.largeTitle.bold())
                    Text("Choose how you'd like to add your plant")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Options
                VStack(spacing: 20) {
                    // Identify Plant Option
                    Button(action: { showingIdentifySheet = true }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title)
                            VStack(alignment: .leading) {
                                Text("Identify Plant")
                                    .font(.headline)
                                Text("Take a photo to identify your plant")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    // Manual Entry Option
                    Button(action: { showingManualEntry = true }) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.title)
                            VStack(alignment: .leading) {
                                Text("Manual Entry")
                                    .font(.headline)
                                Text("Add your plant details manually")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingIdentifySheet) {
                IdentifyPlantView()
            }
            .sheet(isPresented: $showingManualEntry) {
                AddPlantForm(name: "")
            }
        }
    }
}

struct AddPlantSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlantSelectionView()
            .environmentObject(PlantStore())
    }
} 