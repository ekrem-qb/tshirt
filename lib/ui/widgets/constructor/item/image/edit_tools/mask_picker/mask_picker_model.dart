import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../../domain/api/firebase.dart';
import '../../../../../../../domain/entity/mask.dart';
import '../../image_model.dart';

class MaskPicker extends ChangeNotifier {
  MaskPicker(this.imageModel, Mask? currentMask) {
    if (currentMask != null) {
      selectedMaskId = currentMask.id;
    }
    Future.microtask(() => _loadMasks());
  }

  final ImageItem imageModel;

  final List<StreamSubscription> subscriptions = [];

  final Map<String, Mask> masks = {'': Mask()..id = ''};

  bool isLoading = true;

  String _selectedMaskId = '';
  String get selectedMaskId => _selectedMaskId;
  set selectedMaskId(String selectedIndex) {
    _selectedMaskId = selectedIndex;
    notifyListeners();
  }

  final scrollController = ScrollController();

  void _loadMasks() async {
    subscriptions.add(
      db.child('masks').onChildAdded.listen(
        (event) async {
          isLoading = false;
          if (event.snapshot.key != null) {
            masks[event.snapshot.key!] = Mask.fromFirebase(event.snapshot);
            notifyListeners();
          }
        },
      ),
    );
    subscriptions.add(
      db.child('masks').onChildChanged.listen(
        (event) async {
          isLoading = false;
          if (event.snapshot.key != null) {
            masks[event.snapshot.key!] = Mask.fromFirebase(event.snapshot);
            notifyListeners();
          }
        },
      ),
    );
    subscriptions.add(
      db.child('masks').onChildRemoved.listen(
        (event) async {
          isLoading = false;
          if (event.snapshot.key != null) {
            masks.remove(event.snapshot.key!);
            notifyListeners();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
