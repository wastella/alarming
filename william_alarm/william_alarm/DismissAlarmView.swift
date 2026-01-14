//
//  DismissAlarmView.swift
//  william_alarm
//
//  Created by William Stella on 1/14/26.
//

import SwiftUI
import AVFoundation

struct DismissAlarmView: View {
    @Binding var isAlarmActive: Bool
    @State private var player: AVAudioPlayer?

    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            VStack(spacing: 40) {
                Text("Wake Up!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                Button(action: {
                    stopAlarm()
                }) {
                    Text("Dismiss Alarm")
                        .font(.title)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.red)
                        .cornerRadius(20)
                }
            }
            .padding()
        }
        .onAppear {
            startAlarmSound()
        }
    }

    func startAlarmSound() {
        guard let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            print("Error playing alarm sound: \(error)")
        }
    }

    func stopAlarm() {
        player?.stop()
        isAlarmActive = false
    }
}
