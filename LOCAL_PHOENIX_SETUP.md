# 本地Phoenix环境搭建指南

本指南将帮助您在本地搭建Arize Phoenix跟踪环境，用于监控和调试您的应用程序。

## 1. 安装Phoenix

首先，确保您已经安装了Python和pip，然后执行以下命令安装Phoenix：

```bash
pip install arize-phoenix
```

## 2. 启动本地Phoenix服务器

### 方法1：使用Python代码启动（推荐）

创建一个启动脚本 `start_phoenix.py`：

```python
#!/usr/bin/env python3

from phoenix import launch_app

# 启动服务器
app = launch_app()

print("Phoenix服务器已启动，访问地址：http://localhost:6006")
print("按Ctrl+C停止服务器")

# 保持服务器运行
import time
while True:
    time.sleep(1)
```

然后运行：

```bash
python start_phoenix.py
```

### 方法2：使用项目提供的启动脚本

项目中已经包含了一个简化的启动脚本：

```bash
# 启动Phoenix服务器
./start_phoenix.sh
```

这个脚本会自动检查环境、安装依赖并启动服务器。

## 3. 配置环境变量

编辑 `.env` 文件，添加以下配置：

```env
# Phoenix配置
PHOENIX_ENDPOINT=http://localhost:6006/v1/traces
PHOENIX_PROJECT_NAME=youtu_agent
```

## 4. 测试Phoenix集成

创建一个测试脚本 `test_phoenix_integration.py`：

```python
#!/usr/bin/env python3

import os
from utu.tracing.setup import setup_otel_tracing

# 设置环境变量
os.environ["PHOENIX_ENDPOINT"] = "http://localhost:6006/v1/traces"
os.environ["PHOENIX_PROJECT_NAME"] = "youtu_agent"

# 初始化Phoenix跟踪
setup_otel_tracing(debug=True)

print("Phoenix跟踪已初始化！")
print("请访问 http://localhost:6006 查看跟踪数据")

# 创建一个简单的跟踪
from opentelemetry import trace

# 获取追踪器
tracer = trace.get_tracer(__name__)

# 创建一个跨度
with tracer.start_as_current_span("test_span"):
    print("执行测试操作...")

print("测试完成！请在Phoenix界面检查跟踪数据。")
```

运行测试脚本：

```bash
python test_phoenix_integration.py
```

## 5. 与项目集成

### 使用已有的Phoenix工具

项目中已经包含了Phoenix相关的工具类，可以直接使用：

```python
from utu.tracing.phoenix_utils import PhoenixUtils

# 创建Phoenix工具实例
phoenix_utils = PhoenixUtils(
    base_url="http://localhost:6006",
    project_name="youtu_agent"
)

# 获取跟踪URL
trace_url = phoenix_utils.get_trace_url_by_id("your_trace_id")
print(f"跟踪URL: {trace_url}")
```

### 启动项目并查看跟踪

正常启动项目，Phoenix会自动收集跟踪数据：

```bash
# 启动评测程序
./start_e2b_eval.sh
```

然后访问 http://localhost:6006 查看实时跟踪数据。

## 6. 高级配置

### 设置采样率

编辑代码中的跟踪设置，设置采样率：

```python
# 在setup_otel_tracing函数中添加采样器设置
from opentelemetry.sdk.trace.sampling import TraceIdRatioBased

sampler = TraceIdRatioBased(1.0)  # 100%采样率
OTEL_TRACING_PROVIDER = TracerProvider(
    resource=Resource({ResourceAttributes.PROJECT_NAME: project_name}),
    sampler=sampler
)
```

### 添加自定义属性

在代码中添加自定义跟踪属性：

```python
from opentelemetry import trace

# 获取当前跨度
current_span = trace.get_current_span()

# 添加自定义属性
current_span.set_attribute("user.id", "123")
current_span.set_attribute("app.version", "1.0.0")
```

## 7. 故障排除

### 问题：无法连接到Phoenix服务器

**解决方案**：
1. 确保Phoenix服务器正在运行
2. 检查端口是否正确（默认6006）
3. 验证防火墙设置

### 问题：没有看到跟踪数据

**解决方案**：
1. 确保环境变量配置正确
2. 检查日志是否有错误信息
3. 确认采样率设置

### 问题：Phoenix界面无法访问

**解决方案**：
1. 检查服务器是否在正确的端口上运行
2. 尝试使用不同的浏览器
3. 查看服务器日志

## 8. 参考文档

- [Phoenix官方文档](https://arize.com/docs/phoenix/)
- [Phoenix OpenTelemetry集成](https://arize.com/docs/phoenix/tracing/how-to-tracing/setup-tracing/setup-using-phoenix-otel/)
- [Phoenix GitHub仓库](https://github.com/Arize-ai/phoenix/)

## 9. 清理资源

当您完成测试后，可以停止Phoenix服务器：

```bash
# 按Ctrl+C停止命令行启动的服务器
```

或在Python脚本中使用简化的停止逻辑：

```python
# 在start_phoenix.py中
import signal
import sys

def signal_handler(sig, frame):
    print("正在停止Phoenix服务器...")
    sys.exit(0)

# 设置信号处理
signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)
```

对于使用 `launch_app()` 的脚本，当您按 Ctrl+C 时，应用会自动清理资源并退出。

---

现在您已经成功搭建了本地Phoenix环境，可以开始使用它来跟踪和调试您的应用程序了！