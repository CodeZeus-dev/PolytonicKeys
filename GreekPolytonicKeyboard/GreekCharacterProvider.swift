import Foundation

class GreekCharacterProvider {
    
    // Dictionary mapping each vowel to its polytonic variations
    private let vowelOptions: [String: [String]] = [
        // Alpha: Most common combinations based on frequency in ancient Greek texts
        // Common patterns: smooth/rough breathing + acute, circumflex, iota subscript
        "α": ["ᾳ", // iota subscript (without accent)
              "ἀ", // smooth breathing
              "ἁ", // rough breathing
              "ά", // acute accent
              "ᾶ"  // circumflex
             ],
        
        // Epsilon: Doesn't take iota subscript, so we include the most common combinations
        "ε": ["ἐ", // smooth breathing
              "ἑ", // rough breathing
              "έ", // acute accent
              "ὲ"  // grave accent
             ],
        
        // Eta: Common combinations in ancient Greek
        "η": ["ῃ", // iota subscript (without accent)
              "ἠ", // smooth breathing
              "ἡ", // rough breathing
              "ή", // acute accent
              "ῆ"  // circumflex
             ],
        
        // Iota: No iota subscript for itself, so we include major accent forms
        "ι": ["ἰ", // smooth breathing
              "ἱ", // rough breathing
              "ί", // acute accent
              "ῖ"  // circumflex
             ],
        
        // Omicron: Doesn't take iota subscript, so we include most common combinations
        "ο": ["ὀ", // smooth breathing
              "ὁ", // rough breathing
              "ό", // acute accent
              "ὸ"  // grave accent
             ],
        
        // Upsilon: No iota subscript, include most common combinations
        "υ": ["ὐ", // smooth breathing
              "ὑ", // rough breathing
              "ύ", // acute accent
              "ῦ"  // circumflex
             ],
        
        // Omega: Common combinations in ancient Greek
        "ω": ["ῳ", // iota subscript (without accent)
              "ὠ", // smooth breathing
              "ὡ", // rough breathing
              "ώ", // acute accent
              "ῶ"  // circumflex
             ],
        
        // Rho with rough breathing (this occurs at the beginning of words in Ancient Greek)
        "ρ": ["ῥ", "Ῥ"]
    ]
    
    // Full dictionary of all variations (kept for reference and advanced mode)
    private let allVowelOptions: [String: [String]] = [
        // Alpha - all variations
        "α": ["ά", "ὰ", "ᾶ", "ἀ", "ἁ", "ἂ", "ἃ", "ἄ", "ἅ", "ἆ", "ἇ", "ᾀ", "ᾁ", "ᾂ", "ᾃ", "ᾄ", "ᾅ", "ᾆ", "ᾇ", "ᾰ", "ᾱ", "ᾲ", "ᾳ", "ᾴ", "ᾷ"],
        
        // Epsilon
        "ε": ["έ", "ὲ", "ἐ", "ἑ", "ἒ", "ἓ", "ἔ", "ἕ"],
        
        // Eta
        "η": ["ή", "ὴ", "ῆ", "ἠ", "ἡ", "ἢ", "ἣ", "ἤ", "ἥ", "ἦ", "ἧ", "ᾐ", "ᾑ", "ᾒ", "ᾓ", "ᾔ", "ᾕ", "ᾖ", "ᾗ", "ῂ", "ῃ", "ῄ", "ῇ"],
        
        // Iota
        "ι": ["ί", "ὶ", "ῖ", "ἰ", "ἱ", "ἲ", "ἳ", "ἴ", "ἵ", "ἶ", "ἷ", "ῐ", "ῑ", "ῒ", "ΐ", "ῖ", "ῗ"],
        
        // Omicron
        "ο": ["ό", "ὸ", "ὀ", "ὁ", "ὂ", "ὃ", "ὄ", "ὅ"],
        
        // Upsilon
        "υ": ["ύ", "ὺ", "ῦ", "ὐ", "ὑ", "ὒ", "ὓ", "ὔ", "ὕ", "ὖ", "ὗ", "ῠ", "ῡ", "ῢ", "ΰ", "ῦ", "ῧ"],
        
        // Omega
        "ω": ["ώ", "ὼ", "ῶ", "ὠ", "ὡ", "ὢ", "ὣ", "ὤ", "ὥ", "ὦ", "ὧ", "ᾠ", "ᾡ", "ᾢ", "ᾣ", "ᾤ", "ᾥ", "ᾦ", "ᾧ", "ῲ", "ῳ", "ῴ", "ῷ"],
                
        // Rho with rough breathing (this occurs at the beginning of words in Ancient Greek)
        "ρ": ["ῥ", "Ῥ"]
    ]
    
    // User preferences for vowel variations (tracking frequently used combinations)
    private var userPreferences: [String: [String: Int]] = [:]
    
    // Text predictor for suggestions
    private let textPredictor = GreekTextPredictor()
    
