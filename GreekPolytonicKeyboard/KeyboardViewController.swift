import UIKit

class KeyboardViewController: UIInputViewController {
    
    // The main view for our keyboard
    private var keyboardView: KeyboardView!
    
    // Keeps track of the height constraint for the keyboard
    private var heightConstraint: NSLayoutConstraint!
    
    // Suggestion bar for predicted words
    private var suggestionBar: UIView!
    private var suggestionButtons: [UIButton] = []
    
    // Character provider for polytonic options and predictions
    private let characterProvider = GreekCharacterProvider()
    
    // Current word being typed
    private var currentWord: String = ""
    
    // Standard keyboard height
    private let keyboardHeight: CGFloat = 220
    private let suggestionBarHeight: CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the suggestion bar
        setupSuggestionBar()
        
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
                    constant: keyboardHeight + suggestionBarHeight
                )
                inputView.addConstraint(heightConstraint)
            }
            
            heightConstraint.constant = keyboardHeight + suggestionBarHeight
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
        
        // Check for word boundaries (space or newline) to reset current word
        if let documentProxy = textDocumentProxy.documentContextBeforeInput?.last,
           documentProxy == " " || documentProxy == "\n" {
            currentWord = ""
            updateSuggestions([])
        }
    }
    
    // Set up the suggestion bar for text predictions
    private func setupSuggestionBar() {
        // Create suggestion bar container
        suggestionBar = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: suggestionBarHeight))
        suggestionBar.translatesAutoresizingMaskIntoConstraints = false
        suggestionBar.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        view.addSubview(suggestionBar)
        
        // Create three buttons for suggestions
        for i in 0..<3 {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(.darkGray, for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.tag = i
            button.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            
            suggestionBar.addSubview(button)
            suggestionButtons.append(button)
        }
        
        // Set up constraints for suggestion bar
        NSLayoutConstraint.activate([
            suggestionBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            suggestionBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            suggestionBar.topAnchor.constraint(equalTo: view.topAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: suggestionBarHeight)
        ])
        
        // Set up constraints for suggestion buttons
        for (index, button) in suggestionButtons.enumerated() {
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 30),
                button.centerYAnchor.constraint(equalTo: suggestionBar.centerYAnchor)
            ])
            
            if index == 0 {
                button.leadingAnchor.constraint(equalTo: suggestionBar.leadingAnchor, constant: 10).isActive = true
                button.widthAnchor.constraint(equalTo: suggestionBar.widthAnchor, multiplier: 0.3, constant: -15).isActive = true
            } else if index == 1 {
                button.centerXAnchor.constraint(equalTo: suggestionBar.centerXAnchor).isActive = true
                button.widthAnchor.constraint(equalTo: suggestionBar.widthAnchor, multiplier: 0.3, constant: -10).isActive = true
            } else {
                button.trailingAnchor.constraint(equalTo: suggestionBar.trailingAnchor, constant: -10).isActive = true
                button.widthAnchor.constraint(equalTo: suggestionBar.widthAnchor, multiplier: 0.3, constant: -15).isActive = true
            }
        }
        
        // Initially hide suggestions
        updateSuggestions([])
    }
    
    // Handle suggestion button tap
    @objc private func suggestionTapped(_ sender: UIButton) {
        if sender.tag < suggestionButtons.count {
            if let suggestion = suggestionButtons[sender.tag].title(for: .normal), !suggestion.isEmpty {
                // First delete the current partial word
                for _ in 0..<currentWord.count {
                    textDocumentProxy.deleteBackward()
                }
                
                // Then insert the suggested word
                textDocumentProxy.insertText(suggestion)
                
                // Add space after suggestion
                textDocumentProxy.insertText(" ")
                
                // Reset current word
                currentWord = ""
                
                // Learn from this selection
                characterProvider.learnFromText(suggestion)
                
                // Update suggestions
                updateSuggestions([])
            }
        }
    }
    
    // Update the suggestion buttons with new predictions
    private func updateSuggestions(_ suggestions: [String]) {
        // Update each button with a suggestion if available
        for (index, button) in suggestionButtons.enumerated() {
            if index < suggestions.count && !suggestions[index].isEmpty {
                button.setTitle(suggestions[index], for: .normal)
                button.isHidden = false
            } else {
                button.setTitle("", for: .normal)
                button.isHidden = true
            }
        }
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
            keyboardView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - KeyboardViewDelegate
extension KeyboardViewController: KeyboardViewDelegate {
    func keyTapped(key: String) {
        // Insert the character when a key is tapped
        textDocumentProxy.insertText(key)
        
        // Update current word being typed
        currentWord += key
        
        // Check if this is a vowel and record the selection for learning
        let baseVowels = ["α", "ε", "η", "ι", "ο", "υ", "ω"]
        for vowel in baseVowels {
            if key.contains(vowel) {
                characterProvider.recordSelection(of: key, for: vowel)
                break
            }
        }
        
        // Get suggestions for the current word
        let suggestions = characterProvider.getSuggestedWords(for: currentWord)
        updateSuggestions(suggestions)
    }
    
    func backspaceTapped() {
        // Delete the character before the cursor
        textDocumentProxy.deleteBackward()
        
        // Update current word
        if !currentWord.isEmpty {
            currentWord.removeLast()
            
            // Get suggestions for the updated word
            let suggestions = characterProvider.getSuggestedWords(for: currentWord)
            updateSuggestions(suggestions)
        }
    }
    
    func returnTapped() {
        // Insert a new line
        textDocumentProxy.insertText("\n")
        
        // Learn from the completed word
        characterProvider.learnFromText(currentWord)
        
        // Reset current word and suggestions
        currentWord = ""
        updateSuggestions([])
    }
    
    func switchKeyboardTapped() {
        // Switch to the next keyboard
        advanceToNextInputMode()
    }
    
    func spaceTapped() {
        // Insert a space
        textDocumentProxy.insertText(" ")
        
        // Learn from the completed word
        characterProvider.learnFromText(currentWord)
        
        // Reset current word and suggestions
        currentWord = ""
        updateSuggestions([])
    }
}
