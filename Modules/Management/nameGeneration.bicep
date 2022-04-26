param namePrefix string
var name = '${namePrefix}${uniqueString(resourceGroup().id)}'
output nameOutput string = name
