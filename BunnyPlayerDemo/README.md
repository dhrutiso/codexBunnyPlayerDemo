# BunnyPlayerDemo (UIKit + ASPVideoPlayer)

This demo is storyboard-free and uses programmatic UIKit:

- `HomeViewController`
- `MultiLanguagePlayerViewController`
- `AdvertisementPlayerViewController`

## Setup

1. Create a new **iOS App** project in Xcode named `BunnyPlayerDemo` (UIKit / Swift / no SwiftUI lifecycle).
2. Replace generated Swift files with the files in this folder.
3. Place the `Podfile` at project root and run:
   ```bash
   pod install
   ```
4. Open `.xcworkspace` and run.

The player host attempts to use ASPVideoPlayer view types at runtime and falls back to `AVPlayerViewController` when unavailable.
