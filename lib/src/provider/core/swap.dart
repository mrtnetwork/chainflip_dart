class CfSwapMethods {
  final String name;
  final String url;
  const CfSwapMethods._({required this.name, required this.url});
  static const CfSwapMethods quote =
      CfSwapMethods._(name: "quote", url: "/quote");
  static const CfSwapMethods quoteV2 =
      CfSwapMethods._(name: "quoteV2", url: "/v2/quote");
  static const CfSwapMethods swap =
      CfSwapMethods._(name: "swap", url: "/swaps/:id");
  static const CfSwapMethods swapV2 =
      CfSwapMethods._(name: "swap", url: "/v2/swaps/:id");
}
