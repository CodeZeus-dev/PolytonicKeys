import UIKit

// Numeric keyboard view for numbers and symbols
class NumericKeyboardView: KeyboardView {
    
    // Number layout - follows iOS design
    private let numericLayout: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
        ["#+=", ".", ",", "?", "!", "'"]
    ]
    
    // Symbol layout for the third page of keys
    private let symbolLayout: [[String]] = [
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
        ["123", ".", ",", "?", "!", "'"]
    ]
    
    // Current layout (numeric or symbols)
    private var currentLayout: [[String]] = []
    private var isInSymbolMode: Bool = false
    
    // "ABC" key to switch back to letters
    private var abcKeyButton: KeyButton!
    
    // Override initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        // We need to call this explicitly because the setup method in the superclass runs before our properties are initialized
        currentLayout = numericLayout
        setupNumericKeyboard()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        currentLayout = numericLayout
        setupNumericKeyboard()
    }
    
    // Set up the number keyboard layout
    private func setupNumericKeyboard() {
        // iOS keyboard background color (light gray)
        backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.87, alpha: 1.0)
        
        // Remove any existing subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .fill
        mainStackView.spacing = 8
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
        
        // Create the keyboard rows
        createNumericRows(in: mainStackView)
        
        // Create the bottom row with special keys
        createNumericBottomRow(in: mainStackView)
    }
    
    // Create the rows of number keys
    private func createNumericRows(in stackView: UIStackView) {
        for (rowIndex, row) in currentLayout.enumerated() {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.alignment = .fill
            rowStackView.spacing = 6
            
            // For the bottom row we have special keys
            if rowIndex == 2 {
                // First key in bottom row is either #+=, 123, or ABC
                let firstKey = row[0] // #+=, 123
                let firstButton = KeyButton(title: firstKey, type: .special)
                firstButton.addTarget(self, action: #selector(symbolModeToggleTapped), for: .touchUpInside)
                rowStackView.addArrangedSubview(firstButton)
                
                // Add remaining keys
                for i in 1..<row.count {
                    let key = row[i]
                    let button = KeyButton(title: key, type: .character)
                    button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                    rowStackView.addArrangedSubview(button)
                }
                
                // Add backspace key at the end
                let backspaceButton = KeyButton(title: "⌫", type: .backspace)
                backspaceButton.addTarget(self, action: #selector(backspaceTapped), for: .touchUpInside)
                rowStackView.addArrangedSubview(backspaceButton)
            } else {
                // Regular rows with numbers and symbols
                for key in row {
                    let button = KeyButton(title: key, type: .character)
                    button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                    rowStackView.addArrangedSubview(button)
                }
            }
            
            stackView.addArrangedSubview(rowStackView)
        }
    }
    
    // Create the bottom row with ABC, space, and return
    private func createNumericBottomRow(in stackView: UIStackView) {
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.distribution = .fill
        bottomRow.alignment = .fill
        bottomRow.spacing = 6
        
        // ABC key (to go back to letters)
        abcKeyButton = KeyButton(title: "ΑΒΓ", type: .special)
        abcKeyButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        abcKeyButton.addTarget(self, action: #selector(abcKeyTapped), for: .touchUpInside)
        
        // Space key
        let spaceButton = KeyButton(title: "διάστημα", type: .space)
        spaceButton.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        
        // Return key
        let returnButton = KeyButton(title: "εἰσαγωγή", type: .returnKey)
        returnButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        returnButton.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)
        
        // Add keys to bottom row
        bottomRow.addArrangedSubview(abcKeyButton)
        bottomRow.addArrangedSubview(spaceButton)
        bottomRow.addArrangedSubview(returnButton)
        
        stackView.addArrangedSubview(bottomRow)
    }
    
    // Symbol mode toggle (#+=, 123)
    @objc private func symbolModeToggleTapped() {
        if isInSymbolMode {
            // Switch to numeric layout
            currentLayout = numericLayout
            isInSymbolMode = false
        } else {
            // Switch to symbol layout
            currentLayout = symbolLayout
            isInSymbolMode = true
        }
        
        // Recreate the keyboard with the new layout
        setupNumericKeyboard()
    }
    
    // ABC key to go back to letters
    @objc private func abcKeyTapped() {
        delegate?.toggleNumberMode()
    }
    
    // Key press handler with override
    @objc internal override func keyPressed(_ sender: KeyButton) {
        if let key = sender.titleLabel?.text {
            delegate?.keyTapped(key: key)
        }
    }
    
    // Backspace with override
    @objc private func backspaceTapped() {
        delegate?.backspaceTapped()
    }
    
    // Return key with override
    @objc private func returnTapped() {
        delegate?.returnTapped()
    }
    
    // Space key with override
    @objc private func spaceTapped() {
        delegate?.spaceTapped()
    }
}
