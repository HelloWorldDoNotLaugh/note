```java
 private List<Long> getTaskIdByStatusAndRowBounds(String status, Integer rowNum) {
        Example holmesModelTaskExample = Example.builder(HolmesModelTask.class).build();
        // 设置查询字段
        holmesModelTaskExample.selectProperties(HolmesModelTask.Fields.id);
        // 按照修改时间排序
        holmesModelTaskExample.orderBy(HolmesModelTask.Fields.gmtModify);
        Example.Criteria holmesModelTaskExampleCriteria = holmesModelTaskExample.createCriteria();
        // 查询特定状态：排队中
        holmesModelTaskExampleCriteria.andEqualTo(HolmesModelTask.Fields.status, status);
        // 只取前n条数据
        RowBounds rowBounds = new RowBounds(0, rowNum);
        List<HolmesModelTask> holmesModelTaskList = holmesModelTaskMapper.selectByExampleAndRowBounds(holmesModelTaskExample, rowBounds);
        
        return holmesModelTaskList.stream().map(HolmesModelTask::getId).collect(Collectors.toList());
 }
```

