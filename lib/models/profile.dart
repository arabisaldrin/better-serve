class Profile {
  String username;
  String firstName;
  String lastName;
  String? avatarUrl;

  Profile({
    required this.username,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
  });

  Profile.fromJson(Map<String, dynamic> data)
      : this(
            username: data["username"],
            firstName: data["first_name"],
            lastName: data["last_name"],
            avatarUrl: data["avatar_url"]);

  String get initials => (firstName[0] + lastName[0]).toUpperCase();
}
