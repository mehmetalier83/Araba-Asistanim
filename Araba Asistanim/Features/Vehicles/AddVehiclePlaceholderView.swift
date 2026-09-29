import SwiftUI

/// A temporary placeholder for the future "Add Vehicle" flow.
struct AddVehiclePlaceholderView: View {
    var body: some View {
        PlaceholderSheet(
            systemImage: "car.badge.plus",
            title: "Araç Ekle",
            message: "Yeni araç ekleme özelliği henüz eklenmedi. Veri katmanı tamamlandığında kullanılabilir olacak."
        )
    }
}

#Preview {
    AddVehiclePlaceholderView()
}
