//
//  ContentView.swift
//  ShareToInsta
//
//  Created by Amish on 06/08/2024.
//

import SwiftUI
import FBSDKShareKit
import UIKit
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import SCSDKCoreKit
import SCSDKCreativeKit

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct GradientBackgroundModifier: ViewModifier {
    let image: UIImage
    
    @State private var backgroundGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [.white, .white]), startPoint: .top, endPoint: .bottom)
    
    func body(content: Content) -> some View {
        content
            .background(backgroundGradient)
            .onAppear {
                if let colors = image.dominantColors(count: 2), colors.count >= 2 {
                    let majorColor = Color(colors[0])
                    let secondaryColor = Color(colors[1])
                    backgroundGradient = LinearGradient(gradient: Gradient(colors: [majorColor, secondaryColor]), startPoint: .top, endPoint: .bottom)
                }
            }
    }
}

extension View {
    func gradientBackground(from image: UIImage) -> some View {
        self.modifier(GradientBackgroundModifier(image: image))
    }
}

extension UIImage {
    func dominantColors(count: Int) -> [UIColor]? {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        
        let extent = inputImage.extent
        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: inputImage,
            kCIInputExtentKey: CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        ])
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let averageColor = UIColor(
            red: CGFloat(bitmap[0]) / 255.0,
            green: CGFloat(bitmap[1]) / 255.0,
            blue: CGFloat(bitmap[2]) / 255.0,
            alpha: CGFloat(bitmap[3]) / 255.0
        )
        
        // Adjust the brightness and saturation to make the colors darker
        let darkenedColor1 = adjustBrightnessAndSaturation(color: averageColor, brightness: 0.1, saturation: 0.8)
        let darkenedColor2 = adjustBrightnessAndSaturation(color: averageColor, brightness: 0.2, saturation: 0.6)
        
        return [darkenedColor1, darkenedColor2]
    }
    
    private func adjustBrightnessAndSaturation(color: UIColor, brightness: CGFloat, saturation: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturationValue: CGFloat = 0
        var brightnessValue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturationValue, brightness: &brightnessValue, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

struct SpotifyShareView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image("husn")
                .resizable()
                .scaledToFill()
                .frame(width: 180.0, height: 180.0)
                .cornerRadius(8.0)
            
            VStack(alignment: .leading) {
                Text("Jo Tum Mere Ho")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                Text("Anuv Jain")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                
                HStack {
                    Image("saaz")
                    Text("Saaz")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                
            }
        }
        .padding(.vertical, 12.0)
        .padding(.horizontal, 12.0)
        .background(
            RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                .fill(Color.black.opacity(0.8))
        )
    }
}

struct ContentView: View {
    let image = UIImage(named: "husn")!
    
