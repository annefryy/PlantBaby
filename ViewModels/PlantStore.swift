import Foundation
import SwiftUI

class PlantStore: ObservableObject {
    @Published private(set) var plants: [Plant] = []
    private let saveKey = "SavedPlants"
    
    init() {
        loadPlants()
    }
    
    func add(_ plant: Plant) {
        plants.append(plant)
        savePlants()
    }
    
    func update(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index] = plant
            savePlants()
        }
    }
    
    func delete(_ plant: Plant) {
        plants.removeAll { $0.id == plant.id }
        savePlants()
    }
    
    func addCareEvent(_ event: CareEvent, to plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            var updatedPlant = plant
            updatedPlant.careHistory.append(event)
            
            // Update the last care date based on event type
            switch event.type {
            case .watering:
                updatedPlant.lastWatered = event.date
            case .fertilizing:
                updatedPlant.lastFertilized = event.date
            case .pruning:
                updatedPlant.lastPruned = event.date
            case .repotting:
                updatedPlant.lastRepotted = event.date
            }
            
            plants[index] = updatedPlant
            savePlants()
        }
    }
    
    private func savePlants() {
        if let encoded = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadPlants() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            plants = decoded
        }
    }
    
    // MARK: - Statistics
    
    var totalPlants: Int {
        plants.count
    }
    
    var plantsNeedingWater: Int {
        plants.filter { plant in
            guard let lastWatered = plant.lastWatered else { return true }
            let calendar = Calendar.current
            let daysSinceLastWatered = calendar.dateComponents([.day], from: lastWatered, to: Date()).day ?? 0
            return daysSinceLastWatered >= 7 // Example: plants need water after 7 days
        }.count
    }
    
    var plantsNeedingFertilizer: Int {
        plants.filter { plant in
            guard let lastFertilized = plant.lastFertilized else { return true }
            let calendar = Calendar.current
            let monthsSinceLastFertilized = calendar.dateComponents([.month], from: lastFertilized, to: Date()).month ?? 0
            return monthsSinceLastFertilized >= 1 // Example: plants need fertilizer monthly
        }.count
    }
    
    var mostCommonPlant: String? {
        let plantNames = plants.map { $0.name }
        let counts = plantNames.reduce(into: [:]) { counts, name in
            counts[name, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    var totalCareEvents: Int {
        plants.reduce(0) { $0 + $1.careHistory.count }
    }
} 