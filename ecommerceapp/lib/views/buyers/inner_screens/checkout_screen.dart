import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/provider/cart_provider.dart';
import 'package:ecommerceapp/views/buyers/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CheckOutScreen extends StatelessWidget {
  const CheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final CartProvider _cartProvider = Provider.of<CartProvider>(context);
    CollectionReference users = FirebaseFirestore.instance.collection('buyers');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(FirebaseAuth.instance.currentUser!.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.yellow.shade900,
              title: Text(
                'CheckOut',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: ListView.builder(
                shrinkWrap: true,
                itemCount: _cartProvider.getCartItem.length,
                itemBuilder: (context, index) {
                  final cartData =
                      _cartProvider.getCartItem.values.toList()[index];
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      child: SizedBox(
                        height: 175,
                        child: Row(
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.network(
                                cartData.imageUrl[0],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartData.productName,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3),
                                  ),
                                  Text(
                                    '\$' +
                                        ' ' +
                                        cartData.price.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3,
                                      color: Colors.yellow.shade900,
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: null,
                                    child: Text(
                                      cartData.productSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            bottomSheet: Padding(
              padding: const EdgeInsets.all(13.0),
              child: InkWell(
                onTap: () {
                  EasyLoading.show(status: 'Placing Order');
                  _cartProvider.getCartItem.forEach(
                    (key, item) {
                      final orderId = Uuid().v4();
                      _firestore.collection('orders').doc(orderId).set({
                        'orderId': orderId,
                        'vendor': item.vendorId,
                        'email': data['email'],
                        'phone': data['phoneNumber'],
                        'address': data['address'],
                        'buyerId': data['buyerId'],
                        'fullName': data['fullName'],
                        'buyerPhoto': data['profileImage'],
                        'productName': item.productName,
                        'productPrice': item.price,
                        'productId': item.productId,
                        'productImage': item.imageUrl,
                        'quantity': item.productQuantity,
                        'productSize': item.productSize,
                        'scheduleDate': item.scheduleDate,
                        'orderDate': DateTime.now(),
                      }).whenComplete(() {
                        _cartProvider.getCartItem.clear();
                      });
                      EasyLoading.dismiss();

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return MainScreen();
                      }));
                    },
                  );
                  // Place order, it work of future
                  print('Place Order');
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade900,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      'PLACE ORDER',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Center(
          child: CircularProgressIndicator(
            color: Colors.yellow.shade900,
          ),
        );
      },
    );
  }
}
