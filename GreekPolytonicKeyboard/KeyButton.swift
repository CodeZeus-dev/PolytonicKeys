import UIKit

class KeyButton: UIButton {
    
    // Button types for styling
    enum KeyType {
        case character
        case special
        case space
        case returnKey // Changed from 'return' which is a reserved keyword
        case backspace
    }
    
    // Key type for this button
    private var keyType: KeyType = .character
    
    // Flag to indicate whether this button should use larger font
    private var useLargeFont: Bool = false
    
    // Standard initialization
    init(title: String, type: KeyType = .character, largeFont: Bool = false) {
        super.init(frame: .zero)
        self.keyType = type
        self.useLargeFont = largeFont
        setupButton(withTitle: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton(withTitle: "")
    }
    
    // Sets up the button appearance
    private func setupButton(withTitle title: String) {
        setTitle(title, for: .normal)
        
        // iOS native keyboard styling
        switch keyType {
        case .character:
            // Standard key styling
            setTitleColor(.black, for: .normal)
            backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0) // Light gray
            
            // Use a larger font size if this button should be more prominent, but same weight
            if useLargeFont {
                titleLabel?.font = UIFont.systemFont(ofSize: 24) // Larger but same weight
            } else {
                titleLabel?.font = UIFont.systemFont(ofSize: 22)
            }
            
            layer.cornerRadius = 5
            
        case .special:
            // Special keys (shift, symbols, etc)
            setTitleColor(.black, for: .normal)
            backgroundColor = UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.0) // Darker gray
            titleLabel?.font = UIFont.systemFont(ofSize: 16)
            layer.cornerRadius = 5
            
        case .space:
            // Space bar styling
            setTitleColor(.black, for: .normal)
            backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0) // Light gray
            titleLabel?.font = UIFont.systemFont(ofSize: 16)
            layer.cornerRadius = 5
            
        case .returnKey:
            // Return key styling
            setTitleColor(.black, for: .normal)
            backgroundColor = UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.0) // Darker gray
            titleLabel?.font = UIFont.systemFont(ofSize: 16)
            layer.cornerRadius = 5
            
        case .backspace:
            // Backspace key styling
            setTitleColor(.black, for: .normal)
            backgroundColor = UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.0) // Darker gray
            titleLabel?.font = UIFont.systemFont(ofSize: 16)
            layer.cornerRadius = 5
        }
        
        titleLabel?.textAlignment = .center
        clipsToBounds = true
        
        // No shadow for native iOS keyboard look
        layer.shadowOpacity = 0
        
        // Make sure the button can be auto-layout
        translatesAutoresizingMaskIntoConstraints = false
        
        // Set a minimum height for the button
        heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
    }
    
    // Button state appearance changes
    override var isHighlighted: Bool {
        didSet {
            // Adjust colors based on key type when highlighted
            if isHighlighted {
                switch keyType {
                case .character:
                    backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
                case .special, .returnKey, .backspace:
                    backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 0.77, alpha: 1.0)
                case .space:
                    backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
                }
            } else {
                // Reset to default colors
                switch keyType {
                case .character, .space:
                    backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
                case .special, .returnKey, .backspace:
                    backgroundColor = UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.0)
                }
            }
        }
    }
    
    // Override intrinsic content size for better sizing
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: max(superSize.width, 25), height: max(superSize.height, 40))
    }
}
