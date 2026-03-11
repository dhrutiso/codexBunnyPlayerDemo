import AVFoundation
import UIKit

final class AdvertisementPlayerViewController: UIViewController {
    private let mainVideoURL = URL(string: "https://vastrnd.indiaontrack.in/videos/main_video1.mp4")!
    private let vmapURL = URL(string: "https://vastrnd.indiaontrack.in/vmap")!

    private let player = AVPlayer()
    private let playerContainer = ASPPlayerContainerView()
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13)
        return label
    }()

    private let vmapService = VMAPService()
    private var endObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Advertisement"
        view.backgroundColor = .systemBackground

        setupUI()
        playerContainer.player = player
        loadAndPlay()
    }

    deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
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
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            playerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerContainer.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9.0 / 16.0),

            statusLabel.topAnchor.constraint(equalTo: playerContainer.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        playerContainer.attach(to: self)
    }

    private func loadAndPlay() {
        statusLabel.text = "Fetching VMAP and loading pre-roll ad..."

        vmapService.fetchPreRoll(from: vmapURL) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let vmap):
                if let adURL = vmap.preRollURL {
                    self.playPreRoll(url: adURL)
                } else {
                    self.statusLabel.text = "No pre-roll ad found. Playing main video."
                    self.playMainVideo()
                }
            case .failure(let error):
                self.statusLabel.text = "Ad loading failed: \(error.localizedDescription). Playing main video."
                self.playMainVideo()
            }
        }
    }

    private func playPreRoll(url: URL) {
        statusLabel.text = "Playing pre-roll advertisement..."
        let adItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: adItem)
        player.play()

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: adItem,
            queue: .main
        ) { [weak self] _ in
            self?.playMainVideo()
        }
    }

    private func playMainVideo() {
        statusLabel.text = "Playing main content"
        let mainItem = AVPlayerItem(url: mainVideoURL)
        player.replaceCurrentItem(with: mainItem)
        player.play()
    }
}
