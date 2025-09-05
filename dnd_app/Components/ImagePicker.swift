import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImageData: Data?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        if let uiImage = image as? UIImage {
                            // Сжимаем изображение для экономии места
                            let maxSize: CGFloat = 300
                            let resizedImage = self.resizeImage(uiImage, targetSize: CGSize(width: maxSize, height: maxSize))
                            self.parent.selectedImageData = resizedImage.jpegData(compressionQuality: 0.7)
                        }
                    }
                }
            }
        }
        
        private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            
            // Выбираем меньшее соотношение для сохранения пропорций
            let ratio = min(widthRatio, heightRatio)
            
            // Вычисляем новый размер
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            
            // Создаем новое изображение
            let rect = CGRect(origin: .zero, size: newSize)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? image
        }
    }
}

// Компонент для отображения аватара
struct AvatarView: View {
    let imageData: Data?
    let size: CGFloat
    
    var body: some View {
        Group {
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                // Дефолтный аватар
                Circle()
                    .fill(Color.orange)
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: size * 0.4))
                            .foregroundColor(.white)
                    )
            }
        }
    }
}
