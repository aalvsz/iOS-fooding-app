import Foundation
import MapKit
import Combine
import SwiftUI

@MainActor
final class MapViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var places: [Place] = []
    @Published var selectedPlace: Place?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var mapCameraPosition: MapCameraPosition

    let locationService = LocationService()
    private let searchService = PlaceSearchService()
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var currentRegion: MKCoordinateRegion

    // Default to San Francisco (common simulator location)
    private static let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    private static let defaultRegion = MKCoordinateRegion(
        center: defaultCoordinate,
        latitudinalMeters: 5000,
        longitudinalMeters: 5000
    )

    init() {
        self.currentRegion = Self.defaultRegion
        self.mapCameraPosition = .region(Self.defaultRegion)
        setupBindings()
    }

    private func setupBindings() {
        // When search text changes, fetch new results from API
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.fetchPlaces()
            }
            .store(in: &cancellables)

        // Center map on user location when available
        locationService.$currentLocation
            .compactMap { $0 }
            .first()
            .sink { [weak self] location in
                self?.centerOnLocation(location)
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        // Immediately fetch places for the default/current region
        fetchPlaces()

        if locationService.needsPermission {
            locationService.requestPermission()
        } else if locationService.isAuthorized {
            locationService.startUpdatingLocation()
        }
    }

    func centerOnLocation(_ location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        mapCameraPosition = .region(region)
        currentRegion = region
        fetchPlaces()
    }

    func centerOnUserLocation() {
        if let location = locationService.currentLocation {
            centerOnLocation(location)
        }
    }

    func updateRegion(_ region: MKCoordinateRegion) {
        // Check for significant center change
        let centerDelta = abs(currentRegion.center.latitude - region.center.latitude) +
                         abs(currentRegion.center.longitude - region.center.longitude)

        // Check for significant zoom change
        let spanDelta = abs(currentRegion.span.latitudeDelta - region.span.latitudeDelta) +
                       abs(currentRegion.span.longitudeDelta - region.span.longitudeDelta)

        let shouldFetch = centerDelta > 0.005 || spanDelta > 0.005

        currentRegion = region

        if shouldFetch {
            fetchPlaces()
        }
    }

    private func fetchPlaces() {
        searchTask?.cancel()

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        searchTask = Task {
            isLoading = true
            errorMessage = nil

            do {
                let results = try await searchService.searchPlaces(
                    query: query,
                    in: currentRegion
                )

                if !Task.isCancelled {
                    self.places = results
                    print("Fetched \(results.count) places for query: '\(query)'")
                }
            } catch {
                if !Task.isCancelled && !(error is CancellationError) {
                    errorMessage = error.localizedDescription
                    print("Error fetching places: \(error)")
                }
            }

            if !Task.isCancelled {
                isLoading = false
            }
        }
    }

    func selectPlace(_ place: Place?) {
        selectedPlace = place
    }

    func openInMaps(_ place: Place) {
        place.mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
        ])
    }
}
