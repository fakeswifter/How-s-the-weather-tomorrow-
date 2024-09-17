//
//  ContentView.swift
//  明天天气如何
//
//  Created by 景皓彦 on 2024/8/18.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct ContentView: View {
    @StateObject var weatherManager = WeatherManager()
    @State var weather: Weather?
    @State var errorMessage: String?
    
    var body: some View {
        VStack {
            if let weather = weather {
                Text("温度：\(formatTemperature(weather.currentWeather.temperature))")
                    .font(.largeTitle)
                    .padding()
                
                // 使用中文天气状况描述
                Text("天气状况：\(weatherManager.getWeatherConditionDescription(weather.currentWeather.condition))")
                    .font(.title)
                    .padding()
                
                Text("更新时间：\(formatDate(weather.currentWeather.date))")
                    .font(.subheadline)
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.title)
            } else {
                Text("正在加载天气数据...")
                    .font(.title)
                    .onAppear {
                        weatherManager.requestLocationPermission()
                        weatherManager.fetchWeatherData { result in
                            switch result {
                            case .success(let fetchedWeather):
                                self.weather = fetchedWeather
                            case .failure(let error):
                                self.errorMessage = "无法加载天气数据：\(error.localizedDescription)"
                            }
                        }
                    }
            }
        }
        .padding()
    }
    
    func formatTemperature(_ temperature: Measurement<UnitTemperature>) -> String {
        let celsius = temperature.converted(to: .celsius)
        return String(format: "%.1f℃", celsius.value)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}



#Preview {
    ContentView()
}
