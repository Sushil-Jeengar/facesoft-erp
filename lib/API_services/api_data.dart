class API_Data{
  static const String domainLink = "http://192.168.1.141:3000/v1/api/";

  // Auth
  static const String login = domainLink + "auth/signin/send-otp";
  static const String verifyOtp = domainLink + "auth/signin/verify-otp";

  // User
  static const String user = domainLink + "admin/users";

  //Companies
  static const String companies = domainLink + "admin/companies";

  //Parties
  static const String parties = domainLink + "admin/parties";

  //Suppliers
  static const String suppliers = domainLink + "admin/suppliers";

  //Agents
  static const String agents = domainLink + "admin/agents";

  //Transports
  static const String transports = domainLink + "admin/transports";

  //Qualities
  static const String qualities = domainLink + "admin/qualities";

  //Orders
  static const String orders = domainLink + "admin/orders";

  //Items
  static const String items = domainLink + "admin/items";

  //Plans
  static const String plans = domainLink + "admin/plans";
}