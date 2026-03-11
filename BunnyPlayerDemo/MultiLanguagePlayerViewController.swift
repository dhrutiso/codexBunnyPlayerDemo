import AVFoundation
import UIKit

final class MultiLanguagePlayerViewController: UIViewController {
    private let videoURL = URL(string: "https://vz-523ce233-fda.b-cdn.net/bcdn_token=Ke9XLO5009FQtYn3DUeIQFBZog6kJEgqj-PwH88okDw&token_path=%2F&expires=3438947329/fae1041b-485a-49be-a8c2-dfc44a6d1c32/playlist.m3u8")!

    private let playerContainer = ASPPlayerContainerView()
    private let languageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Audio Track", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let player = AVPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Multilanguage"
        view.backgroundColor = .systemBackground

        setupUI()
        configurePlayer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }

    private func setupUI() {
        view.addSubview(playerContainer)
        view.addSubview(languageButton)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            playerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerContainer.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9.0 / 16.0),

            languageButton.topAnchor.constraint(equalTo: playerContainer.bottomAnchor, constant: 18),
            languageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusLabel.topAnchor.constraint(equalTo: languageButton.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        playerContainer.attach(to: self)
        languageButton.addTarget(self, action: #selector(showAudioTracks), for: .touchUpInside)
    }

    private func configurePlayer() {
        let item = AVPlayerItem(url: videoURL)
        player.replaceCurrentItem(with: item)
        playerContainer.player = player
        statusLabel.text = "Loading HLS stream..."

        item.asset.loadValuesAsynchronously(forKeys: ["availableMediaCharacteristicsWithMediaSelectionOptions"]) { [weak self] in
            DispatchQueue.main.async {
                self?.statusLabel.text = "Stream ready. Use Audio Track to switch language."
            }
        }
    }

    @objc private func showAudioTracks() {
        guard
            let item = player.currentItem,
            let group = item.asset.mediaSelectionGroup(forMediaCharacteristic: .audible)
        else {
            showAlert(title: "No Audio Tracks", message: "No selectable audio tracks found for this stream.")
            return
        }

        let sheet = UIAlertController(title: "Audio Track", message: nil, preferredStyle: .actionSheet)

        for option in group.options {
            let action = UIAlertAction(title: option.displayName, style: .default) { [weak self] _ in
                item.select(option, in: group)
                self?.statusLabel.text = "Selected: \(option.displayName)"
            }
            sheet.addAction(action)
        }

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
