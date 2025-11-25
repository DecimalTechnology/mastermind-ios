class ProfileModel {
  final String? id;
  final String? imageUrl;
  final String name;
  final String company;
  final String memberSince;
  final List<String> industries;
  final Map<String, String> socialMediaLinks;
  final String? googleMapLocation;
  final List<int> phonenumbers;
  final String? about;
  final String? dob;
  final String? chapter;
  final String? region;
  final String? website;
  final String? email;
  final String? conncetionStatus;
  final String? userid;
  const ProfileModel(
      {required this.id,
      this.imageUrl,
      required this.name,
      required this.company,
      required this.memberSince,
      required this.industries,
      required this.socialMediaLinks,
      this.googleMapLocation,
      required this.phonenumbers,
      this.email,
      this.about,
      this.dob,
      this.chapter,
      this.region,
      this.website,
      this.conncetionStatus,
      this.userid});

  factory ProfileModel.fromJson(dynamic json) {
    if (json is List) {
      json = json.isNotEmpty ? json[0] : {};
    }

    final data =
        json['data'] != null ? ProfileData.fromJson(json['data']) : null;

    return ProfileModel(
      id: data?.id ?? json['_id'],
      imageUrl: data?.image ?? json['imageUrl'],
      name: data?.name ?? json['name'] ?? '',
      company: data?.company ?? json['company'] ?? '',
      memberSince: data?.memberSince ?? json['memberSince'] ?? '',
      industries: (() {
        final dynamic industriesRaw = data?.industry ?? json['industries'];
        if (industriesRaw == null) return <String>[];
        if (industriesRaw is List) {
          return List<String>.from(industriesRaw.map((e) => e.toString()));
        } else if (industriesRaw is String) {
          return industriesRaw.split(',').map((e) => e.trim()).toList();
        } else {
          return <String>[];
        }
      })(),
      socialMediaLinks: Map<String, String>.from(
        data?.socialMediaLinks ?? json['socialMedia'] ?? {},
      ),
      googleMapLocation: data?.googleMapLocation ?? json['googleMapLocation'],
      about: data?.about ?? json['about'],
      dob: data?.dob,
      chapter: data?.chapter,
      email: data?.email ?? json['email'],
      region: data?.region,
      website: data?.website,
      phonenumbers: (() {
        final dynamic phonesRaw = data?.phoneNumbers ?? json['phoneNumbers'];
        if (phonesRaw == null) return <int>[];
        if (phonesRaw is List) {
          if (phonesRaw.isEmpty) return <int>[];
          if (phonesRaw.first is int) {
            return List<int>.from(phonesRaw);
          } else {
            return phonesRaw
                .map((e) => int.tryParse(e.toString()) ?? 0)
                .toList();
          }
        } else if (phonesRaw is String) {
          return [int.tryParse(phonesRaw) ?? 0];
        } else {
          return <int>[];
        }
      })(),
      conncetionStatus: data?.connectionStatus ?? json['connectionStatus'],
      userid: data?.userid ?? json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'memberSince': memberSince,
      'industries': industries.join(','),
      'socialMediaLinks': socialMediaLinks,
      'googleMapLocation': googleMapLocation,
      'about': about,
      'dob': dob,
      'chapter': chapter,
      'region': region,
      'website': website,
      'email': email,
      'phoneNumbers': phonenumbers,
      // Do NOT include: image, connectionStatus, userId
    };
  }

  ProfileModel copyWith({
    String? id,
    String? imageUrl,
    String? name,
    String? company,
    String? memberSince,
    List<String>? industries,
    Map<String, String>? socialMediaLinks,
    String? googleMapLocation,
    String? about,
    String? email,
    String? dob,
    String? chapter,
    String? region,
    String? website,
    List<int>? phonenumbers,
    String? connectionStatus,
    String? userId,
  }) {
    return ProfileModel(
        id: id ?? this.id,
        imageUrl: imageUrl ?? this.imageUrl,
        name: name ?? this.name,
        company: company ?? this.company,
        memberSince: memberSince ?? this.memberSince,
        industries: industries ?? this.industries,
        socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
        googleMapLocation: googleMapLocation ?? this.googleMapLocation,
        about: about ?? this.about,
        dob: dob ?? this.dob,
        chapter: chapter ?? this.chapter,
        region: region ?? this.region,
        website: website ?? this.website,
        phonenumbers: phonenumbers ?? this.phonenumbers,
        email: email ?? this.email,
        conncetionStatus: connectionStatus,
        userid: userId);
  }
}

class ProfileData {
  final String? id;
  final String? company;
  final String? image;
  final String? about;
  final String? dob;
  final List<String>? industry;
  final List<int>? phoneNumbers;
  final String? email;
  final String? googleMapLocation;
  final String? website;
  final Map<String, String>? socialMediaLinks;
  final String? memberSince;
  final String? name;
  final String? chapter;
  final String? region;
  final String? connectionStatus;
  final String? userid;

  ProfileData(
      {this.id,
      this.company,
      this.image,
      this.about,
      this.dob,
      this.industry,
      this.phoneNumbers,
      this.email,
      this.googleMapLocation,
      this.website,
      this.socialMediaLinks,
      this.memberSince,
      this.name,
      this.chapter,
      this.region,
      this.connectionStatus,
      this.userid});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
        id: json['_id'],
        company: json['company'],
        image: json['image'],
        about: json['about'],
        dob: json['dob'],
        industry: (() {
          final dynamic industriesRaw = json['industries'];
          if (industriesRaw == null) return <String>[];
          if (industriesRaw is List) {
            return List<String>.from(industriesRaw.map((e) => e.toString()));
          } else if (industriesRaw is String) {
            return industriesRaw.split(',').map((e) => e.trim()).toList();
          } else {
            return <String>[];
          }
        })(),
        phoneNumbers: json['phoneNumbers'] != null
            ? List<int>.from(json['phoneNumbers'])
            : null,
        email: json['email'],
        googleMapLocation: json['googleMapLocation'],
        website: json['website'],
        socialMediaLinks: json['socialMediaLinks'] != null
            ? Map<String, String>.from(json['socialMediaLinks'])
            : null,
        memberSince: json['memberSince'],
        name: json['name'],
        chapter: json['chapter'],
        region: json['region'],
        connectionStatus: json['connectionStatus'],
        userid: json['userId']);
  }

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'image': image,
      'about': about,
      'dob': dob,
      'industry': industry,
      'phoneNumbers': phoneNumbers,
      'email': email,
      'googleMapLocation': googleMapLocation,
      'website': website,
      'socialMediaLinks': socialMediaLinks,
      'memberSince': memberSince,
      'name': name,
      'chapter': chapter,
      'region': region,
      'connectionStatus': connectionStatus,
      'userId': userid
    };
  }
}
