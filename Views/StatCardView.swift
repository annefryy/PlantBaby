import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct StatCardView_Previews: PreviewProvider {
    static var previews: some View {
        StatCardView(title: "Temp", value: "24°C", icon: "thermometer")
    }
} 