# SwiftlyImageLoader

A lightweight, fast, and highly configurable Swift image loading library with built-in caching and cancellation. Works seamlessly with UIKit, AppKit, and SwiftUI — making it suitable for iOS, macOS, tvOS, and watchOS applications.

---

## 🚀 Features

- 🧠 Smart in-memory & disk caching
- 🧹 Automatic cancellation for reused views
- 🎛️ Configurable via `SwiftlyImageLoaderConfiguration`
- ✅ Retry logic and TTL configuration
- 🧩 Modular targets: UIKit / AppKit / SwiftUI
- 🛠 Zero dependencies, pure Swift
- 📈 Great for performance-sensitive use cases (e.g. fast-scrolling lists)

---

## 🧠 How It Works – Caching Flow

When you request an image:

```
Request Image
   ↓
Check in-memory cache (fast, volatile)
   ↓
If not found → Check disk cache (persistent)
   ↓
If not found → Download from network
   ↓
Save to memory + disk caches for future use
```

- Memory Cache (`ImageCache`) → uses NSCache, evicts on memory pressure
- Disk Cache (`DiskCache`) → saves across app launches, TTL-aware

This ensures blazing-fast UI (via RAM) + reduced network usage (via disk).

---

## ⚙️ Configuration Example

```swift
ImageLoader.setup(with: SwiftlyImageLoaderConfiguration(
  memoryCacheTTL: 60,              // In-memory cache expires after 60 seconds
  diskCacheTTL: 86400,             // Disk cache expires after 24 hours
  autoCancelOnReuse: true,         // Cancel previous task for reused views
  enableBatchCancelation: true,    // Allows cancelAll() to stop all loading tasks
  logLevel: .verbose                // Enables verbose logging for debugging
))
```

---

## 📦 Installation

### Swift Package Manager (SPM)

Add this line to your `Package.swift`:

```swift
.package(url: "https://github.com/mohsinbmwm3/SwiftlyImageLoader.git", from: "1.0.0")
```

Then add one or more of the following modules to your target:

```swift
.product(name: "SwiftlyImageLoader", package: "SwiftlyImageLoader"),
.product(name: "SwiftlyImageLoaderUIKit", package: "SwiftlyImageLoader"),
.product(name: "SwiftlyImageLoaderAppKit", package: "SwiftlyImageLoader"),
.product(name: "SwiftlyImageLoaderSwiftUI", package: "SwiftlyImageLoader")
```

---

## 🛠 Configuration

Customize behavior via the `SwiftlyImageLoaderConfiguration`:

```swift
ImageLoader.setup(with: SwiftlyImageLoaderConfiguration(
    autoCancelOnReuse: true,
    enableBatchCancelation: true,
    logLevel: .verbose
))
```

### Available Options
| Property                 | Description                                                 |
|--------------------------|-------------------------------------------------------------|
| `autoCancelOnReuse`      | Cancels prior image loads for the same URL automatically    |
| `enableBatchCancelation`| Allows cancelling all tasks via `ImageLoader.cancelAll()`   |
| `logLevel`               | Controls log verbosity (`none`, `basic`, `verbose`)         |

---

## 📱 UIKit Usage

```swift
import SwiftlyImageLoaderUIKit

imageView.setImage(from: URL(string: "https://picsum.photos/id/45/800/600"))
```

Supports:
- Placeholder images
- Image reuse cancellation via config
- Memory & disk cache fallback

---

## 🖥 macOS AppKit Usage

```swift
import SwiftlyImageLoaderAppKit

imageView.setImage(from: URL(string: "https://picsum.photos/id/55/1200/800"))
```

---

## 🧑‍🎨 SwiftUI Usage

```swift
import SwiftlyImageLoaderSwiftUI

SwiftlyAsyncImage(url: URL(string: "https://picsum.photos/id/33/600/400"))
```

---

## 📁 Folder Structure

```
Sources/
├── SwiftlyImageLoader          // Core engine, caching, config
├── SwiftlyImageLoaderUIKit     // UIImageView extensions
├── SwiftlyImageLoaderAppKit    // NSImageView extensions
├── SwiftlyImageLoaderSwiftUI   // SwiftlyAsyncImage wrapper
```

---

## 🧪 Performance Testing

Use Instruments to track:
- Memory spikes
- Network reuse / caching hit rates
- Logging behavior with `.verbose` mode

Use `.cancelAll()` in `viewDidDisappear()` for clean teardown.

---

## 📄 License

MIT © Mohsin Khan