    var body: some View {
        VStack {
            SpotifyShareView()
                .gradientBackground(from: image)
            
            Button(action: {
                shareSpotifyViewToInstagram()
            }) {
                Text("Share to Instagram Stories")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                shareVideoWithSpotifyStickerToInstagramReels()
            }) {
                Text("Share Video with Spotify Sticker to Instagram Reels")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                shareVideoWithSpotifyStickerToInstagramStories()
            }) {
                Text("Share Video with Spotify Sticker to Instagram Stories")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            
            Button(action: {
                shareSpotifyViewToFacebook()
            }) {
                Text("Share to Facebook Stories")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                shareInFacebookFeed()
            }) {
                Text("Share to Facebook Feed")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                      shareToSnapchat()
                  }) {
                      Text("Share to Snapchat Stories")
                          .padding()
                          .background(Color.blue)
                          .foregroundColor(.white)
                          .cornerRadius(8)
                  }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gradientBackground(from: image)
    }
    
    func shareVideoWithSpotifyStickerToInstagramStories() {
        // Identify your App ID
        let appIDString = "512742294571294"
        
        // Identify your video content
        guard let videoURL = Bundle.main.url(forResource: "sample", withExtension: "MOV"),
              let backgroundVideoData = try? Data(contentsOf: videoURL) else {
            print("Failed to find or load video file.")
            return
        }
        
        // Convert your SpotifyShareView to an image
        let spotifyShareView = SpotifyShareView()
            .frame(width: 300, height: 400)
        
        let stickerImage = spotifyShareView.snapshot()
        
        guard let stickerImageData = stickerImage.pngData() else {
            print("Failed to convert Spotify view to PNG data.")
            return
        }
        
        // Call method to share video with Spotify sticker to Instagram Stories
        backgroundVideoWithStickerToStories(backgroundVideoData: backgroundVideoData, stickerImageData: stickerImageData, appID: appIDString)
    }

    // Method to share video with Spotify sticker to Instagram Stories
    func backgroundVideoWithStickerToStories(backgroundVideoData: Data, stickerImageData: Data, appID: String) {
        if let urlScheme = URL(string: "instagram-stories://share?source_application=\(appID)"), UIApplication.shared.canOpenURL(urlScheme) {
            // Add background video, Spotify sticker, and appID to pasteboard items
            let pasteboardItems: [String: Any] = [
                "com.instagram.sharedSticker.backgroundVideo": backgroundVideoData,
                "com.instagram.sharedSticker.stickerImage": stickerImageData,
                "com.instagram.sharedSticker.appID": appID
            ]
            
            // Set pasteboard options
            let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)]
            
            // Attach the pasteboard items
            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
            
            UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
            
        } else {
            print("Instagram Stories is not installed or URL scheme is incorrect.")
        }
    }
    
    
    
    //-------
    
    
    func shareVideoWithSpotifyStickerToInstagramReels() {
        // Identify your App ID
        let appIDString = "512742294571294"
        
        // Identify your video content
        guard let videoURL = Bundle.main.url(forResource: "sample", withExtension: "MOV"),
              let backgroundVideoData = try? Data(contentsOf: videoURL) else {
            print("Failed to find or load video file.")
            return
        }
        
        // Convert your SpotifyShareView to an image
        let spotifyShareView = SpotifyShareView().frame(width: 300, height: 400)
        let stickerImage = spotifyShareView.snapshot()
        
        guard let stickerImageData = stickerImage.pngData() else {
            print("Failed to convert Spotify view to PNG data.")
            return
        }
        
        // Call method to share video with Spotify sticker
        backgroundVideoWithStickerToReels(backgroundVideoData: backgroundVideoData, stickerImageData: stickerImageData, appID: appIDString)
    }

    // Method to share video with Spotify sticker to Instagram Reels
    func backgroundVideoWithStickerToReels(backgroundVideoData: Data, stickerImageData: Data, appID: String) {
        if let urlScheme = URL(string: "instagram-reels://share"), UIApplication.shared.canOpenURL(urlScheme) {
            // Add background video, Spotify sticker, and appID to pasteboard items
            let pasteboardItems: [[String: Any]] = [
                ["com.instagram.sharedSticker.backgroundVideo": backgroundVideoData],
                ["com.instagram.sharedSticker.stickerImage": stickerImageData],
                ["com.instagram.sharedSticker.appID": appID]
            ]
            
            // Set pasteboard options
            let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)]
            
            // Attach the pasteboard items
            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            
            UIApplication.shared.open(urlScheme)
            
        } else {
            print("Instagram Reels is not installed or URL scheme is incorrect.")
        }
    }
    
    func shareSpotifyViewToInstagram() {
        let spotifyShareView = SpotifyShareView().frame(width: 300.0, height: 400.0)
        
        let snapshotImage = spotifyShareView.snapshot()
        
        guard let imageData = snapshotImage.pngData() else {
            print("Failed to convert view to PNG data")
            return
        }
        
        let appIDString = "512742294571294"
        let (topColor, bottomColor) = getDominantColors(from: image)
        let contentURL = URL(string: "https://apps.apple.com/pk/app/saaz-ai-covers-and-songs/id6502518160")!
        shareToInstagram(imageData: imageData, appID: appIDString, topColor: topColor, bottomColor: bottomColor, contentURL: contentURL)
    }
    
    func getDominantColors(from image: UIImage) -> (String, String) {
        let colors = image.dominantColors(count: 2) ?? [.black, .black]
        let topColor = colors[0].toHexString()
        let bottomColor = colors[1].toHexString()
        return (topColor, bottomColor)
    }
    
    func shareToInstagram(imageData: Data, appID: String, topColor: String, bottomColor: String, contentURL: URL) {
        let urlScheme = URL(string: "instagram-stories://share?source_application=\(appID)")!
        
        if UIApplication.shared.canOpenURL(urlScheme) {
            let pasteboardItems: [String: Any] = [
                "com.instagram.sharedSticker.stickerImage": imageData,
                "com.instagram.sharedSticker.backgroundTopColor": topColor,
                "com.instagram.sharedSticker.backgroundBottomColor": bottomColor
            ]
            let pasteboardOptions = [
                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
            ]
            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
            UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
        } else {
            print("Instagram is not installed or URL scheme is incorrect.")
        }
    }
    
    func shareSpotifyViewToFacebook() {
        let spotifyShareView = SpotifyShareView().frame(width: 300.0, height: 400.0)
        
        let snapshotImage = spotifyShareView.snapshot()
        
        guard let stickerImageData = snapshotImage.pngData() else {
            print("Failed to convert view to PNG data")
            return
        }
        let appID = "512742294571294"
        let (topColor, bottomColor) = getDominantColors(from: UIImage(named: "husn")!)
        shareToFacebook(stickerImage: stickerImageData, topColor: topColor, bottomColor: bottomColor, appID: appID)
    }
    
    func shareToFacebook(stickerImage: Data, topColor: String, bottomColor: String, appID: String) {
        let urlScheme = URL(string: "facebook-stories://share")!
        
        if UIApplication.shared.canOpenURL(urlScheme) {
            let pasteboardItems: [String: Any] = [
                "com.facebook.sharedSticker.stickerImage": stickerImage,
                "com.facebook.sharedSticker.backgroundTopColor": topColor,
                "com.facebook.sharedSticker.backgroundBottomColor": bottomColor,
                "com.facebook.sharedSticker.appID": appID
            ]
            let pasteboardOptions = [
                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
            ]
            
            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
            UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
        } else {
            // Handle older app versions or app not installed case
            print("Facebook app is not installed or URL scheme is incorrect.")
        }
    }
    
    func shareInFacebookFeed() {
        let spotifyShareView = SpotifyShareView().frame(width: 300.0, height: 400.0)
        
        let snapshotImage = spotifyShareView.snapshot()
        
        guard let image = UIImage(data: snapshotImage.pngData()!) else {
            print("Failed to convert view to PNG data")
            return
        }
        
        let photo = SharePhoto(image: image, isUserGenerated: true)
        let content = SharePhotoContent()
        content.photos = [photo]
        
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            print("Failed to get root view controller")
            return
        }
        
        let dialog = ShareDialog(viewController: rootViewController, content: content, delegate: nil)
        dialog.mode = .automatic
        
        if dialog.canShow {
            dialog.show()
        } else {
            print("It looks like you don't have the Facebook mobile app on your phone.")
        }
    }
    
    func shareToSnapchat() {
        let spotifyShareView = SpotifyShareView().frame(width: 300.0, height: 400.0)
        
        let snapshotImage = spotifyShareView.snapshot()
        
        guard let image = UIImage(data: snapshotImage.pngData()!) else {
            print("Failed to convert view to PNG data")
            return
        }

        let snapPhoto = SCSDKSnapPhoto(image: image)
        let snapContent = SCSDKPhotoSnapContent(snapPhoto: snapPhoto)
        
        snapContent.caption = "Check this out!"
        snapContent.attachmentUrl = "https://www.yourwebsite.com"
        
        let snapAPI = SCSDKSnapAPI(content: snapContent)
        snapAPI.startSnapping { (error: Error?) in
            if let error = error {
                print("Failed to share to Snapchat: \(error.localizedDescription)")
            } else {
                print("Successfully shared to Snapchat!")
            }
        }
    }
    

}

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
}


#Preview {
    ContentView()
}

