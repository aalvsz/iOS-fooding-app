import SwiftUI
import MapKit

struct PlaceDetailView: View {
    let place: Place
    let onGetDirections: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Category Icon
                Image(systemName: place.category.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(place.category.color, in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(2)

                    Text(place.category.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            // Address
            if let address = place.address {
                Label {
                    Text(address)
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                }
            }

            // Phone
            if let phone = place.phoneNumber {
                Label {
                    Text(phone)
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "phone.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            // Website
            if let url = place.url {
                Label {
                    Link(url.host ?? "Website", destination: url)
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "globe")
                        .foregroundStyle(.blue)
                }
            }

            Spacer()

            // Directions Button
            Button(action: onGetDirections) {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(20)
    }
}

#Preview {
    PlaceDetailView(
        place: Place(from: MKMapItem(placemark: MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        ))),
        onGetDirections: {}
    )
}
