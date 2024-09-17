//
//  WeatherManager.swift
//  明天天气如何
//
//  Created by 景皓彦 on 2024/8/19.
//

import Foundation
import WeatherKit
import CoreLocation
import Combine

class WeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let weatherService = WeatherService()
    private let locationManager = CLLocationManager()
    private var completion: ((Result<Weather, Error>) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // 英文天气状况与中文描述的映射
    private let weatherConditionDescriptions: [WeatherCondition: String] = [
        .clear: "晴朗",
        .partlyCloudy: "局部多云",
        .cloudy: "多云",
        .rain: "下雨",
        .heavyRain: "大雨",
        .thunderstorms: "雷雨",
        .snow: "下雪",
        .foggy: "有雾",
        .windy: "大风",
        // 添加其他可能的天气状况...
    ]
    
    func getWeatherConditionDescription(_ condition: WeatherCondition) -> String {
        return weatherConditionDescriptions[condition] ?? "未知"
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func fetchWeatherData(completion: @escaping (Result<Weather, Error>) -> Void) {
        self.completion = completion
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                DispatchQueue.main.async {
                    self.completion?(.success(weather))
                }
            } catch {
                print("Failed to fetch weather: \(error)")
                DispatchQueue.main.async {
                    self.completion?(.failure(error))
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
        completion?(.failure(error))
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            completion?(.failure(NSError(domain: "LocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location services are not authorized"])))
        default:
            break
        }
    }
}

