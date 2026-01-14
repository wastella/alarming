import SwiftUI
import UserNotifications
import AVFoundation
import Combine

struct AlarmView: View {
    @State private var wakeupTime: Date = Calendar.current.date(
        from: DateComponents(hour: 7, minute: 0)
    ) ?? Date()
    @State private var alarmSet = false
    @State private var animateColor = false
    @State private var showRepeatAlert = false
    @State private var isAlarmActive = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Alarm")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            Spacer()
            Text("Set Your Wake-Up Time!")
                .font(.title)
                .padding()

            DatePicker("Wake-up Time", selection: $wakeupTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
            
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()

                if alarmSet {
                    cancelAlarm()
                } else {
                    showRepeatAlert = true
                }
            } label: {
                HStack {
                    if alarmSet {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    }
                    Text(alarmSet ? "Alarm Set" : "Set Alarm")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(alarmSet ? (animateColor ? Color.green : Color.blue) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            Spacer()
        }
        .fullScreenCover(isPresented: $isAlarmActive) {
            DismissAlarmView(isAlarmActive: $isAlarmActive)
        }
        .alert("Set Alarm", isPresented: $showRepeatAlert) {
            Button("Repeat Daily") {
                scheduleAlarm(repeats: true)
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateColor.toggle()
                }
            }
            Button("One-Time") {
                scheduleAlarm(repeats: false)
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateColor.toggle()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Do you want the alarm to repeat daily?")
        }
        .onChange(of: wakeupTime) { _ in
            if alarmSet {
                cancelAlarm()
                animateColor = false
            }
        }
        .onAppear {
            loadAlarm()
            
            // Listen for notification taps to show full-screen dismissal
            NotificationCenter.default.addObserver(forName: NSNotification.Name("AlarmTapped"), object: nil, queue: .main) { _ in
                isAlarmActive = true
            }
        }
    }
    
    // MARK: - Alarm Functions
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }

    func scheduleAlarm(repeats: Bool) {
        let content = UNMutableNotificationContent()
        content.title = "Wake Up!"
        content.body = "It's time to wake up."
        content.sound = UNNotificationSound.default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeupTime)
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)

        let request = UNNotificationRequest(identifier: "AlarmNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling alarm: \(error.localizedDescription)")
            }
        }

        alarmSet = true
        saveAlarm(repeats: repeats)
    }

    func cancelAlarm() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["AlarmNotification"])
        alarmSet = false
        saveAlarm(repeats: false)
    }

    func loadAlarm() {
        if let savedTime = UserDefaults.standard.object(forKey: "WakeupTime") as? Date {
            wakeupTime = savedTime
            alarmSet = UserDefaults.standard.bool(forKey: "AlarmSet")
        }
    }

    func saveAlarm(repeats: Bool) {
        UserDefaults.standard.set(wakeupTime, forKey: "WakeupTime")
        UserDefaults.standard.set(alarmSet, forKey: "AlarmSet")
        UserDefaults.standard.set(repeats, forKey: "RepeatDaily")
    }
}
