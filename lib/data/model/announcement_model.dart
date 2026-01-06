import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String? docId;
  final String departPays;
  final String departVille;
  final String arriveePays;
  final String arriveeVille;
  final String createdAt;
  final String dateVoyage;
  final String expiresAt;
  final String numeroTel;
  final int poidsDisponible;
  final num pricePerKilo;
  final bool whatsapp;
  final bool isBoosted;
  final String ownerId;
  final String? description;

  Announcement({
    this.docId,
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
  });

  Map<String, dynamic> toMap() {
    return {
      'departPays': departPays,
      'departVille': departVille,
      'arriveePays': arriveePays,
      'arriveeVille': arriveeVille,
      'createdAt': createdAt,
      'dateVoyage': dateVoyage,
      'expiresAt': expiresAt,
      'numeroTel': numeroTel,
      'poidsDisponible': poidsDisponible,
      'price': pricePerKilo,
      'whatsapp': whatsapp,
      'isBoosted': isBoosted,
      'ownerId': ownerId,
      'description': description ?? '',
    };
  }

  factory Announcement.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snap,
      ) {
    final data = snap.data();
    if (data == null) {
      throw StateError('Announcement snapshot data is null');
    }

    final poids = int.tryParse(data['poidsDisponible']?.toString() ?? '');
    final price = num.tryParse(data['price']?.toString() ?? '');

    if (poids == null || poids <= 0) {
      throw StateError('Invalid poidsDisponible in Announcement ${snap.id}');
    }

    if (price == null || price <= 0) {
      throw StateError('Invalid pricePerKilo in Announcement ${snap.id}');
    }

    final ownerId = data['ownerId']?.toString();
    if (ownerId == null || ownerId.isEmpty) {
      throw StateError('Missing ownerId in Announcement ${snap.id}');
    }

    return Announcement(
      docId: snap.id,
      departPays: data['departPays']?.toString() ?? '',
      departVille: data['departVille']?.toString() ?? '',
      arriveePays: data['arriveePays']?.toString() ?? '',
      arriveeVille: data['arriveeVille']?.toString() ?? '',
      createdAt: data['createdAt']?.toString() ?? '',
      dateVoyage: data['dateVoyage']?.toString() ?? '',
      expiresAt: data['expiresAt']?.toString() ?? '',
      numeroTel: data['numeroTel']?.toString() ?? '',
      poidsDisponible: poids,
      pricePerKilo: price,
      whatsapp: data['whatsapp'] == true,
      isBoosted: data['isBoosted'] == true,
      ownerId: ownerId,
      description: data['description']?.toString(),
    );
  }

}
