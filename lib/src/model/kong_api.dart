part of kong;

/// [KongApi] is a class representation of the Kong service response concerning Api
///
/// [KongApi] will be transform to JSON 
class Api {
  @ApiProperty(
    defaultValue:null
  )
  String id;
  String name;
  String path;
  String public_dns;
  String target_url;
  int created_at;
  bool strip_path;
  bool preserve_host;

  Api({this.id, this.name, this.path, this.public_dns, this.target_url, this.created_at, this.strip_path, this.preserve_host});

  toString() {
    var s = {
      "id": id,
      "name": name,
      "target_url": target_url,
      "public_dns": public_dns,
      "path": path,
      "strip_path": strip_path,
      "preserve_host": preserve_host,
      "created_at": created_at,
    };

    return "${s}";
  }
}

/// [KongNodeStatus]