import SwiftUI

struct AlertCardView: View {
    let plantName: String
    let message: String
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text(plantName)
                    .font(.headline)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct AlertCardView_Previews: PreviewProvider {
    static var previews: some View {
        AlertCardView(plantName: "Eggplant", message: "This plant needs water (110ml)")
    }
} 