import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the "Actor" in xAPI (The User).
class XApiActor {
  final String mbox; // "mailto:user@example.com"
  final String? name;

  XApiActor({required this.mbox, this.name});

  Map<String, dynamic> toJson() {
    return {
      'mbox': mbox,
      if (name != null) 'name': name,
      'objectType': 'Agent',
    };
  }

  factory XApiActor.fromJson(Map<String, dynamic> json) {
    return XApiActor(
      mbox: json['mbox'] as String,
      name: json['name'] as String?,
    );
  }
}

/// Represents the "Verb" in xAPI (The Action).
class XApiVerb {
  final String id; // URI
  final Map<String, String> display; // "en-US": "completed"

  const XApiVerb({required this.id, required this.display});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display': display,
    };
  }

  factory XApiVerb.fromJson(Map<String, dynamic> json) {
    return XApiVerb(
      id: json['id'] as String,
      display: Map<String, String>.from(json['display'] as Map),
    );
  }
}

/// Represents the "Object" in xAPI (The Activity/Content).
class XApiObject {
  final String id; // URI
  final Map<String, dynamic> definition; // type, name, description

  XApiObject({required this.id, required this.definition});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'definition': definition,
      'objectType': 'Activity',
    };
  }

  factory XApiObject.fromJson(Map<String, dynamic> json) {
    return XApiObject(
      id: json['id'] as String,
      definition: Map<String, dynamic>.from(json['definition'] as Map),
    );
  }
}

/// Represents the "Result" in xAPI (The Outcome).
class XApiResult {
  final bool? success;
  final bool? completion;
  final String? duration; // ISO 8601 "PT4H"
  final Map<String, dynamic>? score; // { scaled: 0.95, raw: 95 }
  final Map<String, dynamic>? extensions;

  XApiResult({
    this.success,
    this.completion,
    this.duration,
    this.score,
    this.extensions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (success != null) data['success'] = success;
    if (completion != null) data['completion'] = completion;
    if (duration != null) data['duration'] = duration;
    if (score != null) data['score'] = score;
    if (extensions != null) data['extensions'] = extensions;
    return data;
  }

  factory XApiResult.fromJson(Map<String, dynamic> json) {
    return XApiResult(
      success: json['success'] as bool?,
      completion: json['completion'] as bool?,
      duration: json['duration'] as String?,
      score: json['score'] as Map<String, dynamic>?,
      extensions: json['extensions'] as Map<String, dynamic>?,
    );
  }
}

/// Static Constants for Standard Verbs to prevent typos.
class XApiVerbs {
  static const completed = XApiVerb(
    id: 'http://adlnet.gov/expapi/verbs/completed',
    display: {'en-US': 'completed'},
  );
  
  static const passed = XApiVerb(
    id: 'http://adlnet.gov/expapi/verbs/passed',
    display: {'en-US': 'passed'},
  );
  
  static const failed = XApiVerb(
    id: 'http://adlnet.gov/expapi/verbs/failed',
    display: {'en-US': 'failed'},
  );

  static const experienced = XApiVerb(
    id: 'http://adlnet.gov/expapi/verbs/experienced',
    display: {'en-US': 'experienced'},
  );

  static const interact = XApiVerb( // 'interacted' is common, 'interact' is ADL
     id: 'http://adlnet.gov/expapi/verbs/interacted', 
     display: {'en-US': 'interacted'},
  );
}

/// The Root xAPI Statement Document.
class XApiStatement {
  final XApiActor actor;
  final XApiVerb verb;
  final XApiObject object;
  final XApiResult? result;
  final DateTime timestamp;

  XApiStatement({
    required this.actor,
    required this.verb,
    required this.object,
    this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'actor': actor.toJson(),
      'verb': verb.toJson(),
      'object': object.toJson(),
      if (result != null) 'result': result!.toJson(),
      'timestamp': Timestamp.fromDate(timestamp), // Save as Firestore Timestamp
      'stored': FieldValue.serverTimestamp(), // When it was saved
    };
  }
}
