///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$onboarding$en onboarding = Translations$onboarding$en._(_root);
	late final Translations$fieldMap$en fieldMap = Translations$fieldMap$en._(_root);
	late final Translations$gathering$en gathering = Translations$gathering$en._(_root);
	late final Translations$feedback$en feedback = Translations$feedback$en._(_root);
	late final Translations$vibe$en vibe = Translations$vibe$en._(_root);
	late final Translations$event$en event = Translations$event$en._(_root);
	late final Translations$treatPolicy$en treatPolicy = Translations$treatPolicy$en._(_root);
	late final Translations$common$en common = Translations$common$en._(_root);
	late final Translations$hosting$en hosting = Translations$hosting$en._(_root);
	late final Translations$account$en account = Translations$account$en._(_root);
	late final Translations$connections$en connections = Translations$connections$en._(_root);
	late final Translations$info$en info = Translations$info$en._(_root);
	late final Translations$messaging$en messaging = Translations$messaging$en._(_root);
	late final Translations$errors$en errors = Translations$errors$en._(_root);
}

// Path: onboarding
class Translations$onboarding$en {
	Translations$onboarding$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dogs Afield'
	String get appTitle => 'Dogs Afield';

	/// en: 'Because great walks are better with great company.'
	String get tagline => 'Because great walks are better with great company.';

	/// en: 'Continue with Google'
	String get continueWithGoogle => 'Continue with Google';

	/// en: 'Continue with Apple'
	String get continueWithApple => 'Continue with Apple';

	/// en: 'Google sign-in failed: $error'
	String googleSignInFailed({required Object error}) => 'Google sign-in failed: ${error}';

	/// en: 'Apple sign-in failed: $error'
	String appleSignInFailed({required Object error}) => 'Apple sign-in failed: ${error}';

	late final Translations$onboarding$photoUpload$en photoUpload = Translations$onboarding$photoUpload$en._(_root);
	late final Translations$onboarding$profileForm$en profileForm = Translations$onboarding$profileForm$en._(_root);
	late final Translations$onboarding$icebreaker$en icebreaker = Translations$onboarding$icebreaker$en._(_root);
	late final Translations$onboarding$safety$en safety = Translations$onboarding$safety$en._(_root);
}

// Path: fieldMap
class Translations$fieldMap$en {
	Translations$fieldMap$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create Event'
	String get createEvent => 'Create Event';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Nearby'
	String get nearby => 'Nearby';

	/// en: 'My Packs'
	String get myPacks => 'My Packs';

	/// en: 'Feedback'
	String get feedback => 'Feedback';

	/// en: 'Unable to get your location'
	String get unableToGetLocation => 'Unable to get your location';

	/// en: 'Please grant location permission to see the map.'
	String get grantPermission => 'Please grant location permission to see the map.';

	/// en: 'Location permission permanently denied. Open settings to enable.'
	String get permissionDeniedForever => 'Location permission permanently denied. Open settings to enable.';

	/// en: 'Location permission is required to show the map.'
	String get permissionDenied => 'Location permission is required to show the map.';

	/// en: 'Location services are disabled. Enable them in settings.'
	String get locationDisabled => 'Location services are disabled. Enable them in settings.';

	/// en: 'Failed to load events: $error'
	String failedToLoadEvents({required Object error}) => 'Failed to load events: ${error}';

	/// en: 'View Details'
	String get viewDetails => 'View Details';

	/// en: 'Leave Pack'
	String get leavePack => 'Leave Pack';

	/// en: 'Leave Pack — coming soon'
	String get leavePackComingSoon => 'Leave Pack — coming soon';
}

// Path: gathering
class Translations$gathering$en {
	Translations$gathering$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Gathering Details'
	String get title => 'Gathering Details';

	/// en: 'Failed to load event'
	String get failedToLoad => 'Failed to load event';

	/// en: 'Host'
	String get host => 'Host';

	/// en: 'Amenities'
	String get amenities => 'Amenities';

	/// en: 'What to Bring'
	String get whatToBring => 'What to Bring';

	/// en: 'Attendance'
	String get attendance => 'Attendance';

	/// en: '$count / $max attending'
	String attending({required Object count, required Object max}) => '${count} / ${max} attending';

	/// en: '(you)'
	String get you => '(you)';

	/// en: 'User blocked'
	String get userBlocked => 'User blocked';

	/// en: 'Edit Event'
	String get editEvent => 'Edit Event';

	/// en: 'Leave Pack'
	String get leavePack => 'Leave Pack';

	/// en: 'Join Pack'
	String get joinPack => 'Join Pack';

	/// en: 'Could not load pack status'
	String get couldNotLoadPackStatus => 'Could not load pack status';
}

// Path: feedback
class Translations$feedback$en {
	Translations$feedback$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Send Feedback'
	String get title => 'Send Feedback';

	/// en: 'Share your thoughts, suggestions, or report an issue...'
	String get hint => 'Share your thoughts, suggestions, or report an issue...';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Send'
	String get send => 'Send';

	/// en: 'Thanks for your feedback!'
	String get success => 'Thanks for your feedback!';

	/// en: 'Failed to send feedback. Please try again.'
	String get failed => 'Failed to send feedback. Please try again.';
}

// Path: vibe
class Translations$vibe$en {
	Translations$vibe$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lounge Lizard'
	String get loungeLizard => 'Lounge Lizard';

	/// en: 'Zoomie King'
	String get zoomieKing => 'Zoomie King';

	/// en: 'Social Learner'
	String get socialLearner => 'Social Learner';

	/// en: 'Lounge Lizard — calm and chill'
	String get loungeLizardFull => 'Lounge Lizard — calm and chill';

	/// en: 'Zoomie King — high energy'
	String get zoomieKingFull => 'Zoomie King — high energy';

	/// en: 'Social Learner — still learning the ropes'
	String get socialLearnerFull => 'Social Learner — still learning the ropes';
}

// Path: event
class Translations$event$en {
	Translations$event$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$event$type$en type = Translations$event$type$en._(_root);
}

