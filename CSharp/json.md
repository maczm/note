# 1、序列化与反序列化

```c#
//反序列化父JSON
dynamic Json = JsonConvert.DeserializeObject(JsonLocationState);
//序列化子JSON
string JsonSon = Newtonsoft.Json.JsonConvert.SerializeObject(Json.reported);
//反序列化子JSON
dynamic TaskInfo= Newtonsoft.Json.JsonConvert.DeserializeObject(JsonSon);
//反序列化父JSON
Newtonsoft.Json.Linq.JObject  JsonInputs = Newtonsoft.Json.JsonConvert.DeserializeObject<Newtonsoft.Json.Linq.JObject>(JsonObject);
```

