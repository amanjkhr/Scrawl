import SwiftUI

/// Page navigator sidebar with thumbnails.
struct PageNavigatorView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Pages")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Button {
                    appState.addPage()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
                .help("Add Page (⌘N)")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider().background(Color.white.opacity(0.1))

            // Page List
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(Array(appState.pages.enumerated()), id: \.element.id) { index, page in
                        pageThumb(page: page, index: index)
                    }
                }
                .padding(10)
            }
        }
        .frame(width: 140)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
        )
    }

    @ViewBuilder
    private func pageThumb(page: CanvasPage, index: Int) -> some View {
        Button {
            appState.switchToPage(index)
        } label: {
            VStack(spacing: 4) {
                // Thumbnail preview
                RoundedRectangle(cornerRadius: 6)
                    .fill(page.backgroundColor.color)
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .overlay(
                        // Show element count badge
                        Text("\(page.elements.count)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(4)
                            .background(
                                Capsule().fill(Color.black.opacity(0.3))
                            )
                            .padding(4),
                        alignment: .topTrailing
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(
                                index == appState.currentPageIndex
                                    ? Color.accentColor
                                    : Color.white.opacity(0.1),
                                lineWidth: index == appState.currentPageIndex ? 2 : 1
                            )
                    )

                // Page label
                Text(page.label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(
                        index == appState.currentPageIndex
                            ? .white
                            : .white.opacity(0.5)
                    )
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Rename...") {
                // TODO: Rename page
            }
            if appState.pages.count > 1 {
                Button("Delete", role: .destructive) {
                    appState.deletePage(at: index)
                }
            }
        }
    }
}