// Path: treatPolicy
class Translations$treatPolicy$en {
	Translations$treatPolicy$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Okay to share — friendly dogs welcome'
	String get okToShare => 'Okay to share — friendly dogs welcome';

	/// en: 'Ask before feeding — allergies or diet'
	String get askBeforeFeeding => 'Ask before feeding — allergies or diet';

	/// en: 'Okay to share treats with my dog'
	String get okToShareDetail => 'Okay to share treats with my dog';

	/// en: 'Please ask before feeding my dog'
	String get askBeforeFeedingDetail => 'Please ask before feeding my dog';
}

// Path: common
class Translations$common$en {
	Translations$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Unknown'
	String get unknown => 'Unknown';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Keep'
	String get keep => 'Keep';

	/// en: 'Remove'
	String get remove => 'Remove';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Submit'
	String get submit => 'Submit';

	/// en: 'Unblock'
	String get unblock => 'Unblock';

	/// en: 'Upgrade'
	String get upgrade => 'Upgrade';

	/// en: 'Subscribe'
	String get subscribe => 'Subscribe';
}

// Path: hosting
class Translations$hosting$en {
	Translations$hosting$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$hosting$create$en create = Translations$hosting$create$en._(_root);
	late final Translations$hosting$locationPicker$en locationPicker = Translations$hosting$locationPicker$en._(_root);
	late final Translations$hosting$myEvents$en myEvents = Translations$hosting$myEvents$en._(_root);
	late final Translations$hosting$manageAttendees$en manageAttendees = Translations$hosting$manageAttendees$en._(_root);
	late final Translations$hosting$responsibility$en responsibility = Translations$hosting$responsibility$en._(_root);
}

// Path: account
class Translations$account$en {
	Translations$account$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Account'
	String get title => 'Account';

	/// en: 'Could not load account'
	String get couldNotLoad => 'Could not load account';

	/// en: 'My Events'
	String get myEvents => 'My Events';

	/// en: 'Blocked Users'
	String get blockedUsers => 'Blocked Users';

	/// en: 'Trial RSVPs'
	String get trialRsvps => 'Trial RSVPs';

	/// en: 'About Trial RSVPs'
	String get aboutTrialTitle => 'About Trial RSVPs';

	/// en: 'You can use up to $max trial RSVPs to attend events without a Founding Pack subscription. Each RSVP gives you full access to the event. After your trial runs out, upgrade to keep joining the pack.'
	String aboutTrialBody({required Object max}) => 'You can use up to ${max} trial RSVPs to attend events without a Founding Pack subscription. Each RSVP gives you full access to the event. After your trial runs out, upgrade to keep joining the pack.';

	/// en: 'You have $remaining of $max free RSVPs remaining.'
	String rsvpsRemaining({required Object remaining, required Object max}) => 'You have ${remaining} of ${max} free RSVPs remaining.';

	/// en: 'Used'
	String get used => 'Used';

	/// en: 'Remaining'
	String get remaining => 'Remaining';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Upgrade to keep joining'
	String get upgradeToKeepJoining => 'Upgrade to keep joining';

	/// en: 'You are a verified Founding Pack member. Enjoy waived fees for events in your founding city.'
	String get foundingDescription => 'You are a verified Founding Pack member. Enjoy waived fees for events in your founding city.';

	/// en: 'Safety Boundaries'
	String get safetyBoundaries => 'Safety Boundaries';

	/// en: 'Danger Zone'
	String get dangerZone => 'Danger Zone';

	/// en: 'Suspend Account'
	String get suspendAccount => 'Suspend Account';

	/// en: 'Delete Account'
	String get deleteAccount => 'Delete Account';

	/// en: 'Suspend Account'
	String get suspendTitle => 'Suspend Account';

	/// en: 'Your profile will be hidden from other users. You can reactivate at any time by signing in.'
	String get suspendBody => 'Your profile will be hidden from other users. You can reactivate at any time by signing in.';

	/// en: 'Delete Account'
	String get deleteTitle => 'Delete Account';

	/// en: 'This permanently removes all your data. This action cannot be undone.'
	String get deleteBody => 'This permanently removes all your data. This action cannot be undone.';

	/// en: 'Type DELETE to confirm'
	String get deleteConfirmHint => 'Type DELETE to confirm';

	/// en: 'Incorrect. Please type DELETE to confirm.'
	String get deleteConfirmError => 'Incorrect. Please type DELETE to confirm.';

	/// en: 'Delete Forever'
	String get deleteForever => 'Delete Forever';

	/// en: 'Sign Out'
	String get signOut => 'Sign Out';

	late final Translations$account$upgrade$en upgrade = Translations$account$upgrade$en._(_root);
	late final Translations$account$suspend$en suspend = Translations$account$suspend$en._(_root);
	late final Translations$account$rsvpLimit$en rsvpLimit = Translations$account$rsvpLimit$en._(_root);
	late final Translations$account$foundingPack$en foundingPack = Translations$account$foundingPack$en._(_root);
}

// Path: connections
class Translations$connections$en {
	Translations$connections$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$connections$report$en report = Translations$connections$report$en._(_root);
	late final Translations$connections$blocked$en blocked = Translations$connections$blocked$en._(_root);
}

// Path: info
class Translations$info$en {
	Translations$info$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$info$fieldIntro$en fieldIntro = Translations$info$fieldIntro$en._(_root);
}

// Path: messaging
class Translations$messaging$en {
	Translations$messaging$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Messages'
	String get title => 'Messages';

	/// en: 'No conversations yet'
	String get empty => 'No conversations yet';

	/// en: 'Chat with your packmates after you've both confirmed meeting at an event.'
	String get emptyHint => 'Chat with your packmates after you\'ve both confirmed meeting at an event.';

	/// en: 'No messages yet'
	String get noMessages => 'No messages yet';

	/// en: 'Send a message to start the conversation!'
	String get noMessagesYet => 'Send a message to start the conversation!';

