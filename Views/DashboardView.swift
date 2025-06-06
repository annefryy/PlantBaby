import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: PlantStore
    @State private var searchText = ""
    @State private var showingPlantDetail: Plant? = nil
    
    var filteredPlants: [Plant] {
        if searchText.isEmpty {
            return store.plants
        } else {
            return store.plants.filter { plant in
                plant.name.localizedCaseInsensitiveContains(searchText) ||
                (plant.scientificName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // Care Summary Section
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(store.plantsNeedingWater)")
                                .font(.title)
                                .foregroundColor(.blue)
                            Text("Need Water")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(store.plantsNeedingFertilizer)")
                                .font(.title)
                                .foregroundColor(.orange)
                            Text("Need Fertilizer")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(store.totalPlants)")
                                .font(.title)
                                .foregroundColor(.green)
                            Text("Total Plants")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Plants Section
                Section {
                    if filteredPlants.isEmpty {
                        Text("No plants found")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(filteredPlants) { plant in
                            PlantRow(plant: plant)
                                .onTapGesture {
                                    showingPlantDetail = plant
                                }
                        }
                    }
                } header: {
                    Text("My Plants")
                }
            }
            .searchable(text: $searchText, prompt: "Search plants")
            .navigationTitle("Dashboard")
            .sheet(item: $showingPlantDetail) { plant in
                PlantDetailView(plant: plant)
            }
        }
    }
}

struct PlantRow: View {
    let plant: Plant
    
    var body: some View {
        HStack(spacing: 15) {
            // Plant Image
            if let image = plant.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(12)
                    .frame(width: 60, height: 60)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.headline)
                
                if let scientificName = plant.scientificName {
                    Text(scientificName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Care Status
                HStack(spacing: 12) {
                    if let lastWatered = plant.lastWatered {
                        Label(
                            "\(Calendar.current.dateComponents([.day], from: lastWatered, to: Date()).day ?? 0)d",
                            systemImage: "drop.fill"
                        )
                        .font(.caption2)
                        .foregroundColor(.blue)
                    }
                    
                    if let lastFertilized = plant.lastFertilized {
                        Label(
                            "\(Calendar.current.dateComponents([.month], from: lastFertilized, to: Date()).month ?? 0)m",
                            systemImage: "leaf.fill"
                        )
                        .font(.caption2)
                        .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(PlantStore())
    }
} 