import UIKit

class KeyButton: UIButton {

    // Standard initialization
    init(title: String) {
        super.init(frame: .zero)
        setupButton(withTitle: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton(withTitle: "")
    }
    
    // Sets up the button appearance
    private func setupButton(withTitle title: String) {
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
        backgroundColor = UIColor.white
        
        titleLabel?.font = UIFont.systemFont(ofSize: 18)
        titleLabel?.textAlignment = .center
        
        // Round the corners
        layer.cornerRadius = 5
        clipsToBounds = true
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 1
        
        // Make sure the button can be auto-layout
        translatesAutoresizingMaskIntoConstraints = false
        
        // Set a minimum height for the button
        heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
    }
    
    // Button state appearance changes
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(white: 0.9, alpha: 1.0) : UIColor.white
        }
    }
    
    // Override intrinsic content size for better sizing
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: max(superSize.width, 25), height: max(superSize.height, 40))
    }
}
