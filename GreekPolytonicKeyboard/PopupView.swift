import UIKit

// Protocol to handle option selection from the popup
protocol PopupViewDelegate: AnyObject {
    func optionSelected(_ option: String)
}

class PopupView: UIView {
    
    // UI components
    private var collectionView: UICollectionView!
    
    // Options to display
    private var options: [String] = []
    
    // Delegate to handle selection
    weak var delegate: PopupViewDelegate?
    
    // Initialize with character options and position
    init(options: [String], vowelOrigin: CGPoint, vowelSize: CGSize) {
        // Create a smaller, more focused popup based on our smaller options list
        // Width is calculated based on number of options plus padding
        let optionCount = min(options.count, 5) // We now show max 5 options
        let popupWidth = CGFloat(optionCount * 45) // 45px per option + padding
        
        super.init(frame: CGRect(x: 0, y: 0, width: popupWidth, height: 60))
        self.options = options
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // Set up the popup view
    private func setupView() {
        // iOS native popup styling
        backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        translatesAutoresizingMaskIntoConstraints = false
        
        // iOS native popup appearance
        layer.cornerRadius = 10
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        
        // Subtle shadow (iOS style)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 3
        
        // Create a collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 40, height: 50) // Larger cells for better visibility
        layout.minimumInteritemSpacing = 2 // Tighter spacing
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        // Create the collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OptionCell.self, forCellWithReuseIdentifier: "OptionCell")
        
        // Important: Make sure user interaction is enabled
        isUserInteractionEnabled = true
        collectionView.isUserInteractionEnabled = true
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Helper Methods for Drag Selection
    
    // Get the collection view for drag handling
    func getCollectionView() -> UICollectionView? {
        return collectionView
    }
    
    // Get option at specific index
    func getOptionAt(index: Int) -> String {
        guard index >= 0 && index < options.count else {
            print("ERROR: Option index out of bounds: \(index)")
            return ""
        }
        return options[index]
    }
    
    // Process touch point to handle drag selection
    func processTouchPoint(_ point: CGPoint) -> Int? {
        guard let indexPath = collectionView.indexPathForItem(at: point) else {
            return nil
        }
        return indexPath.item
    }
}

// MARK: - UICollectionViewDataSource
extension PopupView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCell
        cell.configure(with: options[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PopupView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.item]
        print("PopupView - option selected via tap: \(selectedOption)")
        delegate?.optionSelected(selectedOption)
    }
    
    // Handle cell highlighting during dragging
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("PopupView - cell highlighted at: \(indexPath.item)")
        // Visual feedback
        if let cell = collectionView.cellForItem(at: indexPath) as? OptionCell {
            cell.isHighlighted = true
        }
    }
    
    // Handle cell unhighlighting
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        print("PopupView - cell unhighlighted at: \(indexPath.item)")
        if let cell = collectionView.cellForItem(at: indexPath) as? OptionCell {
            cell.isHighlighted = false
        }
    }
}

// MARK: - Option Cell
class OptionCell: UICollectionViewCell {
    // Main character label
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)  // Larger font for better visibility
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Small hint label to show what the diacritic is (iota subscript, breathing mark, etc.)
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 8) // Very small hint text
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true // Hidden by default, only shown for special cases
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        // Cell styling - make it look like an iOS keyboard popup option
        contentView.backgroundColor = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1.0)
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        
        // Add both labels
        contentView.addSubview(label)
        contentView.addSubview(hintLabel)
        
        NSLayoutConstraint.activate([
            // Main character label centered
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -2), // Slight offset for hint
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            
            // Hint label below main label
            hintLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            hintLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: -4),
            hintLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            hintLabel.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
    
    func configure(with text: String) {
        // For standalone accent marks, we need to make them visible by combining with a base character
        if text == "\u{0301}" { // Acute accent
            label.text = "ά"    // Example with alpha
            hintLabel.text = "acute"
            hintLabel.isHidden = false
        } else if text == "\u{0300}" { // Grave accent
            label.text = "ὰ"    // Example with alpha
            hintLabel.text = "grave"
            hintLabel.isHidden = false
        } else {
            label.text = text
            
            // Provide hints for common diacritical marks
            if text.contains("ᾳ") || text.contains("ῃ") || text.contains("ῳ") {
                hintLabel.text = "iota"
                hintLabel.isHidden = false
            } else if text.contains("ἀ") || text.contains("ἐ") || text.contains("ἠ") ||
                       text.contains("ἰ") || text.contains("ὀ") || text.contains("ὐ") ||
                       text.contains("ὠ") {
                hintLabel.text = "smooth"
                hintLabel.isHidden = false
            } else if text.contains("ἁ") || text.contains("ἑ") || text.contains("ἡ") ||
                       text.contains("ἱ") || text.contains("ὁ") || text.contains("ὑ") ||
                       text.contains("ὡ") {
                hintLabel.text = "rough"
                hintLabel.isHidden = false
            } else if text.contains("ά") || text.contains("έ") || text.contains("ή") ||
                       text.contains("ί") || text.contains("ό") || text.contains("ύ") ||
                       text.contains("ώ") {
                hintLabel.text = "acute"
                hintLabel.isHidden = false
            } else if text.contains("ᾶ") || text.contains("ῆ") || text.contains("ῖ") ||
                       text.contains("ῦ") || text.contains("ῶ") {
                hintLabel.text = "circum"
                hintLabel.isHidden = false
            } else {
                hintLabel.isHidden = true
            }
        }
        
        // Print debug info about the character
        print("Cell configured with: \(text), displayed as: \(label.text ?? "nil")")
    }
    
    // Highlight when selected with more visible feedback
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                if self.isHighlighted {
                    // More dramatic highlighting for better visibility
                    self.contentView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.9, alpha: 1.0)
                    self.contentView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    self.label.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.8, alpha: 1.0)
                    self.hintLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.8, alpha: 1.0)
                } else {
                    self.contentView.backgroundColor = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1.0)
                    self.contentView.transform = .identity
                    self.label.textColor = .black
                    self.hintLabel.textColor = .darkGray
                }
            }
            
            // Print debug info for highlight state changes
            print("Cell highlight state changed: \(isHighlighted ? "highlighted" : "unhighlighted") - \(label.text ?? "unknown")")
        }
    }
}
