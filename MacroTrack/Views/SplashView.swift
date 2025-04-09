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
                .frame(width: 400, height: 400)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.secondary)
    }
}

struct VideoPlayerView: View {
    var body: some View {
        if let videoUrl = Bundle.main.url(forResource: "LogoAnimated", withExtension: "mp4") {
            let player = AVPlayer(url: videoUrl)
            return AnyView(
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
                    .aspectRatio(650 / 520, contentMode: .fit)
            )
        } else {
            return AnyView(
                Image("FullLogoGreen")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}
