import Foundation
import SwiftUI


struct ResizableTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    var placeholderText: String
    @State var editing: Bool = false

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.text = placeholderText
        textView.delegate = context.coordinator
        textView.textColor = .lightGray // Set initial text color to light gray
        textView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if self.text.isEmpty {
            textView.text = self.editing ? "" : self.placeholderText
            textView.textColor = self.editing ? .black : .lightGray
            textView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        }

        DispatchQueue.main.async {
            self.height = textView.contentSize.height
            textView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ResizableTextView

        init(_ params: ResizableTextView) {
            self.parent = params
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                // Turn off autocorrection when editing starts
                textView.autocorrectionType = .yes
                self.parent.editing = true
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                // Enable autocorrection when user starts typing
                if !textView.text.isEmpty {
                    textView.autocorrectionType = .yes
                }
                self.parent.height = textView.contentSize.height
                self.parent.text = textView.text
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                // Reset autocorrection and placeholder text when editing ends
                textView.autocorrectionType = .yes
                self.parent.editing = false
            }
        }
    }
}
