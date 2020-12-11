# AppLaunchCreateOrderFile
二进制重排,自动创建order文件

# 使用步骤:

1.配置：Target->Build Setting->Custom Compiler Flags

    Objective-C:
        **Other C flags**:   `-fsanitize-coverage=func,trace-pc-guard`
    Swift:
        **Other Swift Flags**: `  -fsanitize-coverage=func,trace-pc-guard`
        
2.评估APP启动结束节点，并在适当的位置调用

    ```
    +[AppLaunchCreateOrderFile toCreateOrderFile];
    ```
3.获取app.order 文件

    在Sandbox->tmp->app.order
    
# 【注意】
这个文件不需要跟随项目发布，只是优化期生成order文件使用，发布前请清空并移除配置

