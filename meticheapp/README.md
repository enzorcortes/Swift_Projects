# Constella

Constella is a private social atlas for the people, places, organizations, and moments that shape a person’s life. Instead of building another public follower network, Constella focuses on smaller, intentional circles and makes it easier to understand how those circles overlap.

The app combines a visual relationship map, shared bulletins, private circles, event planning, and a master social calendar. A person remains at the center of their own atlas while friends, mutual connections, schools, workplaces, favorite gathering places, and temporary events form the constellation around them.

## Product Vision

Most social apps flatten every relationship into the same feed. Constella gives relationships context.

A friend might be connected through college, a former workplace, a neighborhood café, or a one-night event. Constella preserves those origins while allowing each circle to maintain its own updates, plans, relationships, and shared history.

The intended experience is:

- Private and invitation-based by default.
- Centered on real relationships instead of follower counts.
- Organized around meaningful places and circles.
- Useful for catching up without searching through a busy group conversation.
- Transparent about who shared relationship information and event data.
- Designed to make introductions and mutual connections understandable.

## Current Prototype

The current SwiftUI prototype supports iOS and is structured for future macOS and watchOS experiences.

### Social Atlas

The main experience opens as a two-dimensional atlas of the user’s circles, institutions, locations, and events.

- The signed-in person appears at the center.
- Direct branches show every circle the person belongs to.
- Circle-to-circle bridges appear only when another member belongs to both circles.
- Mutual bridges use the avatar colors of the people creating the connection.
- Multiple mutual members appear as parallel colored strands.
- Each circle displays small animated satellites representing its members.
- Reduce Motion freezes orbital movement while preserving the information.
- Temporary events have a distinctive visual treatment and expiration date.
- Selecting a circle opens a focused three-dimensional relationship map.

### Focused Relationship Maps

Inside a selected circle, people appear as celestial bodies orbiting the current user.

- The current user acts as the central sun.
- Close relationships appear as larger planets.
- More distant relationships appear as moons or asteroids.
- Dragging rotates the map using a lightweight perspective projection.
- Selecting a person highlights their visible connections.
- Relationship lines communicate status and whether a perspective is mutual.
- Profiles show relationship notes and who authored each perspective.
- People control their own relationship descriptions and visibility.

### Bulletins

Every circle has a bulletin for updates that should remain easy to find after an active conversation moves on.

- Members can publish updates publicly or anonymously.
- Posts may reference people and locations.
- Updates support reactions, comments, and pinning.
- Each person’s atlas avatar can display relevant update counts.
- The posting interface includes a responsive multiline editor and privacy context.
- Demo content includes plans, recommendations, shared albums, questions, and conversations.

### Circles

Circles represent friend groups, schools, workplaces, community spaces, and temporary gatherings.

- Users can create private circles.
- Each circle has its own membership, bulletin, and relationship map.
- Event links can be imported and attributed to their original provider.
- The prototype recognizes links from Partiful, Apple Invites, Eventbrite, DICE, and other sources.
- Imported information retains its source URL and visible provenance.

### Shared Calendar

The Calendar tab is a master view of upcoming social plans across all circles.

- Browse events by date.
- Review a combined upcoming schedule.
- Associate events with a circle and source calendar.
- Add or remove attendees.
- Store contextual notes, including dietary needs and accessibility details.
- Create shared preparation and bring-item checklists.
- Add and delete Constella events.
- View prepared connection points for Apple Calendar and Google Calendar.

The prototype does not silently access external calendars. Production Apple Calendar synchronization requires EventKit authorization and the appropriate privacy usage descriptions. Google Calendar synchronization requires OAuth credentials and a secure token-handling service.

### Account and Privacy

The account area follows the hierarchy of Apple’s account settings experience.

- Editable profile picture or avatar.
- Circle, relationship, and update summaries.
- Personal information settings.
- Circle and sharing controls.
- Connected-service management.
- Notification preferences.
- Privacy, safety, blocked-account, and data-management entry points.
- Mutual-introduction discoverability controls.

## Branding and Interface

Constella uses a dark orbital visual language inspired by constellations, planetary systems, and connected points of light.

- The supplied Constella artwork is used for the app icon and onboarding identity.
- Mint, blue, purple, pink, and orange accents distinguish people and activity.
- Neutral slate foundations keep relationship and event colors legible.
- Hero areas provide clear identity and shortcuts on the primary screens.
- Hover feedback is included for pointer-based Apple devices.
- Dynamic layouts support touch and pointer interaction.

## Technology

- Swift
- SwiftUI
- Observation with an `@Observable`, main-actor-isolated `ConstellationStore`
- Native navigation, lists, forms, sheets, gestures, animation timelines, and accessibility semantics
- Asset catalogs for app and interface artwork
- A lightweight perspective projection for the interactive three-dimensional map

The current data is prototype data stored in memory for the app session. A production implementation will require authenticated accounts, durable cloud storage, invitation handling, moderation tools, push notifications, and server-enforced visibility permissions.

## Privacy Principles

Constella is designed around intentionally limited visibility.

- Relationship notes should identify their author.
- A person should edit only their own relationship perspective.
- Calendar access should always be optional and permission-based.
- Imported events should identify their external source.
- Precise location data should never be inferred or exposed without explicit consent.
- Anonymous posting should conceal identity from members while retaining accountable moderation records.
- Circle membership and relationship visibility must be enforced by the backend, not only hidden in the interface.

## Future Development

Potential next stages include:

1. Sign in with Apple and persistent user accounts.
2. CloudKit or a dedicated backend for synchronized circles and posts.
3. Invitation links and contact-assisted discovery.
4. EventKit synchronization for approved Apple calendars.
5. Google Calendar OAuth synchronization.
6. Eventbrite OAuth and webhook support.
7. Push notifications and configurable circle digests.
8. Photo attachments and shared event albums.
9. Moderation, blocking, reporting, and retention controls.
10. macOS and watchOS companion experiences.

## Status

Constella is currently a functional product prototype. Its interface, core navigation, social-atlas model, bulletins, circles, event import flow, shared calendar, relationship perspectives, and account settings are implemented with demonstration data. External account services and production synchronization are represented by integration-ready entry points but still require provider credentials, permissions, and backend infrastructure.

---

Created by **Enzo Ricardo Cortés**  
© 2026 Enzo Ricardo Cortés. All rights reserved.
