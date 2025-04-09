import Foundation

class GreekCharacterProvider {
    
    // Dictionary mapping each vowel to its polytonic variations
    private let vowelOptions: [String: [String]] = [
        // Alpha
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
        "ω": ["ώ", "ὼ", "ῶ", "ὠ", "ὡ", "ὢ", "ὣ", "ὤ", "ὥ", "ὦ", "ὧ", "ᾠ", "ᾡ", "ᾢ", "ᾣ", "ᾤ", "ᾥ", "ᾦ", "ᾧ", "ῲ", "ῳ", "ῴ", "ῷ"]
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
        if let options = vowelOptions[vowel], !options.isEmpty {
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
        // This could be expanded to provide detailed descriptions
        if character.contains("ά") || character.contains("έ") || character.contains("ή") || 
           character.contains("ί") || character.contains("ό") || character.contains("ύ") || 
           character.contains("ώ") {
            return "Acute accent (oxia) - rising tone"
        } else if character.contains("ὰ") || character.contains("ὲ") || character.contains("ὴ") || 
                  character.contains("ὶ") || character.contains("ὸ") || character.contains("ὺ") || 
                  character.contains("ὼ") {
            return "Grave accent (varia) - falling tone"
        } else if character.contains("ῆ") || character.contains("ῖ") || character.contains("ῦ") || 
                  character.contains("ῶ") {
            return "Circumflex (perispomeni) - rising-falling tone"
        } else if character.contains("ἀ") || character.contains("ἐ") || character.contains("ἠ") || 
                  character.contains("ἰ") || character.contains("ὀ") || character.contains("ὐ") || 
                  character.contains("ὠ") {
            return "Smooth breathing (psili) - h sound is absent"
        } else if character.contains("ἁ") || character.contains("ἑ") || character.contains("ἡ") || 
                  character.contains("ἱ") || character.contains("ὁ") || character.contains("ὑ") || 
                  character.contains("ὡ") {
            return "Rough breathing (dasia) - h sound is present"
        }
        return "Polytonic Greek character"
    }
}