	/// en: 'Type a message...'
	String get typeMessage => 'Type a message...';

	/// en: 'Could not load messages'
	String get failedToLoad => 'Could not load messages';

	/// en: 'Failed to send message. Please try again.'
	String get failedToSend => 'Failed to send message. Please try again.';

	/// en: 'You can only message your packmates.'
	String get cannotMessage => 'You can only message your packmates.';
}

// Path: errors
class Translations$errors$en {
	Translations$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to create event. Please try again.'
	String get failedToCreateEvent => 'Failed to create event. Please try again.';

	/// en: 'Failed to update event. Please try again.'
	String get failedToUpdateEvent => 'Failed to update event. Please try again.';

	/// en: 'Failed to cancel event. Please try again.'
	String get failedToCancelEvent => 'Failed to cancel event. Please try again.';

	/// en: 'Failed to suspend account. Please try again.'
	String get failedToSuspend => 'Failed to suspend account. Please try again.';

	/// en: 'Failed to delete account. Please try again.'
	String get failedToDelete => 'Failed to delete account. Please try again.';

	/// en: 'Failed to block user. Please try again.'
	String get failedToBlock => 'Failed to block user. Please try again.';

	/// en: 'Failed to block and hide user. Please try again.'
	String get failedToBlockAndHide => 'Failed to block and hide user. Please try again.';

	/// en: 'Failed to report user. Please try again.'
	String get failedToReport => 'Failed to report user. Please try again.';

	/// en: 'Failed to unblock user. Please try again.'
	String get failedToUnblock => 'Failed to unblock user. Please try again.';

	/// en: 'Failed to RSVP: $error'
	String failedToRsvp({required Object error}) => 'Failed to RSVP: ${error}';

	/// en: 'Failed to cancel RSVP: $error'
	String failedToCancelRsvp({required Object error}) => 'Failed to cancel RSVP: ${error}';
}

// Path: onboarding.photoUpload
class Translations$onboarding$photoUpload$en {
	Translations$onboarding$photoUpload$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Verification Photo'
	String get title => 'Verification Photo';

	/// en: 'Upload a photo of you and your dog together'
	String get subtitle => 'Upload a photo of you and your dog together';

	/// en: 'This helps others recognize you at the park.'
	String get hint => 'This helps others recognize you at the park.';

	/// en: 'Take Photo'
	String get takePhoto => 'Take Photo';

	/// en: 'Choose from Gallery'
	String get chooseGallery => 'Choose from Gallery';
}

// Path: onboarding.profileForm
class Translations$onboarding$profileForm$en {
	Translations$onboarding$profileForm$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pup Profile'
	String get title => 'Pup Profile';

	/// en: 'Dog's Name'
	String get dogName => 'Dog\'s Name';

	/// en: 'Age'
	String get age => 'Age';

	/// en: 'Breed'
	String get breed => 'Breed';

	/// en: 'Social Vibe'
	String get socialVibe => 'Social Vibe';

	/// en: 'Please enter your dog's name'
	String get nameRequired => 'Please enter your dog\'s name';

	/// en: 'Profile not ready. Please try again.'
	String get profileNotReady => 'Profile not ready. Please try again.';
}

// Path: onboarding.icebreaker
class Translations$onboarding$icebreaker$en {
	Translations$onboarding$icebreaker$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Icebreaker'
	String get title => 'Icebreaker';

	/// en: 'Pick a prompt and share a story'
	String get subtitle => 'Pick a prompt and share a story';

	/// en: 'This helps other owners get to know you at the park.'
	String get hint => 'This helps other owners get to know you at the park.';

	late final Translations$onboarding$icebreaker$prompts$en prompts = Translations$onboarding$icebreaker$prompts$en._(_root);

	/// en: 'Your story'
	String get yourStory => 'Your story';

	/// en: 'Please select a prompt'
	String get promptRequired => 'Please select a prompt';

	/// en: 'Please share your story'
	String get storyRequired => 'Please share your story';
}

// Path: onboarding.safety
class Translations$onboarding$safety$en {
	Translations$onboarding$safety$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Safety Boundaries'
	String get title => 'Safety Boundaries';

	/// en: 'Treat Policy'
	String get treatPolicy => 'Treat Policy';

	/// en: 'Let other owners know how you handle treats.'
	String get treatPolicySubtitle => 'Let other owners know how you handle treats.';

	/// en: 'Okay to share — friendly dogs welcome'
	String get okToShare => 'Okay to share — friendly dogs welcome';

	/// en: 'Ask before feeding — allergies or diet'
	String get askBeforeFeeding => 'Ask before feeding — allergies or diet';

	/// en: 'Complete Profile'
	String get completeProfile => 'Complete Profile';

	/// en: 'Please select a treat policy'
	String get policyRequired => 'Please select a treat policy';

	/// en: 'Something went wrong. Please try again.'
	String get error => 'Something went wrong. Please try again.';
}

// Path: event.type
class Translations$event$type$en {
	Translations$event$type$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pack Walk'
	String get packWalk => 'Pack Walk';

	/// en: 'Dog Picnic'
	String get dogPicnic => 'Dog Picnic';

	/// en: 'Field Games'
	String get fieldGames => 'Field Games';
}

// Path: hosting.create
class Translations$hosting$create$en {
	Translations$hosting$create$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create Event'
	String get titleCreate => 'Create Event';

	/// en: 'Edit Event'
	String get titleEdit => 'Edit Event';

	/// en: 'Event Type'
	String get eventType => 'Event Type';

	/// en: 'Dog Picnic'
	String get dogPicnic => 'Dog Picnic';

	/// en: 'Pack Walk'
	String get packWalk => 'Pack Walk';

	/// en: 'Field Games'
	String get fieldGames => 'Field Games';

	/// en: 'Title'
	String get title => 'Title';

	/// en: 'Location'
	String get location => 'Location';

	/// en: 'Description (optional)'
	String get description => 'Description (optional)';

	/// en: 'Date & Time'
	String get dateTime => 'Date & Time';

