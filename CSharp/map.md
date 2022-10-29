# 1、匹配两个List

```c#
Dictionary<string,int> map = new Dictionary<string,int>();
for (int i = 0; i < productIdList.Length;i++) 
{
	if (map.ContainsKey(productIdList[i])) 
	{
		int value = map[productIdList[i]] + quantityList[i];
		map[productIdList[i]] = value;
	}
	else
	{
		map.Add(productIdList[i], quantityList[i]);
	}
}
List<string> pList = new List<string>();
List<int> qList = new List<int>();
foreach (var dic in map)
{
	pList.Add(dic.Key);
	qList.Add(dic.Value);
}
var = productId = pList.ToArray();
var = quantity = qList.ToArray();
```



