// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let blue = ColorAsset(name: "Colors/blue")
    internal static let border = ColorAsset(name: "Colors/border")
    internal static let destructive = ColorAsset(name: "Colors/destructive")
    internal static let lightText = ColorAsset(name: "Colors/lightText")
    internal static let pointerRed = ColorAsset(name: "Colors/pointerRed")
    internal static let selectionGray = ColorAsset(name: "Colors/selectionGray")
    internal static let timelineGray = ColorAsset(name: "Colors/timelineGray")
    internal static let white = ColorAsset(name: "Colors/white")
  }
  internal enum Icons {
    internal static let addTimecode = ImageAsset(name: "Icons/addTimecode")
    internal static let decay = ImageAsset(name: "Icons/decay")
    internal static let growth = ImageAsset(name: "Icons/growth")
    internal static let music = ImageAsset(name: "Icons/music")
    internal static let pause = ImageAsset(name: "Icons/pause")
    internal static let play = ImageAsset(name: "Icons/play")
    internal static let pointer = ImageAsset(name: "Icons/pointer")
    internal static let removeTimecode = ImageAsset(name: "Icons/removeTimecode")
    internal static let revert = ImageAsset(name: "Icons/revert")
    internal static let scissors = ImageAsset(name: "Icons/scissors")
  }
  internal static let activeCheckbox = ImageAsset(name: "activeCheckbox")
  internal static let backButton = ImageAsset(name: "backButton")
  internal static let dismiss = ImageAsset(name: "dismiss")
  internal static let dog = ImageAsset(name: "dog")
  internal static let gallery = ImageAsset(name: "gallery")
  internal static let inactiveCheckbox = ImageAsset(name: "inactiveCheckbox")
  internal static let lastScreen = ImageAsset(name: "lastScreen")
  internal static let mainScreen = ImageAsset(name: "mainScreen")
  internal static let nextButton = ImageAsset(name: "nextButton")
  internal static let podcast = ImageAsset(name: "podcast")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = Color(asset: self)

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
