import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:maruttimitra/models/remote/product_model.dart';
import 'package:maruttimitra/models/remote/user_model.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';

class ProductsTableHelper {
  static const String productTableName = 'products';

  static final _db = FirebaseFirestore.instance;
  static final _productsDB = _db.collection(productTableName);

  static Future<List<ProductModel>> getProducts() async {
    final response = await _productsDB.get();

    // if (response.docs.isEmpty) {
    //   final defaultProducts = [
    //     ProductModel(name: "Abele Profiles", points: 200, shop: "MWholesales"),
    //     ProductModel(name: "Abele Sliding Tracks", points: 200, shop: "MWholesales"),
    //     ProductModel(name: "Kosher Profiles", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Kosher Sliding Tracks", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Kosher Gate Sheet", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Acrylic Sheets", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Polycarbonate Sheets", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Artificial Grass", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Acp Sheet", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Pvc Sheet", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Edge Banding", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Aluminium Coil", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Ss Pipe", points: 100, shop: "MWholesales"),
    //     ProductModel(name: "Imported Ladders Ss, Telescopic Ladders, Multipurpose Ladders", points: 300, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Vacuum Bush", points: 300, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Rubber Beading", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Cloth Stands", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Display Channel & Brackets", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Glass Patch Fittings", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Friction Stay", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Sliding Hardware", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Door Hardware", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Screws", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Mosquito Hardware", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Glass Railings", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Aluminium Ladders Liberti ,Euro Star, Industrial Ladders", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Ss Profile", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Wooden Door Sliding Fittings", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Vijaya Bearings", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Floor Spring & Door Closers", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Pvc Beading", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Upvc Hardware", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Domal Windows Hw", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Profile Hardware", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Saint Gobain Glass Hardware", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Hardwyn Hardware", points: 200, shop: "Vinlam Concepts"),
    //     ProductModel(name: "Ozone Hw", points: 100, shop: "Marutti Aluminiums"),
    //     ProductModel(name: "Door Rods", points: 100, shop: "Marutti Aluminiums"),
    //     ProductModel(name: "Aluminium Grills", points: 100, shop: "Marutti Aluminiums"),
    //     ProductModel(name: "Silicone ,Foam ,Spray", points: 100, shop: "Marutti Aluminiums"),
    //     ProductModel(name: "Aluminium Mesh, Ss Mesh, Pvc Mesh", points: 100, shop: "Marutti Aluminiums"),
    //     ProductModel(name: "Ceiling Grid,Channels", points: 100, shop: "Marutti Aluminiums"),
    //     ProductModel(name: "Aluminium Profile", points: 100, shop: "Marutti Aluminiums"),
    //     ProductModel(name: "Masking Tapes", points: 100, shop: "Marutti Aluminiums"),
    //     ProductModel(name: "Polycorbonate", points: 100, shop: "Marutti Aluminiums"),
    //     ProductModel(name: "Aluminium Rivets", points: 100, shop: "Marutti Aluminiums"),
    //     ProductModel(name: "Cabinet Handles & Knobs- Ph,Engrave,Jsv,Abele", points: 300, shop: "Hardware Palace"),
    //     ProductModel(name: "S.s Kitchen Baskets", points: 300, shop: "Hardware Palace"),
    //     ProductModel(name: "Abele Kitchen Tandems Imported", points: 300, shop: "Hardware Palace"),
    //     ProductModel(name: "Abele Brass Hinges", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Abele Brass Towerbolts", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Mortice Locks", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Abele Door Pull Handles", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Abele Rose Lock Ss Or Brass", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Auto Hinges(Ss) O Crank,8 Crank -Sterling,Aries,Evia", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Cylindrical Knob Locks -Abele,Kosher", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Kosher Cabinet Handles Ss", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Abele Drawer Locks & Cupboard Locks", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Abele Cupboard Gas Lifter", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Kosher Khuties", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Folding Bracket", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Door Stoppers", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Bath Accessories", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Glass Items-Lbat,Studs,F Bracket, Wall Touch", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Sofa Legs", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Screws", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Hydraulic Bed Lifter", points: 200, shop: "Hardware Palace"),
    //     ProductModel(name: "Telescopic Channels Ss&Zn -Abele,Kosher", points: 100, shop: "Hardware Palace"),
    //     ProductModel(name: "Abele Antique Coated Items -Aldrop,Hinges,Towerbolts", points: 100, shop: "Hardware Palace"),
    //     ProductModel(name: "Abele Brass Aldrops", points: 100, shop: "Hardware Palace"),
    //     ProductModel(name: "Ss Hinges: Q3Wld,Q3Pin,Kosher,Cn", points: 100, shop: "Hardware Palace"),
    //     ProductModel(name: "Kosher Ss Aldrops", points: 100, shop: "Hardware Palace"),
    //     ProductModel(name: "Kosher Door Handles Ss", points: 100, shop: "Hardware Palace"),
    //     ProductModel(name: "Kosher Aluminium Towerbolt,Windowstay,Handles", points: 100, shop: "Hardware Palace"),
    //   ];
    //   for (var product in defaultProducts) {
    //     await _productsDB.add(product.toJson());
    //   }
    //   return defaultProducts;
    // }

    return response.docs.map((e) => ProductModel.fromJson(e.data())).toList();
  }
}