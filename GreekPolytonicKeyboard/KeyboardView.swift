import UIKit

// Protocol to handle keyboard interactions
protocol KeyboardViewDelegate: AnyObject {
    func keyTapped(key: String)
    func backspaceTapped()
    func returnTapped()
    func switchKeyboardTapped()
    func spaceTapped()
    func toggleNumberMode()
}

class KeyboardView: UIView {
    
    // UI components
    private var keys: [[KeyButton]] = []
    private var rowViews: [UIStackView] = []
    private var popupView: PopupView?
    private var mainStackView: UIStackView!
    
    // Key layout definitions - modified for polytonic input
    private let layout: [[String]] = [
        ["^", "ε", "ρ", "τ", "υ", "θ", "ι", "ο", "π"],    // Replaced ς with circumflex accent (^)
        ["´", "α", "σ", "δ", "φ", "γ", "η", "ξ", "κ", "λ", "῾"],  // Added accent button (´) before α and breathing mark (῾) after λ
        ["ζ", "χ", "ψ", "ω", "β", "ν", "μ"]
    ]
    
    // Special keys for the bottom row
    private var backspaceButton: KeyButton!
    private var returnButton: KeyButton!
    private var spaceButton: KeyButton!
    private var numberKeyButton: KeyButton! // For 123 key
    
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
    internal func setupView() {
        // iOS keyboard background color (light gray)
        backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.87, alpha: 1.0)
        
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fill // Changed from fillEqually to allow for custom sizing
        mainStackView.alignment = .fill
        mainStackView.spacing = 8 // iOS keyboard spacing
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
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
            // All rows get fill distribution to ensure consistent sizing
            rowStackView.distribution = .fillEqually
            rowStackView.alignment = .fill
            // Use tighter spacing for middle row to make keys wider
            rowStackView.spacing = (rowIndex == 1) ? 3 : 6 // Tighter spacing for middle row
            
            var rowButtons: [KeyButton] = []
            
            // Create buttons for this row
            for (_, key) in row.enumerated() {
                // Determine if this is a middle row button that should be larger
                let isMiddleRow = (rowIndex == 1)
                
                // Use character type for letter keys, with larger font for middle row
                let button = KeyButton(title: key, type: .character, largeFont: isMiddleRow)
                
                // Check if this key is a vowel that needs special handling or special accent/breathing buttons
                if "αεηιουωρ".contains(key.lowercased()) {
                    print("Setting up vowel button for: \(key)")
                    
                    // Add long press gesture for vowels
                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                    longPressGesture.minimumPressDuration = 0.2  // Make it more responsive
                    longPressGesture.allowableMovement = 20.0    // Allow some movement
                    button.addGestureRecognizer(longPressGesture)
                    
                    // Also keep the tap gesture for normal taps
                    button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                    
                    // Set custom tag for debugging
                    button.tag = 100 + rowButtons.count
                } else if key == "´" {
                    // Accent marks button (acute and grave)
                    print("Setting up accent marks button")
                    button.tag = 200
                    
                    // Set up long press for accent marks popup
                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                    longPressGesture.minimumPressDuration = 0.2
                    longPressGesture.allowableMovement = 20.0
                    button.addGestureRecognizer(longPressGesture)
                    
                    // Default tap behavior - insert acute accent on tap
                    button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                } else if key == "῾" {
                    // Breathing marks button
                    print("Setting up breathing marks button")
                    button.tag = 201
                    
                    // Set up long press for breathing marks popup
                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                    longPressGesture.minimumPressDuration = 0.2
                    longPressGesture.allowableMovement = 20.0
                    button.addGestureRecognizer(longPressGesture)
                    
                    // Default tap behavior - insert rough breathing on tap
                    button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                } else if key == "^" {
                    // Circumflex accent button - direct insertion on tap
                    print("Setting up circumflex accent button")
                    button.tag = 202
                    button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                } else {
                    // Regular key press for consonants
                    button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                }
                
                rowStackView.addArrangedSubview(button)
                rowButtons.append(button)
            }
            
