import UIKit
import AVFoundation
import ASPVideoPlayer

class MultiLanguagePlayerViewController: UIViewController {
    private let videoURLString = "https://vz-523ce233-fda.b-cdn.net/bcdn_token=Ke9XLO5009FQtYn3DUeIQFBZog6kJEgqj-PwH88okDw&token_path=%2F&expires=3438947329/fae1041b-485a-49be-a8c2-dfc44a6d1c32/playlist.m3u8"

    private let playerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    private let playButton = MultiLanguagePlayerViewController.makeButton(title: "Play")
    private let pauseButton = MultiLanguagePlayerViewController.makeButton(title: "Pause")
    private let languageButton = MultiLanguagePlayerViewController.makeButton(title: "Change Language")

    private let player = AVPlayer()
    private let playerLayer = AVPlayerLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Multilanguage"
        view.backgroundColor = .systemBackground

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        playerContainerView.layer.addSublayer(playerLayer)

        view.addSubview(playerContainerView)
        view.addSubview(playButton)
        view.addSubview(pauseButton)
        view.addSubview(languageButton)

        NSLayoutConstraint.activate([
            playerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playerContainerView.heightAnchor.constraint(equalToConstant: 220),

            playButton.topAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: 24),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            pauseButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 16),
            pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            languageButton.topAnchor.constraint(equalTo: pauseButton.bottomAnchor, constant: 16),
            languageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
        languageButton.addTarget(self, action: #selector(changeLanguageTapped), for: .touchUpInside)

        if let url = URL(string: videoURLString) {
            let item = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: item)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerContainerView.bounds
    }

    @objc private func playTapped() {
        player.play()
    }

    @objc private func pauseTapped() {
        player.pause()
    }

    @objc private func changeLanguageTapped() {
        guard let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .audible) else {
            return
        }

        let alert = UIAlertController(title: "Audio Language", message: nil, preferredStyle: .actionSheet)

        for option in group.options {
            let languageName = option.displayName
            alert.addAction(UIAlertAction(title: languageName, style: .default, handler: { [weak self] _ in
                self?.player.currentItem?.select(option, in: group)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private static func makeButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return button
    }
}
