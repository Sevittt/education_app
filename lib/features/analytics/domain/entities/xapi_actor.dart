import 'package:equatable/equatable.dart';

class XApiActor extends Equatable {
  final String name;
  final String mbox; // mailto:user@example.com

  const XApiActor({
    required this.name,
    required this.mbox,
  });

  Map<String, dynamic> toJson() {
    return {
      'objectType': 'Agent',
      'name': name,
      'mbox': mbox,
    };
  }

  factory XApiActor.fromJson(Map<String, dynamic> json) {
    return XApiActor(
      name: json['name'] as String,
      mbox: json['mbox'] as String,
    );
  }

  @override
  List<Object?> get props => [name, mbox];
}
