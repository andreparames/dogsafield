# **Dogs Afield — User Flows & System Architecture**

This document maps out the core user journeys within Dogs Afield, focused entirely on real-world actions, safety, and community building. By design, the application strips away pre-event messaging to eliminate digital ghosting, ensuring all connections are forged in person.

## **1\. Onboarding & Account Creation**

The onboarding flow introduces the brand ethos, captures critical location data, and prompts the user to build an expressive profile for their dog that serves as a real-world conversation starter. To ensure a pleasant, legible experience across the community, every user must upload a joint photo containing both the owner and the dog before their account becomes active.  
*\[Welcome Screen\] ➔ \[Location Access\] ➔ \[Dual-Subject Photo Upload\] ➔ \[Automated AI Verification Check\] ➔ \[Pup Profile Creation\] ➔ \[Safety Boundaries\] ➔ \[The Field Map\]*

### **Flow Steps**

1. **The Welcome:** The user is greeted with the core philosophy: "Because great walks are better with great company." Authentication occurs via third-party secure sign-on.  
2. **Location Permissions:** The app requests background/foreground geolocation permissions. This is required to populate the local map with active events and check-ins.  
3. **Dual-Subject Photo Upload:** The user is required to upload or capture a single photo containing both themselves (the human owner) and their dog. This image acts as the primary visual identifier for real-world meetups.  
4. **Automated AI Verification Check:**  
   * Upon upload, a computer vision model scans the image to detect the concurrent presence of exactly one human face and at least one dog.  
   * **Path A (Success):** Both subjects are successfully detected. The user is instantly fast-tracked to the next stage of profile creation.  
   * **Path B (Fallback):** The model fails to verify both subjects (e.g., poor lighting, missing human face, or dog-only photo). The profile is flagged and routed to a Manual Profile Verification Queue. The user is permitted to complete onboarding but is placed in a "Pending Verification" state, restricting them from publishing events until a human moderator reviews the photo.  
   * **Note on purpose:** This check exists purely as a quality-of-life filter — it ensures profile photos are legible and usable for other members browsing attendee lists, so people can recognize each other in person. It is not an identity verification or anti-fraud mechanism; that role is handled entirely by the Presence Verification Loop (Section 5).  
5. **Pup Profile Creation:** The user inputs basic statistics (Name, Age, Breed) and selects a Social Vibe tag (e.g., Lounge Lizard, Zoomie King, Social Learner) to set behavioral expectations for other owners.  
6. **Icebreaker Prompts:** Instead of a generic biography text field, the user selects from structured story prompts (e.g., "My dog's greatest criminal achievement to date..."). The user must answer at least one prompt to complete sign-up.  
7. **Safety Boundaries:** The user sets explicit toggles regarding food interaction, specifically a Treat Policy ("Okay to share" vs. "Ask before feeding"), protecting food-motivated or allergic dogs.

## **2\. Platform Access Model & "Founding Pack" Status**

The monetization structure is built to encourage platform content growth (supply) while gating premium consumption (demand) via a consumption-based lifetime trial, unless overridden by local launch status.

### **A. Core Access Rules**

* **Hosting Events (Supply):** Creating and publishing an event to "The Field" is an unrestricted, globally free feature for all users to naturally scale community activity.  
* **Joining Events (Demand):** All standard accounts are given a Lifetime Trial of Three (3) Free RSVPs. Upon attempting to join a fourth (4th) gathering, the user must upgrade to a premium subscription to register.

### **B. The "Founding Pack" Exception**

* **Eligibility Window:** Automatically triggered for any user who registers within the coordinates of a newly launched city during its initial 60-day launch window.  
* **The Activity Lock:** To officially convert their account to a "Founding Pack" tier, the user must successfully cross the Presence Verification Loop at least three (3) times by attending 3 real-world gatherings within their first 60 days.  
* **The Geographic Waiver:** Once unlocked, a permanent "Founding Pack" badge is affixed to their profile. When a founder attempts to join a local gathering, the billing engine checks the physical location of the event. If the event is located within their founding city's geographic boundaries, the lifetime joining cap is completely waived ($0.00 RSVP). If they attempt to join an event outside their founding region, standard trial caps or active subscription checks apply. No continuous background user tracking is required.

## **3\. Discovering & Joining a Gathering**

Users browse the physical map to find activities suited to their schedule and their dog's temperament. Because text chatting is disabled before a meetup, joining is low-friction and action-oriented.  
*\[Browse Map/List\] ➔ \[View Gathering Details & Attendee Profiles\] ➔ \[RSVP 'Join Pack'\]*

### **Flow Steps**

1. **Exploration:** The user enters the primary hub ("The Field") and views active and upcoming events nearby, filtered by type: Pack Walks, Dog Picnics, or Field Games.  
2. **Gathering Inspection:** Selecting an event displays the operational details set by the host: date, precise park location, amenity tags (e.g., Heavy Shade, Fenced Area), and the What to Bring Checklist.  
3. **Evaluating the Pack:** The user can tap into the RSVP list to view the profiles of dogs already attending. They can read the icebreaker stories of the other owners to prepare for in-person conversations.  
4. **Commitment:** The user taps "Join Pack." The system evaluates their trial/founder status against the event's location before confirming the reservation and adding their dog to the public attendee list.

## **4\. Hosting a Gathering**

