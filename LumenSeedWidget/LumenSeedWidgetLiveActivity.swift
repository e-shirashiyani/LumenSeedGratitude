//
//  LumenSeedWidgetLiveActivity.swift
//  LumenSeedWidget
//
//  Created by e.shirashiyani on 5/3/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LumenSeedWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LumenSeedWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LumenSeedWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LumenSeedWidgetAttributes {
    fileprivate static var preview: LumenSeedWidgetAttributes {
        LumenSeedWidgetAttributes(name: "World")
    }
}

extension LumenSeedWidgetAttributes.ContentState {
    fileprivate static var smiley: LumenSeedWidgetAttributes.ContentState {
        LumenSeedWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LumenSeedWidgetAttributes.ContentState {
         LumenSeedWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LumenSeedWidgetAttributes.preview) {
   LumenSeedWidgetLiveActivity()
} contentStates: {
    LumenSeedWidgetAttributes.ContentState.smiley
    LumenSeedWidgetAttributes.ContentState.starEyes
}
