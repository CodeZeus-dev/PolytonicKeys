import Foundation

class GreekTextPredictor {
    // Dictionary to store word frequencies
    private var wordFrequencies: [String: Int] = [:]
    
    // Dictionary to store n-gram models for prediction
    private var nGrams: [String: [String: Int]] = [:]
    
    // Common Greek words to bootstrap the predictor
    private let commonGreekWords = [
        "καί", "δέ", "τε", "μέν", "γάρ", "οὐ", "τόν", "τῶν", "τό", "ἐν",
        "τῆς", "τούς", "τά", "ἐς", "πρός", "ὁ", "οἱ", "τοῦ", "τῇ", "αὐτόν",
        "ἀλλά", "τις", "οὕτως", "εἰς", "ταῦτα", "ἐπί", "αὐτῶν", "ἦν", "ὥστε", "αὐτοῦ",
        "ἄν", "περί", "αὐτῷ", "τοῖς", "οὐδέ", "πάντα", "αὐτήν", "Θεοῦ", "ἐάν", "ἵνα"
    ]
    
    // Common polytonic patterns by vowel
    private var commonPolytonicPatterns: [String: [String: Int]] = [
        "α": ["ά": 100, "ὰ": 80, "ἀ": 150, "ἁ": 120, "ἄ": 90, "ἅ": 70],
        "ε": ["έ": 100, "ὲ": 80, "ἐ": 150, "ἑ": 120, "ἔ": 90, "ἕ": 70],
        "η": ["ή": 100, "ὴ": 80, "ἠ": 150, "ἡ": 120, "ἤ": 90, "ἥ": 70],
        "ι": ["ί": 100, "ὶ": 80, "ἰ": 150, "ἱ": 120, "ἴ": 90, "ἵ": 70],
        "ο": ["ό": 100, "ὸ": 80, "ὀ": 150, "ὁ": 120, "ὄ": 90, "ὅ": 70],
        "υ": ["ύ": 100, "ὺ": 80, "ὐ": 150, "ὑ": 120, "ὔ": 90, "ὕ": 70],
        "ω": ["ώ": 100, "ὼ": 80, "ὠ": 150, "ὡ": 120, "ὤ": 90, "ὥ": 70]
    ]
    
    init() {
        // Initialize with common Greek words
        for word in commonGreekWords {
            wordFrequencies[word] = 10
        }
        
        // Initialize some basic n-grams
        initializeBasicNGrams()
    }
    
    // Initialize basic n-grams from common words
    private func initializeBasicNGrams() {
        for word in commonGreekWords {
            if word.count >= 2 {
                for i in 0..<(word.count - 1) {
                    let startIndex = word.index(word.startIndex, offsetBy: i)
                    let endIndex = word.index(startIndex, offsetBy: 2)
                    let biGram = String(word[startIndex..<endIndex])
                    
                    if let nextCharIndex = word.index(startIndex, offsetBy: 2, limitedBy: word.endIndex) {
                        let nextChar = String(word[word.index(before: nextCharIndex)])
                        
                        if nGrams[biGram] == nil {
                            nGrams[biGram] = [:]
                        }
                        
                        nGrams[biGram]?[nextChar, default: 0] += 1
                    }
                }
            }
        }
    }
    
    // Learn from user input
    func learnFromInput(text: String) {
        // Clean the text and split into words
        let words = text.components(separatedBy: .whitespacesAndNewlines)
                       .filter { !$0.isEmpty }
        
        // Update word frequencies
        for word in words {
            wordFrequencies[word, default: 0] += 1
        }
        
        // Update n-gram model
        for word in words where word.count >= 3 {
            for i in 0..<(word.count - 2) {
                let startIndex = word.index(word.startIndex, offsetBy: i)
                let biGramEndIndex = word.index(startIndex, offsetBy: 2)
                let biGram = String(word[startIndex..<biGramEndIndex])
                
                if let nextCharIndex = word.index(startIndex, offsetBy: 2, limitedBy: word.endIndex) {
                    let nextChar = String(word[nextCharIndex])
                    
                    if nGrams[biGram] == nil {
                        nGrams[biGram] = [:]
                    }
                    
                    nGrams[biGram]?[nextChar, default: 0] += 1
                }
            }
        }
        
        // Update polytonic patterns
        learnPolytonicPatterns(from: text)
    }
    
    // Learn polytonic patterns from text
    private func learnPolytonicPatterns(from text: String) {
        for char in text {
            let charString = String(char)
            
            // Check if this is a polytonic variation
            for (baseVowel, variations) in commonPolytonicPatterns {
                if variations.keys.contains(charString) {
                    commonPolytonicPatterns[baseVowel]?[charString, default: 0] += 1
                }
            }
        }
    }
    
    // Get word suggestions based on current input
    func getSuggestedWords(for partialWord: String, limit: Int = 3) -> [String] {
        if partialWord.isEmpty {
            return []
        }
        
        // Find words that start with the partial input
        let matchingWords = wordFrequencies.keys.filter { $0.hasPrefix(partialWord) }
        
        // Sort by frequency and limit results
        return matchingWords.sorted { wordFrequencies[$0, default: 0] > wordFrequencies[$1, default: 0] }
                           .prefix(limit)
                           .map { $0 }
    }
    
    // Get next character predictions based on n-gram model
    func getPredictedNextCharacters(for text: String, limit: Int = 3) -> [String] {
        guard text.count >= 2 else { return [] }
        
        // Get last two characters for bi-gram lookup
        let startIndex = text.index(text.endIndex, offsetBy: -2)
        let biGram = String(text[startIndex...])
        
        if let predictions = nGrams[biGram] {
            // Sort predictions by frequency and return top ones
            return predictions.sorted { $0.value > $1.value }
                             .prefix(limit)
                             .map { $0.key }
        }
        
        return []
    }
    
    // Get suggested polytonic variations for a vowel, ordered by frequency
    func getSuggestedPolytonicVariations(for vowel: String, limit: Int = 6) -> [String] {
        guard let variations = commonPolytonicPatterns[vowel] else {
            return []
        }
        
        // Return variations sorted by learned frequency
        return variations.sorted { $0.value > $1.value }
                        .prefix(limit)
                        .map { $0.key }
    }
}