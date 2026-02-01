import Foundation
import MapKit
import SwiftUI

enum PlaceCategory: String, CaseIterable {
    case restaurant
    case bar
    case cafe
    case brewery

    var displayName: String {
        switch self {
        case .restaurant: return "Restaurant"
        case .bar: return "Bar"
        case .cafe: return "Cafe"
        case .brewery: return "Brewery"
        }
    }

    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .bar: return "wineglass"
        case .cafe: return "cup.and.saucer"
        case .brewery: return "mug"
        }
    }

    var color: Color {
        switch self {
        case .restaurant: return .orange
        case .bar: return .purple
        case .cafe: return .brown
        case .brewery: return .yellow
        }
    }
}

struct Place: Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: PlaceCategory
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let phoneNumber: String?
    let url: URL?
    let mapItem: MKMapItem

    init(from mapItem: MKMapItem) {
        self.id = UUID()
        self.name = mapItem.name ?? "Unknown Place"
        self.coordinate = mapItem.placemark.coordinate
        self.address = mapItem.placemark.formattedAddress
        self.phoneNumber = mapItem.phoneNumber
        self.url = mapItem.url
        self.mapItem = mapItem
        self.category = Place.determineCategory(from: mapItem)
    }

    private static func determineCategory(from mapItem: MKMapItem) -> PlaceCategory {
        if let category = mapItem.pointOfInterestCategory {
            switch category {
            case .cafe:
                return .cafe
            case .brewery:
                return .brewery
            case .nightlife, .winery:
                return .bar
            default:
                return .restaurant
            }
        }
        return .restaurant
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }
}

extension CLPlacemark {
    var formattedAddress: String? {
        var components: [String] = []

        if let subThoroughfare = subThoroughfare {
            components.append(subThoroughfare)
        }
        if let thoroughfare = thoroughfare {
            components.append(thoroughfare)
        }
        if let locality = locality {
            if !components.isEmpty {
                components.append(", \(locality)")
            } else {
                components.append(locality)
            }
        }
        if let administrativeArea = administrativeArea {
            components.append(administrativeArea)
        }

        return components.isEmpty ? nil : components.joined(separator: " ")
    }
}
