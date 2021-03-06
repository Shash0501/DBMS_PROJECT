import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_ordering_app/cache/order.dart';
import 'package:food_ordering_app/features/customer/home/data/models/orderitem_model.dart';
import 'package:food_ordering_app/features/customer/home/presentation/pages/checkout_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/menuitem_model.dart';
import '../bloc/homepage_bloc.dart';
import 'create_order_page.dart';

class CartPage extends StatefulWidget {
  CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // var box = Hive.box<CurrentOrder>("currentOrder");
  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Your Cart'),
      ),
      body: ValueListenableBuilder<Box>(
          valueListenable: Hive.box<CurrentOrder>("currentOrder").listenable(),
          builder: (buildContext, box, _) {
            List<dynamic> itemIds =
                Hive.box<CurrentOrder>("currentOrder").keys.toList();
            print(box.length);
            return Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      CurrentOrder currentOrder = box.get(itemIds[index])!;
                      MenuItemModel m = MenuItemModel(
                          category: currentOrder.category,
                          itemName: currentOrder.itemName,
                          price: currentOrder.price,
                          description: currentOrder.description,
                          isAvailable: currentOrder.isAvailable,
                          isVeg: currentOrder.isVeg,
                          itemId: currentOrder.itemId,
                          restaurantId: currentOrder.restaurantId);
                      return CustomisableMenuItem(
                        menuItem: MenuItemModel(
                          category: currentOrder.category,
                          isAvailable: currentOrder.isAvailable,
                          itemId: currentOrder.itemId,
                          itemName: currentOrder.itemName,
                          description: currentOrder.description,
                          isVeg: currentOrder.isVeg,
                          price: currentOrder.price,
                          restaurantId: currentOrder.restaurantId,
                        ),
                      );
                    }),
                ElevatedButton(
                  onPressed: () async {
                    String restaurantId = box.get(itemIds[0])!.restaurantId;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          orderItem: OrderItemModel(
                              orderId: uuid.v1(),
                              customerId: FirebaseAuth
                                  .instance.currentUser!.email
                                  .toString(),
                              restaurantId: restaurantId,
                              orderDate: Timestamp.now(),
                              totalAmount: totalAmount(),
                              ratingGiven: 2,
                              status: "Pending",
                              order: getOrderList(),
                              pincode: 314122,
                              address: "asdasdasd asdvhv a jsvdj hasdjb"),
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: Text("Checkout"),
                )
              ],
            );
          }),
    );
  }
}

List<Map<String, dynamic>> getOrderList() {
  List<Map<String, dynamic>> orderList = [];
  List<dynamic> itemIds = Hive.box<CurrentOrder>("currentOrder").keys.toList();
  for (int i = 0; i < itemIds.length; i++) {
    CurrentOrder currentOrder =
        Hive.box<CurrentOrder>("currentOrder").get(itemIds[i])!;
    Map<String, dynamic> order = {
      "itemId": currentOrder.itemId,
      "itemName": currentOrder.itemName,
      'description': currentOrder.description,
      "price": currentOrder.price,
      "quantity": currentOrder.quantity,
      "restaurantId": currentOrder.restaurantId,
      "category": currentOrder.category,
    };
    orderList.add(order);
  }
  return orderList;
}

double totalAmount() {
  double total = 0;
  List<dynamic> itemIds = Hive.box<CurrentOrder>("currentOrder").keys.toList();
  for (int i = 0; i < itemIds.length; i++) {
    CurrentOrder currentOrder =
        Hive.box<CurrentOrder>("currentOrder").get(itemIds[i])!;
    total = total + currentOrder.price * currentOrder.quantity;
  }
  return total;
}
