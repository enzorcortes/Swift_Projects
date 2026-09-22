import PhotosUI
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct AvatarView: View {
    let imageData: Data?
    let initials: String
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(color.gradient)
            if let imageData {
                PlatformAvatarImage(data: imageData)
            } else {
                Text(initials)
                    .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}

private struct PlatformAvatarImage: View {
    let data: Data

    var body: some View {
        #if canImport(UIKit)
        if let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        }
        #elseif canImport(AppKit)
        if let image = NSImage(data: data) {
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
        }
        #endif
    }
}

struct EditableAvatarView: View {
    let store: ConstellationStore
    let person: Person
    let size: CGFloat
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoading = false

    var body: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            AvatarView(
                imageData: person.avatarData,
                initials: person.initials,
                color: person.color,
                size: size
            )
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "camera.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(7)
                    .background(.black.opacity(0.72), in: Circle())
                    .accessibilityHidden(true)
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .padding(8)
                        .background(.regularMaterial, in: Circle())
                }
            }
        }
        .accessibilityLabel(person.avatarData == nil ? "Add profile picture" : "Change profile picture")
        .onChange(of: selectedPhoto) {
            guard let selectedPhoto else { return }
            isLoading = true
            Task {
                defer { isLoading = false }
                if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                    store.setAvatarData(data, for: person.id)
                }
            }
        }
    }
}
