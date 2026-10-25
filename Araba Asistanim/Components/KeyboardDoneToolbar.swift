import SwiftUI
import UIKit

extension View {
    /// Adds a "Bitti" button above the keyboard. Number and decimal pads have
    /// no return key, so without this the keyboard can cover a form's save
    /// button with no obvious way to close it. Apply once per form.
    func keyboardDoneToolbar() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Bitti") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .fontWeight(.semibold)
            }
        }
    }
}