	/// en: 'Max Attendees'
	String get maxAttendees => 'Max Attendees';

	/// en: 'What to Bring'
	String get whatToBring => 'What to Bring';

	/// en: 'Publish to Field'
	String get publish => 'Publish to Field';

	/// en: 'Save Changes'
	String get saveChanges => 'Save Changes';

	/// en: 'Enter a title'
	String get enterTitle => 'Enter a title';

	/// en: 'Tap to select on map'
	String get tapToSelect => 'Tap to select on map';

	/// en: 'Please select an event type.'
	String get selectEventType => 'Please select an event type.';

	/// en: 'Please select a location on the map.'
	String get selectLocation => 'Please select a location on the map.';

	/// en: 'Selected Location'
	String get selectedLocation => 'Selected Location';

	List<String> get bringOptions => [
		'Long line leash',
		'Human lunch',
		'Dog treats',
		'Water bowl',
		'Poop bags',
		'Towel',
		'Frisbee',
		'Tennis balls',
	];

	/// en: 'Event created!'
	String get eventCreated => 'Event created!';

	/// en: 'Event updated!'
	String get eventUpdated => 'Event updated!';
}

// Path: hosting.locationPicker
class Translations$hosting$locationPicker$en {
	Translations$hosting$locationPicker$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select Location'
	String get title => 'Select Location';

	/// en: 'Location name (optional)'
	String get locationName => 'Location name (optional)';

	/// en: 'Tap on the map to select a location'
	String get tapHint => 'Tap on the map to select a location';

	/// en: 'Confirm Location'
	String get confirm => 'Confirm Location';
}

// Path: hosting.myEvents
class Translations$hosting$myEvents$en {
	Translations$hosting$myEvents$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My Events'
	String get title => 'My Events';

	/// en: 'No events yet'
	String get noEvents => 'No events yet';

	/// en: 'Tap the + on the map to create one.'
	String get createHint => 'Tap the + on the map to create one.';

	/// en: 'Active Events'
	String get activeEvents => 'Active Events';

	/// en: 'Cancelled'
	String get cancelled => 'Cancelled';

	/// en: 'Could not load events'
	String get couldNotLoad => 'Could not load events';

	/// en: 'Attendees'
	String get attendees => 'Attendees';

	/// en: 'Can't edit while offline'
	String get cantEditOffline => 'Can\'t edit while offline';

	/// en: 'Cancel Event'
	String get cancelEventTitle => 'Cancel Event';

	/// en: 'This will mark the event as cancelled. Attendees will no longer see it on the map.'
	String get cancelEventBody => 'This will mark the event as cancelled. Attendees will no longer see it on the map.';

	/// en: 'Cancel Event'
	String get cancelEventAction => 'Cancel Event';
}

// Path: hosting.manageAttendees
class Translations$hosting$manageAttendees$en {
	Translations$hosting$manageAttendees$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Attendees: $title'
	String title({required Object title}) => 'Attendees: ${title}';

	/// en: 'Remove Attendee'
	String get removeTitle => 'Remove Attendee';

	/// en: 'This will remove them from the event. They can re-RSVP if the event is open.'
	String get removeBody => 'This will remove them from the event. They can re-RSVP if the event is open.';

	/// en: 'Attendee removed.'
	String get removed => 'Attendee removed.';

	/// en: 'Failed to remove attendee.'
	String get failedRemove => 'Failed to remove attendee.';

	/// en: 'Could not load attendees'
	String get couldNotLoad => 'Could not load attendees';

	/// en: 'No attendees yet'
	String get noAttendees => 'No attendees yet';

	/// en: '$count RSVP'd'
	String rsvpCount({required Object count}) => '${count} RSVP\'d';

	/// en: 'Remove'
	String get removeTooltip => 'Remove';
}

// Path: hosting.responsibility
class Translations$hosting$responsibility$en {
	Translations$hosting$responsibility$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Before You Host'
	String get title => 'Before You Host';

	/// en: 'Hosting Responsibility'
	String get heading => 'Hosting Responsibility';

	/// en: 'Thank you for stepping up to host! A few things to keep in mind:'
	String get intro => 'Thank you for stepping up to host! A few things to keep in mind:';

	List<dynamic> get tips => [
		Translations$hosting$responsibility$tips$0$en._(_root),
		Translations$hosting$responsibility$tips$1$en._(_root),
		Translations$hosting$responsibility$tips$2$en._(_root),
		Translations$hosting$responsibility$tips$3$en._(_root),
		Translations$hosting$responsibility$tips$4$en._(_root),
	];

	/// en: 'I Understand'
	String get iUnderstand => 'I Understand';
}

// Path: account.upgrade
class Translations$account$upgrade$en {
	Translations$account$upgrade$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Upgrade'
	String get title => 'Upgrade';

	/// en: 'Upgrade to Premium'
	String get heading => 'Upgrade to Premium';

	/// en: 'Unlimited RSVPs, early access to events, and exclusive perks.'
	String get description => 'Unlimited RSVPs, early access to events, and exclusive perks.';

	/// en: 'Upgrade coming soon'
	String get comingSoon => 'Upgrade coming soon';
}

// Path: account.suspend
class Translations$account$suspend$en {
	Translations$account$suspend$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Account Suspended'
	String get title => 'Account Suspended';

	/// en: 'Your account is suspended'
	String get heading => 'Your account is suspended';

	/// en: 'Your profile is hidden from other users. You can reactivate your account at any time.'
	String get body => 'Your profile is hidden from other users. You can reactivate your account at any time.';

	/// en: 'Account reactivated'
	String get reactivated => 'Account reactivated';

	/// en: 'Failed to reactivate: $error'
	String failedReactivation({required Object error}) => 'Failed to reactivate: ${error}';

	/// en: 'Reactivate Account'
	String get reactivate => 'Reactivate Account';
}

// Path: account.rsvpLimit
class Translations$account$rsvpLimit$en {
	Translations$account$rsvpLimit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You have $remaining free RSVPs remaining.'
	String remaining({required Object remaining}) => 'You have ${remaining} free RSVPs remaining.';

