import SwiftUI

struct PlantCardView: View {
    let plantName: String
    let imageName: String
    let isSelected: Bool
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.top, 8)
                Text(plantName)
                    .font(.headline)
                    .padding(.bottom, 8)
            }
            .frame(width: 120, height: 140)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 4)
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .background(Color.white.clipShape(Circle()))
                    .offset(x: -8, y: 8)
            }
        }
    }
}

struct PlantCardView_Previews: PreviewProvider {
    static var previews: some View {
        PlantCardView(plantName: "Tomato", imageName: "leaf", isSelected: true)
    }
} 