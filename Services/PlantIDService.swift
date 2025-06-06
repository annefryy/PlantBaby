import Foundation
import UIKit

struct PlantIDResponse: Decodable {
    let result: ClassificationResult
}

struct ClassificationResult: Decodable {
    let classification: Classification
}

struct Classification: Decodable {
    let suggestions: [Suggestion]
}

struct Suggestion: Decodable, Identifiable {
    let id: String
    let name: String
    let probability: Double
    let details: PlantDetails
    let images: [PlantImage]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case probability = "probability"
        case details = "details"
        case images = "similar_images"
    }
}

struct PlantDetails: Decodable {
    let commonNames: [String]?
    let scientificName: String?
    let description: String?
    let wikiDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case commonNames = "common_names"
        case scientificName = "scientific_name"
        case description = "description"
        case wikiDescription = "wiki_description"
    }
}

struct PlantImage: Decodable {
    let url: String
    let similarity: Double
}

enum PlantIDError: Error {
    case imageConversionFailed
    case invalidResponse
    case apiError(String)
    case decodingError
}

class PlantIDService {
    static let apiKey = "TSR8FC3mGjsb5ajDgU0lB3grPISFKCzrpa3fy184h8gwolTpwD"
    static let endpoint = "https://api.plant.id/v2/identify"
    
    static func identifyPlant(image: UIImage) async throws -> [Suggestion] {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw PlantIDError.imageConversionFailed
        }
        
        let base64 = imageData.base64EncodedString()
        let payload: [String: Any] = [
            "images": [base64],
            "organs": ["leaf"],
            "similar_images": true,
            "details": [
                "common_names",
                "scientific_name",
                "description",
                "wiki_description"
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            throw PlantIDError.decodingError
        }
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Api-Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PlantIDError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorJson["message"] as? String {
                throw PlantIDError.apiError(message)
            }
            throw PlantIDError.apiError("Unknown error occurred")
        }
        
        do {
            let plantIDResponse = try JSONDecoder().decode(PlantIDResponse.self, from: data)
            return plantIDResponse.result.classification.suggestions
        } catch {
            print("Decoding error: \(error)")
            throw PlantIDError.decodingError
        }
    }
} 