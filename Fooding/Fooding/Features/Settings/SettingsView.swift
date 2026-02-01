import SwiftUI

struct SettingsView: View {
    @AppStorage("showRestaurants") private var showRestaurants = true
    @AppStorage("showBars") private var showBars = true
    @AppStorage("showCafes") private var showCafes = true
    @AppStorage("showBreweries") private var showBreweries = true
    @AppStorage("searchRadius") private var searchRadius = 2000.0

    var body: some View {
        NavigationStack {
            Form {
                Section("Filter by Category") {
                    Toggle(isOn: $showRestaurants) {
                        Label("Restaurants", systemImage: "fork.knife")
                    }
                    .tint(.orange)

                    Toggle(isOn: $showBars) {
                        Label("Bars", systemImage: "wineglass")
                    }
                    .tint(.purple)

                    Toggle(isOn: $showCafes) {
                        Label("Cafes", systemImage: "cup.and.saucer")
                    }
                    .tint(.brown)

                    Toggle(isOn: $showBreweries) {
                        Label("Breweries", systemImage: "mug")
                    }
                    .tint(.yellow)
                }

                Section("Search Radius") {
                    VStack(alignment: .leading) {
                        Text("\(Int(searchRadius))m")
                            .font(.headline)
                            .monospacedDigit()

                        Slider(value: $searchRadius, in: 500...10000, step: 500) {
                            Text("Radius")
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Fooding Team")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        resetToDefaults()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset to Defaults")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func resetToDefaults() {
        showRestaurants = true
        showBars = true
        showCafes = true
        showBreweries = true
        searchRadius = 2000.0
    }
}

#Preview {
    SettingsView()
}