            // Add extra spacing for indentation on certain rows (iOS keyboard style)
            if rowIndex == 1 {
                // For the middle row, use minimal indentation to maximize key width
                let leadingSpacer = UIView()
                leadingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                leadingSpacer.widthAnchor.constraint(equalToConstant: 5).isActive = true
                rowStackView.insertArrangedSubview(leadingSpacer, at: 0)
                
                let trailingSpacer = UIView()
                trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                trailingSpacer.widthAnchor.constraint(equalToConstant: 5).isActive = true
                rowStackView.addArrangedSubview(trailingSpacer)
            } else if rowIndex == 2 {
                // Add shift key at start of third row (matches iOS keyboard)
                let shiftKey = KeyButton(title: "⇧", type: .special)
                shiftKey.widthAnchor.constraint(equalToConstant: 50).isActive = true
                shiftKey.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                rowStackView.insertArrangedSubview(shiftKey, at: 0)
                
                // Add backspace key at end of third row
                backspaceButton = KeyButton(title: "⌫", type: .backspace)
                backspaceButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
                backspaceButton.addTarget(self, action: #selector(backspacePressed), for: .touchUpInside)
                rowStackView.addArrangedSubview(backspaceButton)
            }
            
            // Add the row to the main stack
            mainStackView.addArrangedSubview(rowStackView)
            
            // Make the middle row (index 1) taller for better usability
            if rowIndex == 1 {
                // Set a taller height constraint for the middle row
                rowStackView.heightAnchor.constraint(equalToConstant: 58).isActive = true
                
                // Set a higher content hugging priority to ensure it keeps its size
                rowStackView.setContentHuggingPriority(.required, for: .vertical)
                rowStackView.setContentCompressionResistancePriority(.required, for: .vertical)
            } else {
                // Set a default height for other rows
                rowStackView.heightAnchor.constraint(equalToConstant: 48).isActive = true
            }
            
            keys.append(rowButtons)
            rowViews.append(rowStackView)
        }
    }
    
    // Creates the bottom row with special function keys (iOS style)
    private func createBottomRow() {
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.distribution = .fill
        bottomRow.alignment = .fill
        bottomRow.spacing = 6 // iOS keyboard spacing
        
        // 123 key (numbers and symbols)
        numberKeyButton = KeyButton(title: "123", type: .special)
        numberKeyButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        numberKeyButton.addTarget(self, action: #selector(numberModePressed), for: .touchUpInside)
        
        // Space key
        spaceButton = KeyButton(title: "space", type: .space) // English "space" to match English keyboard
        spaceButton.addTarget(self, action: #selector(spacePressed), for: .touchUpInside)
        
        // Return key
        returnButton = KeyButton(title: "return", type: .returnKey)
        returnButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        returnButton.addTarget(self, action: #selector(returnPressed), for: .touchUpInside)
        
        // Define backspace button as a class property but don't add it to the bottom row
        // since it's now in the third row of letter keys
        backspaceButton = KeyButton(title: "⌫", type: .backspace)
        
        // Globe key (language switcher) - visible on actual iOS keyboard
        let globeButton = KeyButton(title: "🌐", type: .special)
        globeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        globeButton.addTarget(self, action: #selector(switchKeyboard), for: .touchUpInside)
        
        // Add keys to bottom row (matching the English iOS keyboard layout from screenshot)
        bottomRow.addArrangedSubview(numberKeyButton)
        bottomRow.addArrangedSubview(spaceButton)
        bottomRow.addArrangedSubview(returnButton)
        
        // Note: In actual iOS deployment, the system automatically adds the globe icon
        // for keyboard switching, so we don't need to manually add it
        
        mainStackView.addArrangedSubview(bottomRow)
        
        // Set a consistent height for the bottom row
        bottomRow.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    // Handles long press on vowel keys
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? KeyButton else {
            print("Long press on non-button view")
            return
        }
        
        if let text = button.titleLabel?.text {
            print("Long press on button: \(text), state: \(gesture.state.rawValue)")
        }
        
        // Get the touch point in the keyboard view's coordinate system
        let touchPoint = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            // Show popup with accent options
            print("Long press BEGAN - showing popup")
            showPopupForVowel(button)
            
        case .changed:
            // User is dragging - check if we're hovering over the popup options
            if let popupView = popupView {
                // Convert touch point to the popup's coordinate system
                let popupTouchPoint = convert(touchPoint, to: popupView)
                print("Drag position in popup: \(popupTouchPoint)")
                
                // Get the item at touch location
                if let collectionView = popupView.getCollectionView() {
                    if let indexPath = collectionView.indexPathForItem(at: popupTouchPoint) {
                        // We're hovering over an option
                        print("Hovering over option at index: \(indexPath.item)")
                        
                        // Highlight the cell
                        if let cell = collectionView.cellForItem(at: indexPath) {
                            // Force highlight state
                            cell.isHighlighted = true
                            
                            // Highlight only this cell, unhighlight others
                            for otherIndexPath in collectionView.indexPathsForVisibleItems {
                                if otherIndexPath != indexPath {
                                    collectionView.cellForItem(at: otherIndexPath)?.isHighlighted = false
                                }
                            }
                        }
                    } else {
                        // Not hovering over any option - unhighlight all
                        for indexPath in collectionView.indexPathsForVisibleItems {
                            collectionView.cellForItem(at: indexPath)?.isHighlighted = false
                        }
                    }
                }
            }
            
        case .ended:
            print("Long press ENDED - checking for selection")
            // Check if we ended on a specific option
            if let popupView = popupView {
                // Convert touch point to the popup's coordinate system
                let popupTouchPoint = convert(touchPoint, to: popupView)
                
                // Get the item at touch location
                if let collectionView = popupView.getCollectionView(),
                   let indexPath = collectionView.indexPathForItem(at: popupTouchPoint),
                   let cell = collectionView.cellForItem(at: indexPath) {
                    
                    // We released the finger on an option - select it
                    print("Released on option at index: \(indexPath.item)")
                    
                    // Highlight it briefly for visual feedback
                    cell.isHighlighted = true
                    
                    // Get the option and notify the delegate
                    let option = popupView.getOptionAt(index: indexPath.item)
                    print("Selected option from drag: \(option)")
                    
                    // Trigger the selection
                    delegate?.keyTapped(key: option)
                }
            }
            // Hide the popup in all cases
            hidePopup()
            
        case .cancelled, .failed:
            print("Long press CANCELLED/FAILED - hiding popup without selection")
            hidePopup()
            
        case .possible:
            print("Long press POSSIBLE")
            
        @unknown default:
            print("Long press UNKNOWN STATE")
            hidePopup()
        }
    }
    
    // Shows the popup with accent and breathing options for a vowel or accent button
    private func showPopupForVowel(_ button: KeyButton) {
        guard let text = button.titleLabel?.text else {
            print("ERROR: Could not get text from button")
            return
        }
        
        // Remember which button we're showing options for
        currentPressedVowel = button
        
        // Different popup content based on button type
        var options: [String] = []
        
        if button.tag == 200 {
            // Accent marks button (acute and grave)
            print("Showing accent marks popup")
            // Use explicit Unicode code points for better visibility
            options = ["\u{0301}", "\u{0300}"]  // Combining acute and grave accents
            
            // Debug the accent marks
            print("Accent marks: \(options.map { $0.unicodeScalars.map { "U+\(String(format: "%04X", $0.value))" }.joined() })")
        } else if button.tag == 201 {
            // Breathing marks button
            print("Showing breathing marks popup")
            // Use common combinations on alpha for better visibility
            options = ["ἁ", "ἀ", "ἃ", "ἄ", "ἅ", "ἂ"]  // Alpha with different breathing mark combinations
        } else if text.lowercased() == "ρ" {
            // Rho with rough breathing
            print("Showing popup for rho with breathing options")
            options = ["ῥ", "Ῥ"]  // Rho with rough breathing (lowercase and uppercase)
        } else {
            // Regular vowel
            print("Showing popup for vowel: \(text)")
            options = characterProvider.getOptionsForVowel(text.lowercased())
        }
        
        print("Popup options: \(options)")
        
        // Calculate the position for the popup
        let position = button.convert(button.bounds.origin, to: self)
        print("Button position: \(position)")
        
        // Create and show the popup
        popupView = PopupView(options: options, vowelOrigin: position, vowelSize: button.bounds.size)
        popupView?.delegate = self
        
        if let popupView = popupView {
            addSubview(popupView)
            print("Added popup to view hierarchy")
            
            // Center horizontally above the vowel button with improved positioning
            NSLayoutConstraint.activate([
                popupView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                popupView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -5),
                popupView.widthAnchor.constraint(equalToConstant: 280),
                popupView.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            // Bring to front to ensure it's visible and interactive
            bringSubviewToFront(popupView)
            
            // Set a high z-index to make sure the popup is on top of other views
            popupView.layer.zPosition = 999
            
            // Disable user interaction on other views to avoid tap conflicts
            for subview in subviews {
                if subview != popupView {
                    subview.isUserInteractionEnabled = false
                }
            }
        } else {
            print("ERROR: Failed to create popup view")
        }
    }
    
    // Hides the accent option popup
    private func hidePopup() {
        print("Hiding popup")
        popupView?.removeFromSuperview()
        popupView = nil
        currentPressedVowel = nil
        
        // Re-enable user interaction on all subviews
        for subview in subviews {
            subview.isUserInteractionEnabled = true
        }
    }
    
    // Standard key press handler
    @objc internal func keyPressed(_ sender: KeyButton) {
        guard let character = sender.titleLabel?.text else { return }
        
        // Special handling for accent buttons
        if character == "^" {
            print("Circumflex accent button pressed")
            // The circumflex combines with the previous vowel, so we'll send it directly
            delegate?.keyTapped(key: "\u{0302}") // Unicode combining circumflex
        } else if character == "´" {
            print("Acute accent button pressed")
            // Send acute accent directly
            delegate?.keyTapped(key: "\u{0301}") // Unicode combining acute accent
        } else if character == "῾" {
            print("Rough breathing mark button pressed")
            // Send rough breathing directly
            delegate?.keyTapped(key: "\u{0314}") // Unicode combining rough breathing
        } else {
            // Regular key press
            delegate?.keyTapped(key: character)
        }
    }
    
    // Backspace key handler
    @objc internal func backspacePressed() {
        delegate?.backspaceTapped()
    }
    
    // Return key handler
    @objc internal func returnPressed() {
        delegate?.returnTapped()
    }
    
    // Keyboard switch key handler
    @objc internal func switchKeyboard() {
        delegate?.switchKeyboardTapped()
    }
    
    // Space key handler
    @objc internal func spacePressed() {
        delegate?.spaceTapped()
    }
    
    // Number key handler (for 123 button)
    @objc internal func numberModePressed() {
        delegate?.toggleNumberMode()
    }
}

// MARK: - PopupViewDelegate
extension KeyboardView: PopupViewDelegate {
    func optionSelected(_ option: String) {
        // User selected an accented/breathing character option
        print("PopupViewDelegate - option selected: \(option)")
        
        // Hide before inserting text to avoid UI glitches
        hidePopup()
        
        // For the special accent/breathing buttons, we need to handle differently
        if currentPressedVowel?.tag == 200 {
            // Acute or Grave accent button - send the combining accent
            if option == "ά" {
                delegate?.keyTapped(key: "\u{0301}") // Combining acute accent
                print("Inserted combining acute accent")
            } else if option == "ὰ" {
                delegate?.keyTapped(key: "\u{0300}") // Combining grave accent
                print("Inserted combining grave accent")
            } else {
                delegate?.keyTapped(key: option)
            }
        } else if currentPressedVowel?.tag == 201 {
            // Breathing marks button - extract the breathing mark from the example character
            // The options are displayed as alpha with different breathing marks
            switch option {
            case "ἁ": // Alpha with rough breathing
                delegate?.keyTapped(key: "\u{0314}") // Combining rough breathing
                print("Inserted combining rough breathing")
            case "ἀ": // Alpha with smooth breathing
                delegate?.keyTapped(key: "\u{0313}") // Combining smooth breathing
                print("Inserted combining smooth breathing")
            case "ἃ": // Alpha with rough breathing and grave
                delegate?.keyTapped(key: "\u{0314}\u{0300}") // Combined marks
                print("Inserted rough breathing + grave")
            case "ἄ": // Alpha with smooth breathing and acute
                delegate?.keyTapped(key: "\u{0313}\u{0301}") // Combined marks
                print("Inserted smooth breathing + acute")
            case "ἅ": // Alpha with rough breathing and acute
                delegate?.keyTapped(key: "\u{0314}\u{0301}") // Combined marks
                print("Inserted rough breathing + acute")
            case "ἂ": // Alpha with smooth breathing and grave
                delegate?.keyTapped(key: "\u{0313}\u{0300}") // Combined marks
                print("Inserted smooth breathing + grave")
            default:
                delegate?.keyTapped(key: option)
            }
        } else {
            // Regular selection, send directly
            delegate?.keyTapped(key: option)
            print("Character inserted: \(option)")
        }
    }
}
