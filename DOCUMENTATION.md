# Greek Polytonic Keyboard - Technical Documentation

This document provides a detailed technical overview of the Greek Polytonic Keyboard extension for iOS.

## Architecture Overview

The Greek Polytonic Keyboard is structured as an iOS keyboard extension with a companion container app. The architecture follows Apple's extension guidelines while incorporating specialized functionality for polytonic Greek input.

### Components

1. **Container App** (`GreekPolytonicKeyboardApp`)
   - Provides installation instructions and testing interface
   - Serves as the distribution vehicle for the keyboard extension

2. **Keyboard Extension** (`GreekPolytonicKeyboard`)
   - The actual keyboard implementation
   - Handles user input and text prediction
   - Manages character variations and diacritical marks

## Core Classes and Their Responsibilities

### `KeyboardViewController.swift`

The main entry point for the keyboard extension. This class:
- Initializes and manages the keyboard view
- Handles text input events
- Manages the suggestion bar for word predictions
- Tracks user typing patterns for the learning algorithm
- Communicates with the hosting app through the `UITextDocumentProxy`

Key methods:
- `viewDidLoad()`: Sets up the keyboard UI
- `setupSuggestionBar()`: Creates the suggestion bar UI
- `updateSuggestions()`: Updates word predictions
- Delegate methods (`keyTapped`, `backspaceTapped`, etc.) for handling user interaction

### `KeyboardView.swift`

Responsible for the visual representation and layout of the keyboard. This class:
- Creates and arranges keys in a QWERTY or Greek layout
- Handles touch events on keys
- Displays popup views for polytonic character selection

Key methods:
- `setupKeys()`: Creates and positions all keys
- `handleLongPress()`: Detects long press on vowels
- `showPopupForVowel()`: Displays polytonic options
- `hidePopup()`: Removes the popup when selection is complete

### `GreekCharacterProvider.swift`

Manages polytonic Greek character sets and variations. This class:
- Stores mappings between base vowels and their polytonic variations
- Tracks user preferences for character variations
- Integrates with the text predictor
- Provides methods to access character variations

Key methods:
- `getOptionsForVowel()`: Returns polytonic variations for a vowel
- `recordSelection()`: Updates learning data when user selects a character
- `learnFromText()`: Updates learning data from typed text
- `getSuggestedWords()`: Gets word predictions

### `GreekTextPredictor.swift`

Implements the learning algorithm for text prediction. This class:
- Maintains frequency data for Greek words
- Builds and updates n-gram models for prediction
- Tracks commonly used polytonic combinations
- Provides predictions based on current input

Key methods:
- `learnFromInput()`: Updates the learning model with new text
- `learnPolytonicPatterns()`: Analyzes polytonic usage patterns
- `getSuggestedWords()`: Provides word predictions
- `getSuggestedPolytonicVariations()`: Returns frequently used accents for vowels

### `KeyButton.swift`

A custom button class for keyboard keys. This class:
- Defines the appearance of keyboard buttons
- Handles touch events and visual feedback
- Supports long press gestures for vowels

### `PopupView.swift`

Displays polytonic character options. This class:
- Creates a popup with character options
- Arranges options in a horizontal layout
- Handles selection of polytonic characters

## Data Flow

1. User taps or long-presses a key
2. `KeyboardView` detects the event and notifies its delegate (`KeyboardViewController`)
3. For vowel long-presses, the `PopupView` shows options provided by `GreekCharacterProvider`
4. When a character is selected, it's inserted via the text document proxy
5. The selection is recorded by `GreekCharacterProvider` for learning
6. Word completion suggestions are updated based on the current input and learned patterns

## Learning Algorithm

The learning algorithm has two main components:

1. **Polytonic Pattern Learning**
   - Tracks which diacritical marks are frequently used with each vowel
   - Maintains frequency counters for each vowel-accent combination
   - Sorts options by frequency when displaying the popup

2. **Word Prediction**
   - Maintains a dictionary of Greek words with usage frequencies
   - Builds n-gram models to predict next characters
   - Uses a combination of predefined common words and learned patterns
   - Updates frequencies with each word typed by the user

## Data Persistence

User preferences and learning data are persisted using:
- In-memory storage during active sessions
- UserDefaults for simple preferences
- The container app's document directory for larger datasets

## Keyboard Layout

The keyboard layout is organized in rows, similar to the standard iOS keyboard:
- Top row: Contains numerals and punctuation
- Middle rows: Contains Greek letters arranged for convenient typing
- Bottom row: Contains utility keys (space, return, delete, keyboard switch)

## Performance Considerations

The keyboard is optimized for performance with:
- Lazy loading of resources
- Efficient memory management
- Throttling of learning algorithm updates
- Limiting the number of displayed suggestions

## Testing

Testing the keyboard involves:
1. Unit tests for individual components (character provider, text predictor)
2. Integration tests for keyboard functionality
3. UI tests for layout and interaction
4. Performance tests to ensure responsive typing

## Limitations and Future Improvements

Current limitations:
- Limited initial dictionary for prediction
- No cloud sync of user preferences
- Limited keyboard themes

Planned improvements:
- Expanded dictionary of ancient Greek terms
- Additional keyboard layouts (scholarly variants)
- Advanced linguistic features for ancient Greek texts
- Theme customization options
- Synchronization of learning data across devices

## Debugging

For debugging:
- Enable keyboard logging in the container app
- Use Xcode's debugging tools to monitor memory and performance
- Check the device console for extension-related messages

## Localization

The keyboard supports:
- Interface localization for multiple languages
- Greek character set regardless of interface language
- Right-to-left layout adjustments where needed