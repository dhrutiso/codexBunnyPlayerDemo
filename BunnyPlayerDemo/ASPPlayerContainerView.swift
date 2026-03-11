import AVKit
import UIKit

#if canImport(ASPVideoPlayer)
import ASPVideoPlayer
#endif

/// A host view that prefers ASPVideoPlayer at runtime and falls back to AVPlayerViewController.
final class ASPPlayerContainerView: UIView {
    private let fallbackPlayerController = AVPlayerViewController()
    private var aspHostedView: UIView?

    var player: AVPlayer? {
        get { fallbackPlayerController.player }
        set {
            fallbackPlayerController.player = newValue
            bindPlayerToASPIfPossible(newValue)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        fallbackPlayerController.showsPlaybackControls = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func attach(to parentViewController: UIViewController) {
        if !trySetupASPView() {
            parentViewController.addChild(fallbackPlayerController)
            let fallbackView = fallbackPlayerController.view!
            fallbackView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(fallbackView)
            NSLayoutConstraint.activate([
                fallbackView.topAnchor.constraint(equalTo: topAnchor),
                fallbackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                fallbackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                fallbackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            fallbackPlayerController.didMove(toParent: parentViewController)
        }
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    @discardableResult
    private func trySetupASPView() -> Bool {
        guard aspHostedView == nil else { return true }

        let candidates = [
            "ASPVideoPlayer.ASPVideoPlayerView",
            "ASPVideoPlayer.VideoPlayerView",
            "ASPVideoPlayer.ASPVideoPlayer"
        ]

        for className in candidates {
            guard let type = NSClassFromString(className) as? UIView.Type else { continue }
            let aspView = type.init(frame: .zero)
            aspView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(aspView)
            NSLayoutConstraint.activate([
                aspView.topAnchor.constraint(equalTo: topAnchor),
                aspView.leadingAnchor.constraint(equalTo: leadingAnchor),
                aspView.trailingAnchor.constraint(equalTo: trailingAnchor),
                aspView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            aspHostedView = aspView
            bindPlayerToASPIfPossible(player)
            return true
        }

        return false
    }

    private func bindPlayerToASPIfPossible(_ player: AVPlayer?) {
        guard let aspHostedView else { return }

        let selectors = [NSSelectorFromString("setPlayer:"), NSSelectorFromString("setAvPlayer:")]
        for selector in selectors where aspHostedView.responds(to: selector) {
            _ = aspHostedView.perform(selector, with: player)
            return
        }
    }
}
