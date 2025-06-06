import SwiftUI
import Kingfisher // Assuming Kingfisher is used for async image loading

struct PlantCardView: View {
    let plant: Plant // Now takes a Plant object

    // Computed property to check if care is due soon (e.g., within 3 days)
    private var isCareDueSoon: Bool {
        if let nextCareDate = plant.nextCareDate {
            return nextCareDate > Date() && nextCareDate <= Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        } else {
            return false
        }
    }

    // Computed property to check if care is overdue
    private var isCareOverdue: Bool {
         if let nextCareDate = plant.nextCareDate {
             return nextCareDate <= Date()
         } else {
             return false
         }
    }

    var body: some View {
        HStack {
            // Plant Image
            if let uiImage = plant.uiImage { // Use local image if available
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .clipped()
            } else if let imageUrl = plant.imageUrl, let url = URL(string: imageUrl) { // Otherwise, load from URL
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .clipped()
            } else { // Placeholder
                Image(systemName: "leaf")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(plant.age)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Display next care date and indicator
                if let nextCareDate = plant.nextCareDate {
                    HStack {
                         Image(systemName: isCareOverdue ? "exclamationmark.triangle.fill" : "calendar")
                             .foregroundColor(isCareOverdue ? .red : isCareDueSoon ? .orange : .blue)
                         Text("Care: \(nextCareDate, style: .date)")
                             .font(.caption)
                             .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct PlantCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Add previews with and without care dates
        VStack {
            PlantCardView(plant: Plant(name: "Fiddle Leaf Fig", age: "1 year", imageUrl: "https://images.unsplash.com/photo-1626042403757-8f61162039bf?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80", temp: "", light: "", humidity: "", fertilizer: "", careHistory: [], nextCareDate: Date().addingTimeInterval(86400 * 2)))
            PlantCardView(plant: Plant(name: "Snake Plant", age: "6 months", imageUrl: "https://images.unsplash.com/photo-1599947980010-b5a3b29b6225?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80", temp: "", light: "", humidity: "", fertilizer: "", careHistory: [], nextCareDate: Date().addingTimeInterval(86400 * 5)))
            PlantCardView(plant: Plant(name: "ZZ Plant", age: "2 years", imageUrl: "https://images.unsplash.com/photo-1601984987641-b8c10314354d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80", temp: "", light: "", humidity: "", fertilizer: "", careHistory: [])) // No next care date
            PlantCardView(plant: Plant(name: "Overdue Plant", age: "1 month", imageUrl: "https://images.unsplash.com/photo-1599947980010-b5a3b29b6225?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80", temp: "", light: "", humidity: "", fertilizer: "", careHistory: [], nextCareDate: Date().addingTimeInterval(-86400 * 2))) // Overdue
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 