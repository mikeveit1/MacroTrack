//
//  SplashView.swift
//  MacroTrack
//
//  Created by Mike Veit on 3/7/25.
//

import Foundation
import AVKit
import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack {
            Spacer()
            VideoPlayerView()
                .frame(width: 400, height: 400) // Make sure the video fills the screen
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.secondary)
    }
}

struct VideoPlayerView: View {
    var body: some View {
        // Try to find the video URL from the app's assets
        if let videoUrl = Bundle.main.url(forResource: "LogoAnimated", withExtension: "mp4") {
            let player = AVPlayer(url: videoUrl)
            return AnyView(
                VideoPlayer(player: player)
                    .onAppear {
                        player.play() // Automatically play when the view appears
                    }
                    .onDisappear {
                        player.pause() // Pause the video if the view disappears
                    }
                    .aspectRatio(650 / 520, contentMode: .fit)
            )
        } else {
            // Fallback view if the video asset is not found
            return AnyView(
                Image("FullLogoGreen")
                    .resizable()
                    .scaledToFill() // Make sure the fallback image fills the screen
                    .edgesIgnoringSafeArea(.all) // Ensure it covers the entire screen
            )
        }
    }
}
