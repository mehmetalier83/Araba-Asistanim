import PhotosUI
import SwiftUI

/// An optional receipt/invoice photo attachment. Shows a dashed drop-zone
/// card when empty and a cropped preview with a remove button once a photo
/// is picked — from the camera or the photo library. Every photo is run
/// through on-device OCR (`ReceiptScanner`) right after capture; the result
/// is handed back via `onScan` so the caller can pre-fill its form fields.
/// Those fields stay ordinary, fully-editable text fields — the scan is a
/// head start, not an answer the camera can be wrong about.
struct ReceiptAttachmentView: View {
    @Binding var imageData: Data?
    var onScan: ((ReceiptScanner.ScanResult) -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var pickerItem: PhotosPickerItem?
    @State private var isShowingSourceDialog = false
    @State private var isShowingPhotoLibrary = false
    @State private var isShowingCamera = false
    @State private var isScanning = false

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Fiş / Fatura")
                .font(AppTypography.footnote)
                .foregroundStyle(AppTheme.textSecondary)

            if let imageData, let uiImage = UIImage(data: imageData) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
                        .onTapGesture { isShowingSourceDialog = true }

                    if isScanning {
                        RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                            .fill(.black.opacity(0.45))
                        VStack(spacing: AppSpacing.xs) {
                            ProgressView()
                                .tint(.white)
                            Text("Fiş taranıyor…")
                                .font(AppTypography.caption)
                                .foregroundStyle(.white)
                        }
                    }

                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(reduceMotion ? nil : AppAnimation.fast) {
                                    self.imageData = nil
                                    pickerItem = nil
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: AppSizes.iconMedium))
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .black.opacity(0.45))
                            }
                            .padding(AppSpacing.xs)
                            .accessibilityLabel("Fişi kaldır")
                        }
                        Spacer()
                    }
                }
                .frame(height: 150)
            } else {
                Button {
                    isShowingSourceDialog = true
                } label: {
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: AppSizes.iconLarge))
                            .foregroundStyle(AppTheme.textTertiary)

                        Text("Fiş veya Fatura Ekle")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)

                        Text("İsteğe bağlı — tutar ve tür otomatik algılanır")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                            .strokeBorder(AppTheme.border, style: StrokeStyle(lineWidth: 1.5, dash: [7, 5]))
                    )
                }
                .buttonStyle(.appPressScale)
            }
        }
        .confirmationDialog("Fiş Ekle", isPresented: $isShowingSourceDialog, titleVisibility: .visible) {
            if isCameraAvailable {
                Button("Kameradan Çek") { isShowingCamera = true }
            }
            Button("Galeriden Seç") { isShowingPhotoLibrary = true }
            Button("Vazgeç", role: .cancel) {}
        }
        .photosPicker(isPresented: $isShowingPhotoLibrary, selection: $pickerItem, matching: .images)
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker { image in
                isShowingCamera = false
                applyImage(image)
            } onCancel: {
                isShowingCamera = false
            }
            .ignoresSafeArea()
        }
        .onChange(of: pickerItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else { return }
                applyImage(uiImage)
            }
        }
    }

    private func applyImage(_ image: UIImage) {
        let data = image.jpegData(compressionQuality: 0.85)
        withAnimation(reduceMotion ? nil : AppAnimation.standard) {
            imageData = data
            isScanning = true
        }

        Task {
            let result = await ReceiptScanner.scan(image)
            withAnimation(reduceMotion ? nil : AppAnimation.fast) {
                isScanning = false
            }
            if let result {
                onScan?(result)
            }
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        ReceiptAttachmentView(imageData: .constant(nil))
    }
    .padding()
}