	/// en: 'You have used all your free RSVPs. Upgrade to keep joining events.'
	String get exhausted => 'You have used all your free RSVPs. Upgrade to keep joining events.';
}

// Path: account.foundingPack
class Translations$account$foundingPack$en {
	Translations$account$foundingPack$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Founding Pack'
	String get badge => 'Founding Pack';
}

// Path: connections.report
class Translations$connections$report$en {
	Translations$connections$report$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Report User'
	String get title => 'Report User';

	/// en: 'Tell us what happened...'
	String get hint => 'Tell us what happened...';

	/// en: 'Submit'
	String get submit => 'Submit';
}

// Path: connections.blocked
class Translations$connections$blocked$en {
	Translations$connections$blocked$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Blocked Users'
	String get title => 'Blocked Users';

	/// en: 'No blocked users'
	String get empty => 'No blocked users';

	/// en: 'Blocked'
	String get tier1 => 'Blocked';

	/// en: 'Blocked & Hidden'
	String get tier2 => 'Blocked & Hidden';

	/// en: 'Blocked, Hidden & Reported'
	String get tier3 => 'Blocked, Hidden & Reported';

	/// en: 'User unblocked'
	String get userUnblocked => 'User unblocked';

	/// en: 'Could not load blocked users'
	String get couldNotLoad => 'Could not load blocked users';
}

// Path: info.fieldIntro
class Translations$info$fieldIntro$en {
	Translations$info$fieldIntro$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome to the Field'
	String get title => 'Welcome to the Field';

	/// en: 'Explore Dog-Friendly Events'
	String get heading => 'Explore Dog-Friendly Events';

	/// en: 'The Field map shows everything happening near you. Here's how to get started:'
	String get intro => 'The Field map shows everything happening near you. Here\'s how to get started:';

	List<dynamic> get tips => [
		Translations$info$fieldIntro$tips$0$en._(_root),
		Translations$info$fieldIntro$tips$1$en._(_root),
		Translations$info$fieldIntro$tips$2$en._(_root),
		Translations$info$fieldIntro$tips$3$en._(_root),
	];

	/// en: 'Got It'
	String get gotIt => 'Got It';
}

// Path: onboarding.icebreaker.prompts
class Translations$onboarding$icebreaker$prompts$en {
	Translations$onboarding$icebreaker$prompts$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My dog's greatest criminal achievement to date...'
	String get criminalAchievement => 'My dog\'s greatest criminal achievement to date...';

	/// en: 'The weirdest thing my dog is afraid of...'
	String get weirdestFear => 'The weirdest thing my dog is afraid of...';

	/// en: 'If my dog had a job, it would be...'
	String get job => 'If my dog had a job, it would be...';

	/// en: 'My dog's favorite snack that isn't dog food...'
	String get favoriteSnack => 'My dog\'s favorite snack that isn\'t dog food...';
}

// Path: hosting.responsibility.tips.0
class Translations$hosting$responsibility$tips$0$en {
	Translations$hosting$responsibility$tips$0$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Show up on time'
	String get title => 'Show up on time';

	/// en: 'Attendees plan their day around your event. Arrive a few minutes early to get settled.'
	String get description => 'Attendees plan their day around your event. Arrive a few minutes early to get settled.';
}

// Path: hosting.responsibility.tips.1
class Translations$hosting$responsibility$tips$1$en {
	Translations$hosting$responsibility$tips$1$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Communicate changes'
	String get title => 'Communicate changes';

	/// en: 'If you need to cancel or reschedule, do it as early as possible so attendees can adjust.'
	String get description => 'If you need to cancel or reschedule, do it as early as possible so attendees can adjust.';
}

// Path: hosting.responsibility.tips.2
class Translations$hosting$responsibility$tips$2$en {
	Translations$hosting$responsibility$tips$2$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome everyone'
	String get title => 'Welcome everyone';

	/// en: 'New members may be nervous. A warm welcome goes a long way toward building the pack.'
	String get description => 'New members may be nervous. A warm welcome goes a long way toward building the pack.';
}

// Path: hosting.responsibility.tips.3
class Translations$hosting$responsibility$tips$3$en {
	Translations$hosting$responsibility$tips$3$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Safety first'
	String get title => 'Safety first';

	/// en: 'Keep an eye on all dogs. If a dog seems stressed or reactive, give them space.'
	String get description => 'Keep an eye on all dogs. If a dog seems stressed or reactive, give them space.';
}

// Path: hosting.responsibility.tips.4
class Translations$hosting$responsibility$tips$4$en {
	Translations$hosting$responsibility$tips$4$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Report issues'
	String get title => 'Report issues';

	/// en: 'Use the feedback button on the map to report any problems or concerns to the team.'
	String get description => 'Use the feedback button on the map to report any problems or concerns to the team.';
}

// Path: info.fieldIntro.tips.0
class Translations$info$fieldIntro$tips$0$en {
	Translations$info$fieldIntro$tips$0$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Browse the map'
	String get title => 'Browse the map';

	/// en: 'Green markers are casual walks, blue are playdates, orange are training sessions. Tap any marker to learn more.'
	String get description => 'Green markers are casual walks, blue are playdates, orange are training sessions. Tap any marker to learn more.';
}

// Path: info.fieldIntro.tips.1
class Translations$info$fieldIntro$tips$1$en {
	Translations$info$fieldIntro$tips$1$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'RSVP to join'
	String get title => 'RSVP to join';

	/// en: 'Tap "Join Pack" to let the host know you're coming. You'll see your RSVPs in the filter toggle above the map.'
	String get description => 'Tap "Join Pack" to let the host know you\'re coming. You\'ll see your RSVPs in the filter toggle above the map.';
}

// Path: info.fieldIntro.tips.2
class Translations$info$fieldIntro$tips$2$en {
	Translations$info$fieldIntro$tips$2$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Host your own'
	String get title => 'Host your own';

