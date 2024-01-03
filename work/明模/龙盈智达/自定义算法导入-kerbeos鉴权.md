## 背景

行方提供 kerbeos鉴权的文件，需要我们自己做鉴权，不再通过星云做鉴权

## 修改建议

1. 在chaos接口中做kerbeos鉴权，并下载算法包
2. tlib中的 python 服务调用 chaos接口 将算法包加载到notebook所在服务器

## tlib修改点

