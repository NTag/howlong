//
//  HowLongWidgetBundle.swift
//  HowLongWidget
//
//  Created by Basile Bruneau on 25/02/2026.
//

import WidgetKit
import SwiftUI

@main
struct HowLongWidgetBundle: WidgetBundle {
    var body: some Widget {
        HowLongWidget()
        HowLongWidgetControl()
        HowLongWidgetLiveActivity()
    }
}
