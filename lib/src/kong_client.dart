part of kong;

/// [Client] handle the communication with a Kong server
/// 
/// [Client] will handle the communication with and Kong server and will provide some features like :
///
///   * Some error handling, like update a API if the api have already been added
///   * Provide Object representation of Kong response
///   * Provide Object representation of parameter send to Kong
///
class Client {
  List<String> urls;
  /// url of the main kong server
  String url;
  
  ApiConfigSchema _apiConfigSchema;
  ApiParser _parser = new ApiParser();
  Map<Type, ApiConfigSchema> _configsSchema = {};

  Client({String this.url, List<String> this.urls}) {
    _configsSchema[Api] = _parser.parseSchema(reflectClass(Api), false);
    _configsSchema[NodeStatus] = _parser.parseSchema(reflectClass(NodeStatus), false);
    _configsSchema[NodePlugins] = _parser.parseSchema(reflectClass(NodePlugins), false);
  }

  ///
   /// Retrieve one api information from the key parameter [official-documentation/add-api](http://getkong.org/docs/0.4.1/admin-api/#retrieve-api)
   ///
   /// The key parameter can be a String or a Api object
   /// If the key is a String, it needs to be the name or the id of the registered API
   /// name or id [required] :	The unique identifier or the name of the API to retrieve
   ///
  Future<Api> getOneApi(var key) async {
    String id;
    if (key is Api)
      id = key.id;
    else
      id = key;
    var res = await http.get(_createUrl(url + "apis/${id}"));
    if (res.statusCode == HttpStatus.NOT_FOUND)
      return null; // TODO : check what is best , return null or throw exception ?
    return _fromJson(Api, JSON.decode(res.body));
  }

  /// [getApis] retreive the list of API registered [official-documentation/list-apis](http://getkong.org/docs/0.4.1/admin-api/#list-apis)
  ///
  /// - id [optional] :	A filter on the list based on the apis id field.
  /// - name [optional] :	A filter on the list based on the apis name field.
  /// - public_dns [optional] : A filter on the list based on the apis public_dns field.
  /// - target_url [optional] :	A filter on the list based on the apis target_url field.
  /// - size [optional] : optional, default is 100	A limit on the number of objects to be returned.
  /// - offset [optional] :	A cursor used for pagination. offset is an object identifier that defines a place in the list.
  Future<List<Api>> getApis({String id, String name, String public_dns, String target_url, int size, int offset}) async {
    Map params = {
      "id": id,
      "name": name,
      "public_dns": public_dns,
      "target_url": target_url,
      "size": size,
      "offset": offset
    };
    var res = await http.get(_createUrl(url + "apis/", params));
    var json = JSON.decode(res.body);
    var l = [];
    for (var jsonApi in json.data) {
      l.add(_fromJson(Api, jsonApi));
    }
    return l;
  }
  
  /// Register a api into kong. [official-documentation/add-api](http://getkong.org/docs/0.4.1/admin-api/#add-api)
  ///
  /// * name [optional] :	The API name. If none is specified, will default to the public_dns.
  /// * public_dns [semi-optional] :	The public DNS address that points to your API. For example, mockbin.com. At least public_dns or path or both should be specified.
  /// * path [semi-optional] :	The public path that points to your API. For example, /someservice. At least public_dns or path or both should be specified.
  /// * strip_path [optional] :	Strip the path value before proxying the request to the final API. For example a request made to /someservice/hello will be resolved to target_url/hello. By default is false.
  /// * target_url :	The base target URL that points to your API server, this URL will be used for proxying requests. For example, https://mockbin.com.
  addApi(Api api) async {
    Api tmp = await getOneApi(api.name);
    var res;
    if (tmp == null)
      res = await http.post(_createUrl(url + "apis/", {}), body: _toJson(api));
    else {
      api.id = tmp.id;
      res = await http.put(_createUrl(url + "apis/", {}), body: _toJson(api));
    }
    if (res.statusCode == HttpStatus.CONFLICT)
      throw new ConflictException("api already exist", res.body);
    return _fromJson(Api, JSON.decode(res.body));
  }

  /// [addApiFromParam] will create a [Api] object from the parameters and call [addApi]
  addApiFromParam(String targetUrl, {String name, String publicDns, String path, bool stripPath, bool preserveHost}) async {
    var urlParams = {
      "name": name,
      "target_url": targetUrl,
      "public_dns": publicDns,
      "path": path,
      "strip_path": stripPath,
      "preserve_host": preserveHost
    };
    return await addApi(_fromJson(Api, urlParams));
  }

  /// [status] retreive node status
  ///
  /// Retrieve usage informations about a node, with some basic information about the connections being processed by the underlying nginx process.
  /// Because Kong is built on top of nginx, every existing nginx monitoring tool or agent can also be used.
  status() async {
    var res = await http.get(_createUrl(url + "/status"));
    return _fromJson(NodeStatus, JSON.decode(res.body));
  }

  /// [info] will retreive installation details about a node [official-documentation/informations-routes](https://getkong.org/docs/0.4.X/admin-api#informations-routes)
  info() async {
    var res = await http.get(_createUrl(url + ""));
    return _fromJson(NodeStatus, JSON.decode(res.body));
  }

  String _createUrl(String baseUrl, [Map<String, dynamic> urlParameter]) {
    if (urlParameter == null)
      return baseUrl;
    Map tmp = new Map.from(urlParameter);
    tmp.forEach((k, v) {
      if (v == null)
        tmp.remove(k);
    });
    var newUrl = baseUrl + "?";
    urlParameter.forEach((String key, var value) {
      newUrl += "${key}=${value}&";
    });
    newUrl = newUrl.substring(0, newUrl.length-1);
    return newUrl;
  }

  ///
   /// [MongoMapper.toJson] use the [rpc] package transformation to JSON function to transform your object to JSON object
   ///
  _toJson(var obj) {
    var json = _configsSchema[obj.runtimeType].toResponse(obj);
    return json;
  }

  ///
   /// [MongoMapper.toJson] use the [rpc] package transformation from JSON function to transform your JSON object to a new instance of your type T
   ///
  _fromJson(Type type, var json) {
    return _configsSchema[type].fromRequest(json);
  }
}