Hosting is structured around templates to take the pressure off the human organizer. The app enforces parameters that keep events safe, organized, and predictable. Paid local professional trackers and "Field Guides" utilize these exact flows to schedule the platform's initial seed events.  
*\[Select Template\] ➔ \[Define Location & Time\] ➔ \[Set Pack Capacity & Rules\] ➔ \[Publish to Field\]*

### **Flow Steps**

1. **Template Selection:** The host chooses the style of event they wish to coordinate:  
   * **Dog Picnic:** Stationary, relaxed, focused on blankets and slow socializing.  
   * **Pack Walk:** Linear movement along a designated trail or neighborhood route.  
   * **Field Games:** Structured activities using pre-set playground rules (e.g., Recall Roulette).  
2. **Logistics Entry:** The host selects a park or trail from the map interface and assigns a date and time window. During city launches, choices are funneled primarily into designated "Hub Parks."  
3. **Event Parameters:** The host sets limits to ensure safety:  
   * **Pack Capacity:** Cap the number of maximum RSVPs to prevent chaotic overcrowding.  
   * **What to Bring Checklist:** Quick-select items (e.g., Bring human lunch, Bring long line leash).  
4. **Publication:** The event is published instantly to the map for all local users within a defined radius.

## **5\. The Presence Verification & Connection Loop**

This is the core security and social engine of the app. Direct communication channels are entirely locked until the system verifies both parties physically shared the field together.  
*\[Event Concludes\] ➔ \[Attendance Roll Call Prompt\] ➔ \[Mutual Verification Match\] ➔ \[Pack Status Unlocked\]*

### **Flow Steps**

1. **Post-Event Trigger:** Two hours after a gathering begins, the app triggers a push notification to all users who submitted an RSVP.  
2. **The Attendance Roll Call:** Upon opening the app, every attendee — not just the host — is presented with a list of the dogs who marked themselves as attending. Each user individually checks the boxes next to the dogs they personally saw and interacted with at the park. This is a peer-driven process across the whole group, not a single organizer's call.  
3. **Cross-Reference Engine:** The system parses the submissions. A connection is authorized if:  
   * User A and User B mutually check each other's dogs.  
   * OR, the designated Event Host (or hired Field Guide) explicitly marks both users as present (fallback path, used when one party doesn't submit a roll call).  
4. **Unlocking the Pack:** Once verified, both users are marked as "Packmates." This status permanently unlocks a direct messaging channel between the two owners, allowing them to coordinate private playdates, share photos, and view each other's direct contact details moving forward.

### **Future Improvements (Not in Scope for V1)**

* **Anti-collusion hardening for mutual confirmation:** Since most connections will be authorized purely via pairwise mutual check-off between two attendees, this is the single highest-leverage abuse vector for the app (two accounts that never actually met could confirm each other and unlock DMs/contact info). Candidate mitigations to evaluate post-launch:  
  * Group cross-check: flag pairs who mutually confirm each other but whom no other attendee at the same event also confirms, for lightweight review.  
  * Pattern/rate limiting: flag accounts that repeatedly form mutual confirmations with the same partner across many events without ever overlapping with the rest of that event's pack.  
  * Optional one-time location ping at roll-call open, to confirm the device was near the event location during the event window, without introducing continuous background tracking.  
* **Dispute/appeals flow:** no process is currently defined for a user contesting a roll call outcome (falsely marked present/absent). Worth scoping before wider rollout.  
* **No-show handling:** clarify whether an RSVP that results in a no-show consumes one of the Lifetime Trial's 3 free RSVPs, and whether repeated no-shows carry any penalty.

## **6\. Blocking & Reporting**

Once two users become Packmates and messaging unlocks, either party can invoke escalating levels of protection against the other. In the examples below, the blocking user is protecting themselves from another user, "Bob."  
**Tier 1 — Block**

* Immediately and silently cuts the DM channel in both directions. Bob is not notified.  
* This also revokes "Packmate" status between the two users: every mention of the blocking user disappears from Bob's app entirely (profile, past event attendee lists, contact details, everything), as if the two had never connected.

**Tier 2 — Block & Hide (includes Tier 1\)**

* Any event the blocking user hosts is hidden from Bob's map/browse view, so he can't discover or newly RSVP into it.  
* If the blocking user has already RSVP'd to an event, Bob can still discover and join that same event (hiding a host's events doesn't extend to events merely attended by the blocking user) — but Bob cannot see that the blocking user is attending. The blocking user is omitted from the attendee list and RSVP list shown to Bob, in both directions.  
* If the blocking user has already RSVP'd to an event and Bob subsequently joins the same event, the blocking user gets a warning notification (e.g., "Bob, who you've blocked, has joined an event you're attending"). This is purely informational — the user can cancel their RSVP as they normally would, but the block confers no special exemption (e.g., no refund of trial credit) beyond that.

**Tier 3 — Block, Hide & Report (includes Tier 2\)**

* Same as Tier 2, plus a free-text message routed to a Trust & Safety / admin queue describing the concern.  
* Filing a report has no automatic account-level effect on Bob — no hold, restriction, or flag beyond the blocking/hiding already in place from Tier 2\. Any consequence for Bob depends entirely on manual admin review.  
* Admin response target is "as soon as possible" — a soft target for v1, worth converting into a concrete SLA once real report volume is available to calibrate against.