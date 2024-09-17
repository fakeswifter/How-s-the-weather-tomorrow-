//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by 景皓彦 on 2024/8/20.
//

import WidgetKit
import SwiftUI

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
        WeatherWidgetControl()
        WeatherWidgetLiveActivity()
    }
}
