import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var store: PlantStore
    
    var body: some View {
        NavigationView {
            List {
                // Overview Section
                Section {
                    StatCard(
                        title: "Total Plants",
                        value: "\(store.totalPlants)",
                        icon: "leaf.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Plants Needing Water",
                        value: "\(store.plantsNeedingWater)",
                        icon: "drop.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Plants Needing Fertilizer",
                        value: "\(store.plantsNeedingFertilizer)",
                        icon: "leaf.fill",
                        color: .orange
                    )
                } header: {
                    Text("Overview")
                }
                
                // Care History Section
                Section {
                    StatCard(
                        title: "Total Care Events",
                        value: "\(store.totalCareEvents)",
                        icon: "calendar",
                        color: .purple
                    )
                    
                    if let mostCommon = store.mostCommonPlant {
                        StatCard(
                            title: "Most Common Plant",
                            value: mostCommon,
                            icon: "star.fill",
                            color: .yellow
                        )
                    }
                } header: {
                    Text("Care History")
                }
                
                // Plant Types Section
                Section {
                    ForEach(store.plants) { plant in
                        HStack {
                            if let image = plant.uiImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "leaf.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(8)
                                    .frame(width: 40, height: 40)
                                    .background(Color.green.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(plant.name)
                                    .font(.headline)
                                if let scientificName = plant.scientificName {
                                    Text(scientificName)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(plant.careHistory.count) events")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Your Plants")
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title2.bold())
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environmentObject(PlantStore())
    }
} 