	/// en: 'Tap the + button to create a new event. Be sure to read the hosting tips first!'
	String get description => 'Tap the + button to create a new event. Be sure to read the hosting tips first!';
}

// Path: info.fieldIntro.tips.3
class Translations$info$fieldIntro$tips$3$en {
	Translations$info$fieldIntro$tips$3$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Send feedback'
	String get title => 'Send feedback';

	/// en: 'Found a bug or have a suggestion? Tap the chat bubble to share your thoughts with the team.'
	String get description => 'Found a bug or have a suggestion? Tap the chat bubble to share your thoughts with the team.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'onboarding.appTitle' => 'Dogs Afield',
			'onboarding.tagline' => 'Because great walks are better with great company.',
			'onboarding.continueWithGoogle' => 'Continue with Google',
			'onboarding.continueWithApple' => 'Continue with Apple',
			'onboarding.googleSignInFailed' => ({required Object error}) => 'Google sign-in failed: ${error}',
			'onboarding.appleSignInFailed' => ({required Object error}) => 'Apple sign-in failed: ${error}',
			'onboarding.photoUpload.title' => 'Verification Photo',
			'onboarding.photoUpload.subtitle' => 'Upload a photo of you and your dog together',
			'onboarding.photoUpload.hint' => 'This helps others recognize you at the park.',
			'onboarding.photoUpload.takePhoto' => 'Take Photo',
			'onboarding.photoUpload.chooseGallery' => 'Choose from Gallery',
			'onboarding.profileForm.title' => 'Pup Profile',
			'onboarding.profileForm.dogName' => 'Dog\'s Name',
			'onboarding.profileForm.age' => 'Age',
			'onboarding.profileForm.breed' => 'Breed',
			'onboarding.profileForm.socialVibe' => 'Social Vibe',
			'onboarding.profileForm.nameRequired' => 'Please enter your dog\'s name',
			'onboarding.profileForm.profileNotReady' => 'Profile not ready. Please try again.',
			'onboarding.icebreaker.title' => 'Icebreaker',
			'onboarding.icebreaker.subtitle' => 'Pick a prompt and share a story',
			'onboarding.icebreaker.hint' => 'This helps other owners get to know you at the park.',
			'onboarding.icebreaker.prompts.criminalAchievement' => 'My dog\'s greatest criminal achievement to date...',
			'onboarding.icebreaker.prompts.weirdestFear' => 'The weirdest thing my dog is afraid of...',
			'onboarding.icebreaker.prompts.job' => 'If my dog had a job, it would be...',
			'onboarding.icebreaker.prompts.favoriteSnack' => 'My dog\'s favorite snack that isn\'t dog food...',
			'onboarding.icebreaker.yourStory' => 'Your story',
			'onboarding.icebreaker.promptRequired' => 'Please select a prompt',
			'onboarding.icebreaker.storyRequired' => 'Please share your story',
			'onboarding.safety.title' => 'Safety Boundaries',
			'onboarding.safety.treatPolicy' => 'Treat Policy',
			'onboarding.safety.treatPolicySubtitle' => 'Let other owners know how you handle treats.',
			'onboarding.safety.okToShare' => 'Okay to share — friendly dogs welcome',
			'onboarding.safety.askBeforeFeeding' => 'Ask before feeding — allergies or diet',
			'onboarding.safety.completeProfile' => 'Complete Profile',
			'onboarding.safety.policyRequired' => 'Please select a treat policy',
			'onboarding.safety.error' => 'Something went wrong. Please try again.',
			'fieldMap.createEvent' => 'Create Event',
			'fieldMap.account' => 'Account',
			'fieldMap.nearby' => 'Nearby',
			'fieldMap.myPacks' => 'My Packs',
			'fieldMap.feedback' => 'Feedback',
			'fieldMap.unableToGetLocation' => 'Unable to get your location',
			'fieldMap.grantPermission' => 'Please grant location permission to see the map.',
			'fieldMap.permissionDeniedForever' => 'Location permission permanently denied. Open settings to enable.',
			'fieldMap.permissionDenied' => 'Location permission is required to show the map.',
			'fieldMap.locationDisabled' => 'Location services are disabled. Enable them in settings.',
			'fieldMap.failedToLoadEvents' => ({required Object error}) => 'Failed to load events: ${error}',
			'fieldMap.viewDetails' => 'View Details',
			'fieldMap.leavePack' => 'Leave Pack',
			'fieldMap.leavePackComingSoon' => 'Leave Pack — coming soon',
			'gathering.title' => 'Gathering Details',
			'gathering.failedToLoad' => 'Failed to load event',
			'gathering.host' => 'Host',
			'gathering.amenities' => 'Amenities',
			'gathering.whatToBring' => 'What to Bring',
			'gathering.attendance' => 'Attendance',
			'gathering.attending' => ({required Object count, required Object max}) => '${count} / ${max} attending',
			'gathering.you' => '(you)',
			'gathering.userBlocked' => 'User blocked',
			'gathering.editEvent' => 'Edit Event',
			'gathering.leavePack' => 'Leave Pack',
			'gathering.joinPack' => 'Join Pack',
			'gathering.couldNotLoadPackStatus' => 'Could not load pack status',
			'feedback.title' => 'Send Feedback',
			'feedback.hint' => 'Share your thoughts, suggestions, or report an issue...',
			'feedback.cancel' => 'Cancel',
			'feedback.send' => 'Send',
			'feedback.success' => 'Thanks for your feedback!',
			'feedback.failed' => 'Failed to send feedback. Please try again.',
			'vibe.loungeLizard' => 'Lounge Lizard',
			'vibe.zoomieKing' => 'Zoomie King',
			'vibe.socialLearner' => 'Social Learner',
			'vibe.loungeLizardFull' => 'Lounge Lizard — calm and chill',
			'vibe.zoomieKingFull' => 'Zoomie King — high energy',
			'vibe.socialLearnerFull' => 'Social Learner — still learning the ropes',
			'event.type.packWalk' => 'Pack Walk',
			'event.type.dogPicnic' => 'Dog Picnic',
			'event.type.fieldGames' => 'Field Games',
			'treatPolicy.okToShare' => 'Okay to share — friendly dogs welcome',
			'treatPolicy.askBeforeFeeding' => 'Ask before feeding — allergies or diet',
			'treatPolicy.okToShareDetail' => 'Okay to share treats with my dog',
			'treatPolicy.askBeforeFeedingDetail' => 'Please ask before feeding my dog',
			'common.retry' => 'Retry',
			'common.cancel' => 'Cancel',
			'common.unknown' => 'Unknown',
			'common.next' => 'Next',
			'common.keep' => 'Keep',
			'common.remove' => 'Remove',
			'common.edit' => 'Edit',
			'common.submit' => 'Submit',
			'common.unblock' => 'Unblock',
			'common.upgrade' => 'Upgrade',
			'common.subscribe' => 'Subscribe',
			'hosting.create.titleCreate' => 'Create Event',
			'hosting.create.titleEdit' => 'Edit Event',
			'hosting.create.eventType' => 'Event Type',
			'hosting.create.dogPicnic' => 'Dog Picnic',
			'hosting.create.packWalk' => 'Pack Walk',
			'hosting.create.fieldGames' => 'Field Games',
			'hosting.create.title' => 'Title',
			'hosting.create.location' => 'Location',
			'hosting.create.description' => 'Description (optional)',
			'hosting.create.dateTime' => 'Date & Time',
			'hosting.create.maxAttendees' => 'Max Attendees',
			'hosting.create.whatToBring' => 'What to Bring',
			'hosting.create.publish' => 'Publish to Field',
			'hosting.create.saveChanges' => 'Save Changes',
			'hosting.create.enterTitle' => 'Enter a title',
			'hosting.create.tapToSelect' => 'Tap to select on map',
			'hosting.create.selectEventType' => 'Please select an event type.',
			'hosting.create.selectLocation' => 'Please select a location on the map.',
			'hosting.create.selectedLocation' => 'Selected Location',
			'hosting.create.bringOptions.0' => 'Long line leash',
			'hosting.create.bringOptions.1' => 'Human lunch',
			'hosting.create.bringOptions.2' => 'Dog treats',
			'hosting.create.bringOptions.3' => 'Water bowl',
			'hosting.create.bringOptions.4' => 'Poop bags',
			'hosting.create.bringOptions.5' => 'Towel',
			'hosting.create.bringOptions.6' => 'Frisbee',
			'hosting.create.bringOptions.7' => 'Tennis balls',
			'hosting.create.eventCreated' => 'Event created!',
			'hosting.create.eventUpdated' => 'Event updated!',
			'hosting.locationPicker.title' => 'Select Location',
			'hosting.locationPicker.locationName' => 'Location name (optional)',
			'hosting.locationPicker.tapHint' => 'Tap on the map to select a location',
			'hosting.locationPicker.confirm' => 'Confirm Location',
			'hosting.myEvents.title' => 'My Events',
			'hosting.myEvents.noEvents' => 'No events yet',
			'hosting.myEvents.createHint' => 'Tap the + on the map to create one.',
			'hosting.myEvents.activeEvents' => 'Active Events',
			'hosting.myEvents.cancelled' => 'Cancelled',
			'hosting.myEvents.couldNotLoad' => 'Could not load events',
			'hosting.myEvents.attendees' => 'Attendees',
			'hosting.myEvents.cantEditOffline' => 'Can\'t edit while offline',
			'hosting.myEvents.cancelEventTitle' => 'Cancel Event',
			'hosting.myEvents.cancelEventBody' => 'This will mark the event as cancelled. Attendees will no longer see it on the map.',
			'hosting.myEvents.cancelEventAction' => 'Cancel Event',
			'hosting.manageAttendees.title' => ({required Object title}) => 'Attendees: ${title}',
			'hosting.manageAttendees.removeTitle' => 'Remove Attendee',
			'hosting.manageAttendees.removeBody' => 'This will remove them from the event. They can re-RSVP if the event is open.',
			'hosting.manageAttendees.removed' => 'Attendee removed.',
			'hosting.manageAttendees.failedRemove' => 'Failed to remove attendee.',
			'hosting.manageAttendees.couldNotLoad' => 'Could not load attendees',
			'hosting.manageAttendees.noAttendees' => 'No attendees yet',
			'hosting.manageAttendees.rsvpCount' => ({required Object count}) => '${count} RSVP\'d',
			'hosting.manageAttendees.removeTooltip' => 'Remove',
			'hosting.responsibility.title' => 'Before You Host',
			'hosting.responsibility.heading' => 'Hosting Responsibility',
			'hosting.responsibility.intro' => 'Thank you for stepping up to host! A few things to keep in mind:',
			'hosting.responsibility.tips.0.title' => 'Show up on time',
			'hosting.responsibility.tips.0.description' => 'Attendees plan their day around your event. Arrive a few minutes early to get settled.',
			'hosting.responsibility.tips.1.title' => 'Communicate changes',
			'hosting.responsibility.tips.1.description' => 'If you need to cancel or reschedule, do it as early as possible so attendees can adjust.',
			'hosting.responsibility.tips.2.title' => 'Welcome everyone',
			'hosting.responsibility.tips.2.description' => 'New members may be nervous. A warm welcome goes a long way toward building the pack.',
			'hosting.responsibility.tips.3.title' => 'Safety first',
			'hosting.responsibility.tips.3.description' => 'Keep an eye on all dogs. If a dog seems stressed or reactive, give them space.',
			'hosting.responsibility.tips.4.title' => 'Report issues',
			'hosting.responsibility.tips.4.description' => 'Use the feedback button on the map to report any problems or concerns to the team.',
			'hosting.responsibility.iUnderstand' => 'I Understand',
			'account.title' => 'Account',
			'account.couldNotLoad' => 'Could not load account',
			'account.myEvents' => 'My Events',
			'account.blockedUsers' => 'Blocked Users',
			'account.trialRsvps' => 'Trial RSVPs',
			'account.aboutTrialTitle' => 'About Trial RSVPs',
			'account.aboutTrialBody' => ({required Object max}) => 'You can use up to ${max} trial RSVPs to attend events without a Founding Pack subscription. Each RSVP gives you full access to the event. After your trial runs out, upgrade to keep joining the pack.',
			'account.rsvpsRemaining' => ({required Object remaining, required Object max}) => 'You have ${remaining} of ${max} free RSVPs remaining.',
			'account.used' => 'Used',
			'account.remaining' => 'Remaining',
			'account.total' => 'Total',
			'account.upgradeToKeepJoining' => 'Upgrade to keep joining',
			'account.foundingDescription' => 'You are a verified Founding Pack member. Enjoy waived fees for events in your founding city.',
			'account.safetyBoundaries' => 'Safety Boundaries',
			'account.dangerZone' => 'Danger Zone',
			'account.suspendAccount' => 'Suspend Account',
			'account.deleteAccount' => 'Delete Account',
			'account.suspendTitle' => 'Suspend Account',
			'account.suspendBody' => 'Your profile will be hidden from other users. You can reactivate at any time by signing in.',
			'account.deleteTitle' => 'Delete Account',
			'account.deleteBody' => 'This permanently removes all your data. This action cannot be undone.',
			'account.deleteConfirmHint' => 'Type DELETE to confirm',
			'account.deleteConfirmError' => 'Incorrect. Please type DELETE to confirm.',
			'account.deleteForever' => 'Delete Forever',
			'account.signOut' => 'Sign Out',
			'account.upgrade.title' => 'Upgrade',
			'account.upgrade.heading' => 'Upgrade to Premium',
			'account.upgrade.description' => 'Unlimited RSVPs, early access to events, and exclusive perks.',
			'account.upgrade.comingSoon' => 'Upgrade coming soon',
			'account.suspend.title' => 'Account Suspended',
			'account.suspend.heading' => 'Your account is suspended',
			'account.suspend.body' => 'Your profile is hidden from other users. You can reactivate your account at any time.',
			'account.suspend.reactivated' => 'Account reactivated',
			'account.suspend.failedReactivation' => ({required Object error}) => 'Failed to reactivate: ${error}',
			'account.suspend.reactivate' => 'Reactivate Account',
			'account.rsvpLimit.remaining' => ({required Object remaining}) => 'You have ${remaining} free RSVPs remaining.',
			'account.rsvpLimit.exhausted' => 'You have used all your free RSVPs. Upgrade to keep joining events.',
			'account.foundingPack.badge' => 'Founding Pack',
			'connections.report.title' => 'Report User',
			'connections.report.hint' => 'Tell us what happened...',
			'connections.report.submit' => 'Submit',
			'connections.blocked.title' => 'Blocked Users',
			'connections.blocked.empty' => 'No blocked users',
			'connections.blocked.tier1' => 'Blocked',
			'connections.blocked.tier2' => 'Blocked & Hidden',
			'connections.blocked.tier3' => 'Blocked, Hidden & Reported',
			'connections.blocked.userUnblocked' => 'User unblocked',
			'connections.blocked.couldNotLoad' => 'Could not load blocked users',
			'info.fieldIntro.title' => 'Welcome to the Field',
			'info.fieldIntro.heading' => 'Explore Dog-Friendly Events',
			'info.fieldIntro.intro' => 'The Field map shows everything happening near you. Here\'s how to get started:',
			'info.fieldIntro.tips.0.title' => 'Browse the map',
			'info.fieldIntro.tips.0.description' => 'Green markers are casual walks, blue are playdates, orange are training sessions. Tap any marker to learn more.',
			'info.fieldIntro.tips.1.title' => 'RSVP to join',
			'info.fieldIntro.tips.1.description' => 'Tap "Join Pack" to let the host know you\'re coming. You\'ll see your RSVPs in the filter toggle above the map.',
			'info.fieldIntro.tips.2.title' => 'Host your own',
			'info.fieldIntro.tips.2.description' => 'Tap the + button to create a new event. Be sure to read the hosting tips first!',
			'info.fieldIntro.tips.3.title' => 'Send feedback',
			'info.fieldIntro.tips.3.description' => 'Found a bug or have a suggestion? Tap the chat bubble to share your thoughts with the team.',
			'info.fieldIntro.gotIt' => 'Got It',
			'messaging.title' => 'Messages',
			'messaging.empty' => 'No conversations yet',
			'messaging.emptyHint' => 'Chat with your packmates after you\'ve both confirmed meeting at an event.',
			'messaging.noMessages' => 'No messages yet',
			'messaging.noMessagesYet' => 'Send a message to start the conversation!',
			'messaging.typeMessage' => 'Type a message...',
			'messaging.failedToLoad' => 'Could not load messages',
			'messaging.failedToSend' => 'Failed to send message. Please try again.',
			'messaging.cannotMessage' => 'You can only message your packmates.',
			'errors.failedToCreateEvent' => 'Failed to create event. Please try again.',
			'errors.failedToUpdateEvent' => 'Failed to update event. Please try again.',
			'errors.failedToCancelEvent' => 'Failed to cancel event. Please try again.',
			'errors.failedToSuspend' => 'Failed to suspend account. Please try again.',
			'errors.failedToDelete' => 'Failed to delete account. Please try again.',
			'errors.failedToBlock' => 'Failed to block user. Please try again.',
			'errors.failedToBlockAndHide' => 'Failed to block and hide user. Please try again.',
			'errors.failedToReport' => 'Failed to report user. Please try again.',
			'errors.failedToUnblock' => 'Failed to unblock user. Please try again.',
			'errors.failedToRsvp' => ({required Object error}) => 'Failed to RSVP: ${error}',
			'errors.failedToCancelRsvp' => ({required Object error}) => 'Failed to cancel RSVP: ${error}',
			_ => null,
		};
	}
}
