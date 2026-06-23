import '../../models/remote/shop_model.dart';
import '../../resources/marutti_logos.dart';

class Constants {
  static const String keyLanguageCode = 'language-code';
  static const String keyLoggedInTime = 'logged-in-time';

  static const String keyType = 'type';
  static const String keyUrl = 'url';

  static const String keyTitle = 'type';

  static const String keyFirm = 'firm';

  static const String keyCategory = 'category';
  static const String keyCreated = 'createdAt';
  static const String keyRoomId = 'roomId';
  static const String keySender = 'sender';

  static const String keyIsBasicInfoSubmitted = 'is-basic-info-submitted';
  static const String keyIsAddressDetailsSubmitted = 'is-address-details-submitted';

  static const String termsOfService = "Terms of Service";
  static const String privacyPolicy = "Privacy Policy";


  static const shops = [
    ShopModel(name: 'Marutti Aluminiums', logo: MaruttiLogos.aluminiums),
    ShopModel(name: 'Vinlam Concepts', logo: MaruttiLogos.vinlam),
    ShopModel(name: 'Hardware Palace', logo: MaruttiLogos.hardwarePalace),
    ShopModel(name: 'MWholesale', logo: MaruttiLogos.mWholesale),
  ];

  static const String keyVerificationId = 'verification-id';

}