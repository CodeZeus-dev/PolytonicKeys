import UIKit

// Protocol to handle keyboard interactions
protocol KeyboardViewDelegate: AnyObject {
    func keyTapped(key: String)
    func backspaceTapped()
    func returnTapped()
    func switchKeyboardTapped()
    func spaceTapped()
}

class KeyboardView: UIView {
    
    // UI components
    private var keys: [[KeyButton]] = []
    private var rowViews: [UIStackView] = []
    private var popupView: PopupView?
    private var mainStackView: UIStackView!
    
    // Key layout definitions - basic Greek polytonic keyboard layout
    private let layout: [[String]] = [
        ["ς", "ε", "ρ", "τ", "υ", "θ", "ι", "ο", "π"],
        ["α", "σ", "δ", "φ", "γ", "η", "ξ", "κ", "λ"],
        ["ζ", "χ", "ψ", "ω", "β", "ν", "μ"]
    ]
    
    // Special keys for the bottom row
    private var backspaceButton: KeyButton!
    private var returnButton: KeyButton!
    private var keyboardSwitchButton: KeyButton!
    private var spaceButton: KeyButton!
    
    // Delegate to handle keyboard actions
    weak var delegate: KeyboardViewDelegate?
    
    // Character provider for polytonic combinations
    private let characterProvider = GreekCharacterProvider()
    
    // Currently pressed vowel for showing the popupView
    private var currentPressedVowel: KeyButton?
    
    // Initialize the keyboard view
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // Set up the main keyboard view
    private func setupView() {
        backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .fill
        mainStackView.spacing = 5
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        
        // Create the keyboard rows
        createKeyboardRows()
        
        // Add the bottom row with special keys
        createBottomRow()
    }
    
    // Creates the standard character rows
    private func createKeyboardRows() {
        // Create each row of the keyboard
        for (rowIndex, row) in layout.enumerated() {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.alignment = .fill
            rowStackView.spacing = 5
            
            var rowButtons: [KeyButton] = []
            
            // Create buttons for this row
            for (columnIndex, key) in row.enumerated() {
                let button = KeyButton(title: key)
                
                // Check if this key is a vowel that needs special handling
                if "αεηιουω".contains(key.lowercased()) {
                    // Add long press gesture for vowels
                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                    longPressGesture.minimumPressDuration = 0.3
                    button.addGestureRecognizer(longPressGesture)
                    
                    // Also keep the tap gesture for normal taps
                    button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                } else {
                    // Regular key press for consonants
                    button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                }
                
                rowStackView.addArrangedSubview(button)
                rowButtons.append(button)
            }
            
            // Add extra spacing for indentation on certain rows
            if rowIndex == 1 {
                // Indent the second row a bit
                let leadingSpacer = UIView()
                leadingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                leadingSpacer.widthAnchor.constraint(equalToConstant: 15).isActive = true
                rowStackView.insertArrangedSubview(leadingSpacer, at: 0)
                
                let trailingSpacer = UIView()
                trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                trailingSpacer.widthAnchor.constraint(equalToConstant: 15).isActive = true
                rowStackView.addArrangedSubview(trailingSpacer)
            } else if rowIndex == 2 {
                // Indent the third row more
                let leadingSpacer = UIView()
                leadingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                leadingSpacer.widthAnchor.constraint(equalToConstant: 30).isActive = true
                rowStackView.insertArrangedSubview(leadingSpacer, at: 0)
                
                let trailingSpacer = UIView()
                trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                trailingSpacer.widthAnchor.constraint(equalToConstant: 30).isActive = true
                rowStackView.addArrangedSubview(trailingSpacer)
            }
            
            mainStackView.addArrangedSubview(rowStackView)
            keys.append(rowButtons)
            rowViews.append(rowStackView)
        }
    }
    
    // Creates the bottom row with special function keys
    private func createBottomRow() {
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.distribution = .fill
        bottomRow.alignment = .fill
        bottomRow.spacing = 5
        
        // Keyboard switch key
        keyboardSwitchButton = KeyButton(title: "🌐")
        keyboardSwitchButton.widthAnchor.constraint(equalToConstant, 45).isActive = true
        keyboardSwitchButton.addTarget(self, action: #selector(switchKeyboard), for: .touchUpInside)
        
        // Space key
        spaceButton = KeyButton(title: "Space")
        spaceButton.addTarget(self, action: #selector(spacePressed), for: .touchUpInside)
        
        // Return key
        returnButton = KeyButton(title: "⏎")
        returnButton.widthAnchor.constraint(equalToConstant, 60).isActive = true
        returnButton.addTarget(self, action: #selector(returnPressed), for: .touchUpInside)
        
        // Backspace key
        backspaceButton = KeyButton(title: "⌫")
        backspaceButton.widthAnchor.constraint(equalToConstant, 45).isActive = true
        backspaceButton.addTarget(self, action: #selector(backspacePressed), for: .touchUpInside)
        
        bottomRow.addArrangedSubview(keyboardSwitchButton)
        bottomRow.addArrangedSubview(spaceButton)
        bottomRow.addArrangedSubview(returnButton)
        bottomRow.addArrangedSubview(backspaceButton)
        
        mainStackView.addArrangedSubview(bottomRow)
    }
    
    // Handles long press on vowel keys
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? KeyButton else { return }
        
        switch gesture.state {
        case .began:
            // Show popup view with accent options
            showPopupForVowel(button)
            
        case .ended, .cancelled:
            // Hide the popup when the long press ends
            hidePopup()
            
        default:
            break
        }
    }
    
    // Shows the popup with accent and breathing options for a vowel
    private func showPopupForVowel(_ button: KeyButton) {
        guard let vowel = button.titleLabel?.text?.lowercased() else { return }
        
        // Remember which vowel we're showing options for
        currentPressedVowel = button
        
        // Get all polytonic variations for this vowel
        let options = characterProvider.getOptionsForVowel(vowel)
        
        // Calculate the position for the popup
        let position = button.convert(button.bounds.origin, to: self)
        
        // Create and show the popup
        popupView = PopupView(options: options, vowelOrigin: position, vowelSize: button.bounds.size)
        popupView?.delegate = self
        
        if let popupView = popupView {
            addSubview(popupView)
            
            // Center horizontally above the vowel button
            NSLayoutConstraint.activate([
                popupView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                popupView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -5),
                popupView.widthAnchor.constraint(equalToConstant, 200),
                popupView.heightAnchor.constraint(equalToConstant, 50)
            ])
        }
    }
    
    // Hides the accent option popup
    private func hidePopup() {
        popupView?.removeFromSuperview()
        popupView = nil
        currentPressedVowel = nil
    }
    
    // Standard key press handler
    @objc private func keyPressed(_ sender: KeyButton) {
        if let character = sender.titleLabel?.text {
            delegate?.keyTapped(key: character)
        }
    }
    
    // Backspace key handler
    @objc private func backspacePressed() {
        delegate?.backspaceTapped()
    }
    
    // Return key handler
    @objc private func returnPressed() {
        delegate?.returnTapped()
    }
    
    // Keyboard switch key handler
    @objc private func switchKeyboard() {
        delegate?.switchKeyboardTapped()
    }
    
    // Space key handler
    @objc private func spacePressed() {
        delegate?.spaceTapped()
    }
}

// MARK: - PopupViewDelegate
extension KeyboardView: PopupViewDelegate {
    func optionSelected(_ option: String) {
        // User selected an accented/breathing character option
        delegate?.keyTapped(key: option)
        hidePopup()
    }
}
