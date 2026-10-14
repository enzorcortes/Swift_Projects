# 🗺️ Apple Maps Reimagined

> A SwiftUI concept that brings maps, trusted community reviews, location sharing, and nearby events into one cohesive Apple-inspired experience.

## Table of Contents

- [Mission](#-mission)
- [Why This Concept Exists](#-why-this-concept-exists)
- [What Has Been Built](#-what-has-been-built)
- [Key Product Ideas](#-key-product-ideas)
- [Technology](#-technology)
- [Project Structure](#-project-structure)
- [Run the App](#-run-the-app)
- [Prototype Limitations](#-prototype-limitations)
- [Roadmap](#-roadmap)
- [Disclaimer](#-disclaimer)

## 🎯 Mission

The mission of this project is to explore what Apple Maps could become if more of the Apple ecosystem lived directly on the map.

Instead of treating navigation, location sharing, reviews, and local discovery as separate experiences, this concept brings them together. The goal is to help people understand a place, find friends and belongings, coordinate plans, and discover something nearby without constantly switching between apps.

This project began from the perspective of a frustrated user who saw an opportunity to make these everyday tools feel simpler, more social, and more useful.

## 💡 Why This Concept Exists

Apple Maps and Find My already rely heavily on maps and location. Keeping them separate can create unnecessary friction, so this prototype imagines Find My as a native layer inside the main Maps experience.

The concept also moves away from Yelp as the primary voice behind place reviews. Instead, reviews are imagined as contributions from Apple Account users who are already part of the ecosystem. Reviewers can participate publicly, use an alias, or share activity with friends and contacts. This could make it easier for more people to contribute while making recommendations from people you know more visible and meaningful.

People naturally want to know where their friends are so they can coordinate, meet nearby, and see what others are up to. Inspired in part by the social usefulness of Snapchat's map, this project explores that behavior with privacy controls and a more utility-focused experience.

Events are another major part of the idea. Calendar plans and recommendations from services such as Eventbrite or DICE can appear where they are happening, helping users notice an event nearby or remember that something relevant is coming up soon.

## ✨ What Has Been Built

### 🗺️ Map experience

- An Apple-inspired, map-first SwiftUI interface
- New York City as the default demo region
- Map style, location, and filter controls positioned around the map
- Search suggestions displayed beneath the search field while typing
- Demo landmarks, restaurants, and other notable locations
- Place detail sheets with directions, ratings, reviews, and review submission
- Consistent close buttons and back navigation for presented menus

### ⭐ Community reviews

- A first-party review concept centered on Apple Account users rather than Yelp
- Public reviews with reviewer identity or a chosen alias
- An alias prompt when a user enables alias posting without having created one
- Friend- and contact-oriented social context
- Review composer with a standard left-to-right placeholder and typing experience
- Demo review content for selected New York City locations

### 📍 Find My integration

- A Find My layer integrated directly into the map
- Dedicated People, Devices, Items, and Me sections
- Search support for people, devices, items, and regular places
- Map annotations that open the matching Find My subsection
- Individual visibility controls for people, devices, and items
- A master control to hide or show the entire Find My layer
- Accordion-style lists for browsing Find My entries
- Simulated movement for people in the demo
- Devices grouped near a home location to reflect a realistic use case
- A Find My-inspired icon and glass-style presentation

### 🎟️ Nearby events

- Event markers displayed alongside places on the city map
- A demo pickup soccer match at Brooklyn Bridge Park Pier 5
- Upcoming timing such as **In 3 days**
- Source attribution, including:
  - Found in your Calendar
  - Found in Google Calendar
  - Recommended by Eventbrite
  - Recommended by DICE
- Contact avatars and attendee names for personal events
- Event details with venue, distance, date, time, and description
- A master Events visibility toggle
- Filters for individual sources and individual events

### 👤 Profile and preferences

- Profile presentation with avatar, name, and email address
- Places, Reports, Offline Maps, and Preferences sections
- Travel preferences for driving, walking, transit, and cycling
- Route avoidance options such as tolls, highways, hills, busy roads, and stairs
- Preferred transit-type selections
- Optional photo credit using a public nickname

### 🪟 Interface organization

- Glass-inspired sheets and controls
- Animated sheet presentation and dismissal
- Smaller map controls designed to avoid covering important content
- Improved spacing and padding throughout menus
- Feature code separated into models and focused SwiftUI view files instead of one oversized `ContentView`

## 🚀 Key Product Ideas

1. **One location hub** — Navigation, people, devices, items, reviews, and events should work together.
2. **Reviews from the ecosystem** — Make contributing easy for existing Apple users and surface opinions from trusted connections.
3. **Social coordination with control** — Help friends meet and coordinate while allowing every location layer to be hidden or filtered.
4. **Context at the right moment** — Show nearby or upcoming events when their location and timing make them useful.
5. **Privacy by design** — Give people control over identity, aliases, sharing, and which information appears on their map.

## 🛠️ Technology

- Swift
- SwiftUI
- MapKit
- Xcode
- Native Apple interface patterns and SF Symbols

Bootstrap is not used or required. The interface is built with native SwiftUI components and Apple platform frameworks.

## 🗂️ Project Structure

```text
applemapstwo/
├── AppModels.swift          # Shared place, review, Find My, and event models
├── CommunityViews.swift     # Community and social review interfaces
├── ContentView.swift        # Root application view
├── EventViews.swift         # Event markers, details, and filters
├── ExploreViews.swift       # Discovery experiences
├── FindMyViews.swift        # People, devices, items, and Find My controls
├── HomeMapView.swift        # Main map composition and feature layers
├── HomeSearchViews.swift    # Search field and inline results
├── PlaceViews.swift         # Place details and review flows
├── ProfileViews.swift       # Account, preferences, and profile interfaces
└── MyApp.swift              # Application entry point
```

## ▶️ Run the App

1. Clone this repository.
2. Open the Xcode project in a current version of Xcode.
3. Select an iPhone simulator or compatible device.
4. Build and run the app with **⌘R**.

No Bootstrap installation is needed.

## 🧪 Prototype Limitations

This is currently a product concept and interactive demo, not a replacement for Apple's production applications.

- Place reviews and Apple Account identities use sample data.
- Find My people, devices, items, locations, and movement are simulated.
- Eventbrite, DICE, Apple Calendar, and Google Calendar entries are demo content rather than live integrations.
- A production version would require appropriate APIs, user authorization, privacy protections, secure data handling, and compliance with each platform's terms.
- Access to Apple's private Find My network and private Apple Account data is not provided by this prototype.

## 🛣️ Roadmap

- Connect calendar events through EventKit with explicit user permission
- Investigate supported third-party event APIs
- Add persistent review and alias profiles
- Expand friend-only and private review visibility
- Improve routing and live place search
- Add stronger accessibility and Dynamic Type support
- Add unit and UI test coverage
- Continue adapting the experience across iPhone, iPad, and Mac

## ⚖️ Disclaimer

I do not own Apple Maps, Find My, their names, designs, icons, data, or related intellectual property. Apple Maps and Find My are products and trademarks of Apple Inc. This independent, unofficial project is not affiliated with, endorsed by, or sponsored by Apple.

The project draws inspiration from Apple Maps and Find My while exploring an original product concept born from personal frustration with the current separation of mapping, location sharing, reviews, and discovery. References to Yelp, Snapchat, Eventbrite, DICE, Google Calendar, and other third-party products are included only to explain inspiration, comparison points, or potential integrations. Their respective names and trademarks belong to their owners.

---

Made as an exploration of a more connected, social, and useful map experience. 🌎✨
