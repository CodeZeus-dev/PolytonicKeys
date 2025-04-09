import UIKit

class ViewController: UIViewController {
    
    private let textView = UITextView()
    private let instructionLabel = UILabel()
    private let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Set up title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Greek Polytonic Keyboard"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        // Set up instruction label
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.text = "To enable this keyboard, go to:\nSettings > General > Keyboard > Keyboards > Add New Keyboard... > Greek Polytonic\n\nThen long-press vowels for polytonic options."
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(instructionLabel)
        
        // Set up text view for testing
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Tap here to test the keyboard..."
        view.addSubview(textView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            textView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 30),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}
