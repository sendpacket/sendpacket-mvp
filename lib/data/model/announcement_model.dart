import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String? docId; // id Firestore auto
  final int id; // id numérique interne
  final String departPays;
  final String departVille;
  final String arriveePays;
  final String arriveeVille;
  final String createdAt; // "dd-MM-yyyy"
  final String dateVoyage; // "dd-MM-yyyy"
  final String expiresAt; // "dd-MM-yyyy"
  final String numeroTel;
  final int poidsDisponible;
  final num pricePerKilo; // stocké dans Firestore sous "price"
  final bool whatsapp;
  final bool isBoosted;
  final String ownerId;
  final String? description;

  // facultatif : infos du voyageur directement dans l’annonce
  final String? ownerFirstName;
  final String? ownerLastName;
  final String? ownerProfileImage;

  Announcement({
    this.docId,
    required this.id,
    required this.departPays,
    required this.departVille,
    required this.arriveePays,
    required this.arriveeVille,
    required this.createdAt,
    required this.dateVoyage,
    required this.expiresAt,
    required this.numeroTel,
    required this.poidsDisponible,
    required this.pricePerKilo,
    required this.whatsapp,
    required this.isBoosted,
    required this.ownerId,
    this.description,
    this.ownerFirstName,
    this.ownerLastName,
    this.ownerProfileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departPays': departPays,
      'departVille': departVille,
      'arriveePays': arriveePays,
      'arriveeVille': arriveeVille,
      'createdAt': createdAt,
      'dateVoyage': dateVoyage,
      'expiresAt': expiresAt,
      'numeroTel': numeroTel,
      'poidsDisponible': poidsDisponible,
      'price': pricePerKilo, // ⚠️: champ Firestore actuel
      'whatsapp': whatsapp,
      'isBoosted': isBoosted,
      'ownerId': ownerId,
      'description': description ?? '',
      'ownerFirstName': ownerFirstName,
      'ownerLastName': ownerLastName,
      'ownerProfileImage': ownerProfileImage,
    };
  }

  factory Announcement.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snap,
      ) {
    final data = snap.data() ?? {};
    return Announcement(
      docId: snap.id,
      id: (data['id'] ?? 0) is int
          ? data['id'] as int
          : int.tryParse(data['id'].toString()) ?? 0,
      departPays: (data['departPays'] ?? '').toString(),
      departVille: (data['departVille'] ?? '').toString(),
      arriveePays: (data['arriveePays'] ?? '').toString(),
      arriveeVille: (data['arriveeVille'] ?? '').toString(),
      createdAt: (data['createdAt'] ?? '').toString(),
      dateVoyage: (data['dateVoyage'] ?? '').toString(),
      expiresAt: (data['expiresAt'] ?? '').toString(),
      numeroTel: (data['numeroTel'] ?? '').toString(),
      poidsDisponible: int.tryParse(
          (data['poidsDisponible'] ?? '0').toString()) ??
          0,
      pricePerKilo:
      num.tryParse((data['price'] ?? '0').toString()) ?? 0,
      whatsapp: (data['whatsapp'] ?? false) == true,
      isBoosted: (data['isBoosted'] ?? false) == true,
      ownerId: (data['ownerId'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      ownerFirstName: data['ownerFirstName']?.toString(),
      ownerLastName: data['ownerLastName']?.toString(),
      ownerProfileImage: data['ownerProfileImage']?.toString(),
    );
  }
}
