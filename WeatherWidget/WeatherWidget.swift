//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by 景皓彦 on 2024/8/20.
//

import WidgetKit
import SwiftUI
import WeatherKit
import CoreLocation

struct WeatherWidgetEntry: TimelineEntry {
    let date: Date
    let temperature: String
    let condition: String
}

struct WeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherWidgetEntry {
        WeatherWidgetEntry(date: Date(), temperature: "25°C", condition: "Sunny")
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherWidgetEntry) -> Void) {
        let entry = WeatherWidgetEntry(date: Date(), temperature: "25°C", condition: "Sunny")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherWidgetEntry>) -> Void) {
        // 获取天气数据并更新 Widget
        let weatherService = WeatherService()
        let locationManager = CLLocationManager()

        locationManager.requestLocation()

        if let location = locationManager.location {
            Task {
                do {
                    let weather = try await weatherService.weather(for: location)
                    let temperature = "\(Int(weather.currentWeather.temperature.value))°C"
                    let condition = weather.currentWeather.condition.rawValue

                    let entry = WeatherWidgetEntry(date: Date(), temperature: temperature, condition: condition)
                    
                    // 创建一个 Timeline，设置刷新策略
                    let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))) // 每小时刷新一次
                    completion(timeline)
                } catch {
                    // 错误处理
                    let entry = WeatherWidgetEntry(date: Date(), temperature: "N/A", condition: "Error")
                    let timeline = Timeline(entries: [entry], policy: .atEnd)
                    completion(timeline)
                }
            }
        } else {
            // 无法获取位置
            let entry = WeatherWidgetEntry(date: Date(), temperature: "N/A", condition: "No Location")
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct WeatherWidgetEntryView : View {
    var entry: WeatherProvider.Entry

    var body: some View {
        VStack {
            Text(entry.condition)
                .font(.headline)
                .padding()
            Text(entry.temperature)
                .font(.largeTitle)
                .bold()
        }
        .containerBackground(.white, for: .widget)

    }
}


struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Weather Widget")
        .description("Displays the current weather.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}



struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherWidgetEntryView(entry: WeatherWidgetEntry(date: Date(), temperature: "25°C", condition: "Sunny"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