    init() {
        // Initialize user preferences with default weights
        for (vowel, options) in vowelOptions {
            userPreferences[vowel] = [:]
            for option in options {
                // Start with a base usage frequency of 1
                userPreferences[vowel]?[option] = 1
            }
        }
    }
    
    // Get polytonic options for a specified vowel, ordered by user preference
    func getOptionsForVowel(_ vowel: String) -> [String] {
        // Use default common options for each vowel - we're focusing on limited, most frequent options
        if let options = vowelOptions[vowel], !options.isEmpty {
            return options
        }
        
        return []
    }
    
    // Get all polytonic options for a vowel (for potential advanced mode)
    func getAllOptionsForVowel(_ vowel: String) -> [String] {
        // First check if we have learned preferences
        if let preferences = userPreferences[vowel], !preferences.isEmpty {
            // Get most frequently used options from the text predictor
            let predictedOptions = textPredictor.getSuggestedPolytonicVariations(for: vowel)
            
            // If the predictor has suggestions, use those
            if !predictedOptions.isEmpty {
                return predictedOptions
            }
            
            // Otherwise, use user preferences sorted by frequency
            let sortedOptions = preferences.sorted { $0.value > $1.value }
                .prefix(8)
                .map { $0.key }
            
            if !sortedOptions.isEmpty {
                return sortedOptions
            }
        }
        
        // Fallback to default options
        if let options = allVowelOptions[vowel], !options.isEmpty {
            if options.count > 8 {
                // Return most commonly used options if there are too many
                return Array(options.prefix(8))
            }
            return options
        }
        
        return []
    }
    
    // Record that a user selected a specific polytonic character
    func recordSelection(of character: String, for vowel: String) {
        // Update user preferences
        userPreferences[vowel]?[character, default: 0] += 1
        
        // If this is a character not in our common list, add it
        if let options = vowelOptions[vowel], !options.contains(character) {
            // Check if it's in the full list of options
            if let allOptions = allVowelOptions[vowel], allOptions.contains(character) {
                // It's a valid character but not in our common list
                // Consider adding it as the user has explicitly chosen it
                // For now we just record the preference, but we could potentially
                // update the vowelOptions array in a future version
                print("User selected uncommon character: \(character) for vowel: \(vowel)")
            }
        }
    }
    
    // Learn from user input text
    func learnFromText(_ text: String) {
        textPredictor.learnFromInput(text: text)
    }
    
    // Get word suggestions based on current input
    func getSuggestedWords(for partialWord: String) -> [String] {
        return textPredictor.getSuggestedWords(for: partialWord)
    }
    
    // Get next character predictions
    func getPredictedNextCharacters(for text: String) -> [String] {
        return textPredictor.getPredictedNextCharacters(for: text)
    }
    
    // Optional method to get a description of what each diacritical mark does
    func getDiacriticalDescription(for character: String) -> String {
        // Iota subscript
        if character.contains("ᾳ") || character.contains("ῃ") || character.contains("ῳ") {
            return "Iota subscript - small iota written under the vowel"
        }
        // Combined forms with iota subscript
        else if character.contains("ᾴ") || character.contains("ῄ") || character.contains("ῴ") {
            return "Iota subscript with acute accent"
        }
        else if character.contains("ᾷ") || character.contains("ῇ") || character.contains("ῷ") {
            return "Iota subscript with circumflex accent"
        }
        // Basic accent marks
        else if character.contains("ά") || character.contains("έ") || character.contains("ή") ||
                character.contains("ί") || character.contains("ό") || character.contains("ύ") ||
                character.contains("ώ") {
            return "Acute accent (oxia) - rising tone"
        }
        else if character.contains("ὰ") || character.contains("ὲ") || character.contains("ὴ") ||
                character.contains("ὶ") || character.contains("ὸ") || character.contains("ὺ") ||
                character.contains("ὼ") {
            return "Grave accent (varia) - falling tone"
        }
        else if character.contains("ᾶ") || character.contains("ῆ") || character.contains("ῖ") ||
                character.contains("ῦ") || character.contains("ῶ") {
            return "Circumflex (perispomeni) - rising-falling tone"
        }
        // Breathing marks
        else if character.contains("ἀ") || character.contains("ἐ") || character.contains("ἠ") ||
                character.contains("ἰ") || character.contains("ὀ") || character.contains("ὐ") ||
                character.contains("ὠ") {
            return "Smooth breathing (psili) - h sound is absent"
        }
        else if character.contains("ἁ") || character.contains("ἑ") || character.contains("ἡ") ||
                character.contains("ἱ") || character.contains("ὁ") || character.contains("ὑ") ||
                character.contains("ὡ") || character.contains("ῥ") || character.contains("Ῥ") {
            return "Rough breathing (dasia) - h sound is present"
        }
        return "Polytonic Greek character"
    }
}
