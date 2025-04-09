import UIKit

class KeyboardViewController: UIInputViewController {
    
    // The main view for our keyboard
    private var keyboardView: KeyboardView!
    
    // Keeps track of the height constraint for the keyboard
    private var heightConstraint: NSLayoutConstraint!
    
    // Standard keyboard height
    private let keyboardHeight: CGFloat = 220
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the keyboard view
        setupKeyboardView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Update the keyboard height based on the current orientation
        if let inputView = inputView {
            if heightConstraint == nil {
                heightConstraint = NSLayoutConstraint(
                    item: inputView,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 0.0,
                    constant: keyboardHeight
                )
                inputView.addConstraint(heightConstraint)
            }
            
            heightConstraint.constant = keyboardHeight
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If the keyboard was inactive, we need to refresh it
        if keyboardView.alpha == 0 {
            keyboardView.alpha = 1
        }
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // Called when the text input changes (but before the change is applied)
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // Called after text has been changed in the document
    }
    
    // Sets up the keyboard view
    private func setupKeyboardView() {
        // Create keyboard view with the full width of the input view
        keyboardView = KeyboardView(frame: view.frame)
        keyboardView.delegate = self
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the keyboard view to the hierarchy
        view.addSubview(keyboardView)
        
        // Set up constraints for the keyboard view
        NSLayoutConstraint.activate([
            keyboardView.leftAnchor.constraint(equalTo: view.leftAnchor),
            keyboardView.rightAnchor.constraint(equalTo: view.rightAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - KeyboardViewDelegate
extension KeyboardViewController: KeyboardViewDelegate {
    func keyTapped(key: String) {
        // Insert the character when a key is tapped
        textDocumentProxy.insertText(key)
    }
    
    func backspaceTapped() {
        // Delete the character before the cursor
        textDocumentProxy.deleteBackward()
    }
    
    func returnTapped() {
        // Insert a new line
        textDocumentProxy.insertText("\n")
    }
    
    func switchKeyboardTapped() {
        // Switch to the next keyboard
        advanceToNextInputMode()
    }
    
    func spaceTapped() {
        // Insert a space
        textDocumentProxy.insertText(" ")
    }
}
