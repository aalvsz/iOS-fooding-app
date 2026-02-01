import Foundation
import MapKit

actor PlaceSearchService {
    private var currentSearchTask: Task<[Place], Error>?

    func searchPlaces(query: String, in region: MKCoordinateRegion) async throws -> [Place] {
        currentSearchTask?.cancel()

        let task = Task<[Place], Error> {
            try Task.checkCancellation()

            if query.isEmpty {
                // For browsing mode, search multiple categories in parallel
                return try await fetchAllCategories(in: region)
            } else {
                // For specific search, just search that query
                return try await searchSingleQuery(query, in: region)
            }
        }

        currentSearchTask = task
        return try await task.value
    }

    private func fetchAllCategories(in region: MKCoordinateRegion) async throws -> [Place] {
        // Search multiple categories in parallel to get more results
        let queries = ["restaurants", "cafe coffee", "bar pub", "pizza", "sushi", "tacos", "bakery", "fast food"]

        try Task.checkCancellation()

        // Run all searches in parallel
        let results = await withTaskGroup(of: [Place].self) { group in
            for query in queries {
                group.addTask {
                    do {
                        return try await self.searchSingleQuery(query, in: region)
                    } catch {
                        return []
                    }
                }
            }

            var allPlaces: [Place] = []
            for await places in group {
                allPlaces.append(contentsOf: places)
            }
            return allPlaces
        }

        // Remove duplicates based on coordinate proximity
        let uniquePlaces = removeDuplicates(from: results)
        return uniquePlaces
    }

    private func searchSingleQuery(_ query: String, in region: MKCoordinateRegion) async throws -> [Place] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        return response.mapItems.map { Place(from: $0) }
    }

    private func removeDuplicates(from places: [Place]) -> [Place] {
        var seen = Set<String>()
        var unique: [Place] = []

        for place in places {
            // Create a key based on name and approximate location
            let latKey = String(format: "%.4f", place.coordinate.latitude)
            let lonKey = String(format: "%.4f", place.coordinate.longitude)
            let key = "\(place.name.lowercased())-\(latKey)-\(lonKey)"

            if !seen.contains(key) {
                seen.insert(key)
                unique.append(place)
            }
        }

        return unique
    }

    func cancelCurrentSearch() {
        currentSearchTask?.cancel()
        currentSearchTask = nil
    }
}
