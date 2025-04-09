import UIKit

// Protocol to handle option selection from the popup
protocol PopupViewDelegate: AnyObject {
    func optionSelected(_ option: String)
}

class PopupView: UIView {
    
    // UI components
    private var stackView: UIStackView!
    
    // Options to display
    private var options: [String] = []
    
    // Delegate to handle selection
    weak var delegate: PopupViewDelegate?
    
    // Initialize with character options and position
    init(options: [String], vowelOrigin: CGPoint, vowelSize: CGSize) {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        self.options = options
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // Set up the popup view
    private func setupView() {
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        translatesAutoresizingMaskIntoConstraints = false
        
        // Round the corners and add shadow
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
        
        // Create a horizontal stack view to hold options
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        
        // Add option buttons
        createOptionButtons()
    }
    
    // Creates buttons for each character option
    private func createOptionButtons() {
        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
        }
    }
    
    // Handle option selection
    @objc private func optionTapped(_ sender: UIButton) {
        if let selectedOption = sender.titleLabel?.text {
            delegate?.optionSelected(selectedOption)
        }
    }
}
