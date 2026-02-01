import SwiftUI
import MapKit

struct MapContainerView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var selectedPlaceTag: Place?

    var body: some View {
        ZStack(alignment: .top) {
            // Map
            Map(position: $viewModel.mapCameraPosition, selection: $selectedPlaceTag) {
                // User location
                UserAnnotation()

                // Place markers
                ForEach(viewModel.places) { place in
                    Marker(
                        place.name,
                        systemImage: place.category.icon,
                        coordinate: place.coordinate
                    )
                    .tint(place.category.color)
                    .tag(place)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.updateRegion(context.region)
            }
            .onChange(of: selectedPlaceTag) { _, newValue in
                viewModel.selectPlace(newValue)
            }

            // Search bar overlay
            VStack {
                SearchBarView(
                    text: $viewModel.searchText,
                    isLoading: viewModel.isLoading
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }

            // Permission denied overlay
            if viewModel.locationService.isDenied {
                VStack(spacing: 16) {
                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "location.slash.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text("Location Access Denied")
                            .font(.headline)

                        Text("Enable location access in Settings to see nearby places.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding()

                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            PlaceDetailView(place: place) {
                viewModel.openInMaps(place)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    MapContainerView()
}
