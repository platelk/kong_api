part of kong;

class NodePlugins {
  List<String> available_on_server;
  Map<String, bool> enable_in_cluster;
}

class NodeInfo {
  String hostname;
  String lua_version;
  NodePlugins plugins;
  String tagline;
  String version;
}