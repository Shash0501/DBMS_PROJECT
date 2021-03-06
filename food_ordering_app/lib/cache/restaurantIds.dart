import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as d;

import 'package:food_ordering_app/cache/ids.dart';
import 'package:hive/hive.dart';

Future<bool> cacheRestaurantIds() async {
  var box = Hive.box<Id>('restaurantIds');
  box.clear();

  List<String> restaurantIds = [];

  await FirebaseFirestore.instance
      .collection("restaurants")
      .get()
      .then((value) {
    value.docs.forEach((element) {
      box.put(
          element.id,
          Id(
              id: element.id,
              name: element.data()["restaurantName"],
              rating: element.data()["rating"].toString()));
    });
  });
  return true;
}

List<String> getRestaurantIds() {
  Box box = Hive.box<Id>('restaurantIds');
  List<String> ids = [];
  box.values.forEach((element) {
    ids.add(element.id);
  });
  return ids;
}
