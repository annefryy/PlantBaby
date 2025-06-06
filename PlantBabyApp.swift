import SwiftUI

struct AddPlantView: View {
    @EnvironmentObject var store: PlantStore
    @State private var showForm = false
    var body: some View {
        VStack {
            Spacer()
            Button(action: { showForm = true }) {
                VStack {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    Text("Add New Plant")
                        .font(.title)
                        .padding()
                }
            }
            .sheet(isPresented: $showForm) {
                AddPlantForm { plant in
                    store.add(plant)
                    showForm = false
                }
            }
            Spacer()
        }
    }
}

struct StatisticsView: View {
    var body: some View {
        VStack {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.green)
            Text("Statistics")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}

@main
struct PlantBabyApp: App {
    @StateObject private var store = PlantStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                DashboardView()
                    .tabItem {
                        Label("My Plants", systemImage: "house")
                    }

                // Use the new selection view here
                AddPlantSelectionView()
                    .tabItem {
                        Label("Add Plant", systemImage: "plus.circle")
                    }

                // Placeholder for Statistics
                Text("Statistics View Placeholder")
                    .tabItem {
                        Label("Statistics", systemImage: "chart.bar")
                    }
            }
            .environmentObject(store) // Make the store available to all tabs
        }
    }
} 