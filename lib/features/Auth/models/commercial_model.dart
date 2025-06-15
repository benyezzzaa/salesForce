class CommercialModel {
  String? accessToken;
  User? user;

  CommercialModel({this.accessToken, this.user});

  CommercialModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? nom;
  String? prenom;
  String? email;
  String? password;
  String? tel;
  String? role;
  double? latitude;
  double? longitude;
  bool? isActive;

  User(
      {this.id,
      this.nom,
      this.prenom,
      this.email,
      this.password,
      this.tel,
      this.role,
      this.latitude,
      this.longitude,
      this.isActive});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    prenom = json['prenom'];
    email = json['email'];
    password = json['password'];
    tel = json['tel'];
    role = json['role'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nom'] = this.nom;
    data['prenom'] = this.prenom;
    data['email'] = this.email;
    data['password'] = this.password;
    data['tel'] = this.tel;
    data['role'] = this.role;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['isActive'] = this.isActive;
    return data;
  }
}