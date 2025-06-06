import Foundation

class PlantStore: ObservableObject {
    @Published var plants: [Plant] = [] {
        didSet { save() }
    }
    private let key = "plants_v1"
    
    init() {
        load()
    }
    
    func add(_ plant: Plant) {
        plants.append(plant)
    }
    
    func update(_ plant: Plant) {
        if let idx = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[idx] = plant
        }
    }
    
    func delete(_ plant: Plant) {
        plants.removeAll { $0.id == plant.id }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            plants = decoded
        } else {
            plants = []
        }
    }
}

// Make Plant and CareEvent Codable
extension Plant: Codable {}
extension CareEvent: Codable {} 