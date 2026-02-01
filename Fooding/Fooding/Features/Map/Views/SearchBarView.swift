import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var isLoading: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search restaurants, bars, cafes...", text: $text)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

#Preview {
    VStack {
        SearchBarView(text: .constant(""), isLoading: false)
        SearchBarView(text: .constant("Pizza"), isLoading: true)
    }
    .padding()
}
