import SwiftUI

struct AlertView: UIViewControllerRepresentable {
    var title: String
    var message: String
    var actionHandler: (String) -> Void

    class Coordinator: NSObject {
        var actionHandler: (String) -> Void

        init(actionHandler: @escaping (String) -> Void) {
            self.actionHandler = actionHandler
        }

        @objc func handleAction(_ action: UIAlertAction) {
            self.actionHandler(action.title ?? "")
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(actionHandler: self.actionHandler)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add a text field for entering the number of servings
        alertController.addTextField { textField in
            textField.placeholder = "Enter number of servings"
            textField.keyboardType = .numberPad
        }
        
        // Add actions to the alert
        let submitAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let servingsText = alertController.textFields?.first?.text,
               !servingsText.isEmpty {
                self.actionHandler(servingsText)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        // Present the alert
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // We don't need to update anything since the alert is presented once.
    }
}
