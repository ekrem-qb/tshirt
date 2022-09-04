import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/api/firebase.dart';
import '../../../domain/entity/tshirt.dart';

class Catalog extends ChangeNotifier {
  Catalog() {
    Future.microtask(() => _loadTshirts());
  }

  final List<StreamSubscription> _subscriptions = [];

  final Map<String, Tshirt> tshirts = {};

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  final scrollController = ScrollController();

  void _loadTshirts() async {
    _subscriptions.add(
      db.child('tshirts').onChildAdded.listen(
        (event) async {
          isLoading = false;
          if (event.snapshot.key != null && event.snapshot.value is Map) {
            tshirts[event.snapshot.key!] = Tshirt.fromFirebase(event.snapshot);
            notifyListeners();
          }
        },
      ),
    );
    _subscriptions.add(
      db.child('tshirts').onChildChanged.listen(
        (event) async {
          isLoading = false;
          if (event.snapshot.key != null && event.snapshot.value is Map) {
            tshirts[event.snapshot.key!] = Tshirt.fromFirebase(event.snapshot);
            notifyListeners();
          }
        },
      ),
    );
    _subscriptions.add(
      db.child('tshirts').onChildRemoved.listen(
        (event) async {
          isLoading = false;
          if (event.snapshot.key != null && event.snapshot.value is Map) {
            tshirts.remove(event.snapshot.key!);
            notifyListeners();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
