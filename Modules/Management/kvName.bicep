param kvNamePrefix string
var kvName = '${kvNamePrefix}${uniqueString(resourceGroup().id)}'
output kvNameOutput string = kvName
