import UIKit

final class HomeViewController: UIViewController {
    private let multilanguageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Multilanguage", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let advertisementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Advertisement", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [multilanguageButton, advertisementButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "ASP Video Demo"

        setupViews()
        setupActions()
    }

    private func setupViews() {
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            multilanguageButton.widthAnchor.constraint(equalToConstant: 220),
            advertisementButton.widthAnchor.constraint(equalTo: multilanguageButton.widthAnchor)
        ])
    }

    private func setupActions() {
        multilanguageButton.addTarget(self, action: #selector(openMultilanguage), for: .touchUpInside)
        advertisementButton.addTarget(self, action: #selector(openAdvertisement), for: .touchUpInside)
    }

    @objc private func openMultilanguage() {
        navigationController?.pushViewController(MultiLanguagePlayerViewController(), animated: true)
    }

    @objc private func openAdvertisement() {
        navigationController?.pushViewController(AdvertisementPlayerViewController(), animated: true)
    }
}
