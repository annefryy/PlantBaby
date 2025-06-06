import SwiftUI

struct DashboardView: View {
    let stats = [
        ("Temp", "24°C", "thermometer"),
        ("Humidity", "76%", "humidity"),
        ("CO₂", "614", "leaf")
    ]
    let plants = [
        ("Tomato", "leaf"),
        ("Cucumber", "leaf"),
        ("Bell pepper", "leaf")
    ]
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("My plants")
                    .font(.title.bold())
                Spacer()
                Button(action: {}) {
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding([.horizontal, .top])
            
            // Stats
            HStack(spacing: 16) {
                ForEach(stats, id: \.(0)) { stat in
                    StatCardView(title: stat.0, value: stat.1, icon: stat.2)
                }
            }
            .padding(.vertical)
            
            // Alerts
            VStack(alignment: .leading, spacing: 8) {
                Text("Alerts")
                    .font(.headline)
                AlertCardView(plantName: "Eggplant", message: "This plant needs water (110ml)")
            }
            .padding(.horizontal)
            
            // Plant Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(plants, id: \.(0)) { plant in
                        PlantCardView(plantName: plant.0, imageName: plant.1, isSelected: plant.0 == "Cucumber")
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
            
            Spacer()
            
            // Bottom Navigation
            HStack {
                Spacer()
                Image(systemName: "leaf")
                    .font(.title2)
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 48, height: 48)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                Spacer()
                Image(systemName: "chart.bar")
                    .font(.title2)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
} 