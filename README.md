# PlantBaby 🌱

PlantBaby is an iOS app that helps plant enthusiasts identify, track, and care for their plants. Using advanced plant identification technology and intuitive care tracking features, PlantBaby makes plant parenthood easier and more enjoyable.

## Features

### 🌿 Plant Identification
- Take photos of your plants to identify them instantly
- Get scientific names and detailed descriptions
- View similar plant images for verification
- Powered by Plant.id API for accurate identification

### 📱 User Interface
- Clean, modern design with intuitive navigation
- Tab-based interface for easy access to all features
- Beautiful plant cards with care status indicators
- Search functionality to quickly find your plants

### 🌡️ Plant Care Tracking
- Track essential care activities:
  - Watering
  - Fertilizing
  - Pruning
  - Repotting
- Automatic care reminders based on plant needs
- Care history logging
- Customizable care schedules

### 📊 Statistics & Insights
- Overview of your plant collection
- Care activity tracking
- Plant health monitoring
- Care needs summary
- Most common plants in your collection

### 💾 Data Management
- Local storage of plant data
- Image storage in app's documents directory
- Care history persistence
- Easy plant information updates

## Technical Details

### Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- Plant.id API key

### Dependencies
- SwiftUI for UI components
- PhotosUI for image handling
- Plant.id API for plant identification

### Architecture
- MVVM architecture
- SwiftUI views
- Observable objects for state management
- Local data persistence using UserDefaults

## Getting Started

1. Clone the repository
2. Open `PlantBaby.xcodeproj` in Xcode
3. Add your Plant.id API key in `PlantIDService.swift`
4. Build and run the app

## Usage

### Adding a New Plant
1. Tap the "+" tab
2. Choose between:
   - Identify Plant: Take a photo to identify your plant
   - Manual Entry: Add plant details manually
3. Fill in care requirements
4. Save the plant

### Tracking Plant Care
1. View your plants in the Dashboard
2. Tap on a plant to view details
3. Add care events as needed
4. View care history and upcoming needs

### Viewing Statistics
1. Navigate to the Statistics tab
2. View overview of your plant collection
3. Check care activity summaries
4. Monitor plant health indicators

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Plant.id API for plant identification
- SwiftUI for the amazing UI framework
- The plant-loving community for inspiration

## Support

For support, please open an issue in the GitHub repository or contact the development team.

---

Made with ❤️ for plant lovers everywhere
