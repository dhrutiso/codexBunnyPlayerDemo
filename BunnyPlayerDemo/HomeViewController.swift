import UIKit

class HomeViewController: UIViewController {
    private let multiLanguageButton: UIButton = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground

        view.addSubview(multiLanguageButton)
        view.addSubview(advertisementButton)

        NSLayoutConstraint.activate([
            multiLanguageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            multiLanguageButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),

            advertisementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            advertisementButton.topAnchor.constraint(equalTo: multiLanguageButton.bottomAnchor, constant: 24)
        ])

        multiLanguageButton.addTarget(self, action: #selector(openMultiLanguagePlayer), for: .touchUpInside)
        advertisementButton.addTarget(self, action: #selector(openAdvertisementPlayer), for: .touchUpInside)
    }

    @objc private func openMultiLanguagePlayer() {
        navigationController?.pushViewController(MultiLanguagePlayerViewController(), animated: true)
    }

    @objc private func openAdvertisementPlayer() {
        navigationController?.pushViewController(AdvertisementPlayerViewController(), animated: true)
    }
}
