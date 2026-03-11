import UIKit
import AVFoundation
import ASPVideoPlayer

class AdvertisementPlayerViewController: UIViewController, XMLParserDelegate {
    private let mainVideoURLString = "https://vastrnd.indiaontrack.in/videos/main_video1.mp4"
    private let vmapURLString = "https://vastrnd.indiaontrack.in/vmap"

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Loading..."
        return label
    }()

    private let playerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    private let player = AVQueuePlayer()
    private let playerLayer = AVPlayerLayer()

    private var adURLs: [URL] = []
    private var currentElement = ""
    private var currentTimeOffset = ""
    private var parsedAdURLs: [URL] = []

    private var isPlayingAds = true

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Advertisement"
        view.backgroundColor = .systemBackground

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        playerContainerView.layer.addSublayer(playerLayer)

        view.addSubview(statusLabel)
        view.addSubview(playerContainerView)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            playerContainerView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playerContainerView.heightAnchor.constraint(equalToConstant: 220)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidFinish(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )

        loadVMAPAndStartPlayback()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerContainerView.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func loadVMAPAndStartPlayback() {
        statusLabel.text = "Loading VMAP..."

        guard let vmapURL = URL(string: vmapURLString) else {
            statusLabel.text = "Invalid VMAP URL"
            return
        }

        URLSession.shared.dataTask(with: vmapURL) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if error != nil || data == nil {
                    self.statusLabel.text = "Failed to load VMAP"
                    self.playMainVideo()
                    return
                }

                self.parsedAdURLs = []
                self.currentElement = ""
                self.currentTimeOffset = ""

                let parser = XMLParser(data: data!)
                parser.delegate = self
                parser.parse()

                self.adURLs = self.parsedAdURLs
                self.statusLabel.text = "Total Ads Found: \(self.adURLs.count)"
                self.playAdsThenMainVideo()
            }
        }.resume()
    }

    private func playAdsThenMainVideo() {
        player.removeAllItems()

        if adURLs.isEmpty {
            playMainVideo()
            return
        }

        isPlayingAds = true

        for adURL in adURLs {
            let adItem = AVPlayerItem(url: adURL)
            player.insert(adItem, after: nil)
        }

        statusLabel.text = "Ad Started"
        player.play()
    }

    @objc private func playerItemDidFinish(_ notification: Notification) {
        if isPlayingAds {
            if player.items().isEmpty {
                statusLabel.text = "Ad Finished"
                playMainVideo()
            }
        } else {
            statusLabel.text = "Main Video Finished"
        }
    }

    private func playMainVideo() {
        guard let mainURL = URL(string: mainVideoURLString) else {
            statusLabel.text = "Invalid Main Video URL"
            return
        }

        isPlayingAds = false
        player.removeAllItems()
        player.insert(AVPlayerItem(url: mainURL), after: nil)
        statusLabel.text = "Main Video Playing"
        player.play()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if elementName == "vmap:AdBreak" {
            currentTimeOffset = attributeDict["timeOffset"] ?? ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Very simple VMAP parsing: collect only pre-roll ad URLs from VASTAdData sections.
        if currentTimeOffset == "start", currentElement.contains("MediaFile") {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("http"), let url = URL(string: trimmed), !parsedAdURLs.contains(url) {
                parsedAdURLs.append(url)
            }
        }
    }
}
