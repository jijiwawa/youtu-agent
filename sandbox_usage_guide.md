# Youtu-Agent 沙箱环境使用指南

## 1. 沙箱环境类型

Youtu-Agent 支持多种沙箱环境，主要分为两类：

### 云沙箱环境（推荐）
- **E2BEnv**：用于代码执行和文件操作任务
- **BrowserE2BEnv**：用于网页自动化和浏览器交互任务
- **SandboxEnv**：远程会话式沙箱环境

### 本地沙箱环境（开发用）
- **ShellLocalEnv**：本地文件系统隔离工作区
- **BrowserEnv**：基于Docker的浏览器环境

## 2. 沙箱配置方式

### 2.1 基本配置结构

在 YAML 配置文件中定义沙箱环境：

```yaml
# @package _global_
defaults:
  - /model/base@model
  - _self_

agent:
  name: sandbox-agent
  instructions: "You are an assistant using sandbox tools."

env:
  name: sandbox  # 沙箱类型
  config:
    sandbox_type: "envscale"  # 沙箱实现类型
    base_url: "http://localhost:8848"  # 沙箱服务URL
    access_token: "your-token"  # 访问令牌
    run_id_source: "explicit"  # 会话ID来源
    run_id: "test-run-123"  # 显式会话ID
    data_dir: "path/to/data"  # 包含工具定义的目录
    timeout: 60  # 请求超时时间
```

### 2.2 关键配置参数

| 参数名 | 说明 | 示例值 |
|--------|------|--------|
| `sandbox_type` | 沙箱实现类型（如envscale） | "envscale" |
| `base_url` | 沙箱服务API基础URL | "http://localhost:8848" |
| `access_token` | 沙箱服务访问令牌 | "your-secret-token" |
| `run_id_source` | 会话ID来源（trace_id或explicit） | "explicit" |
| `run_id` | 显式会话ID（当run_id_source="explicit"时需要） | "test-run-123" |
| `data_dir` | 包含interface_plan.json的目录 | "path/to/sandbox/data" |
| `interface_plan_path` | tool定义文件路径 | "path/to/interface_plan.json" |
| `timeout` | 请求超时时间（秒） | 60 |

## 3. 启动沙箱的命令

### 3.1 使用 cli_chat.py 启动

使用项目提供的 CLI 脚本启动带有沙箱环境的智能体：

```bash
# 使用沙箱示例配置
python scripts/cli_chat.py --config_name sandbox/it_asset_demo

# 使用自定义沙箱配置
python scripts/cli_chat.py --config path/to/your/sandbox_config.yaml
```

### 3.2 环境变量配置

在 `.env` 或 `.env.full` 文件中配置沙箱相关环境变量：

```bash
# 沙箱服务URL
SANDBOX_BASE_URL=http://localhost:8848
# 沙箱访问令牌
SANDBOX_ACCESS_TOKEN=your-secret-token
# 其他沙箱配置
...
```

## 4. 沙箱工具定义

沙箱环境使用 `interface_plan.json` 文件定义可用工具：

```json
[
  {
    "name": "query_appointment",
    "doc": "查询预约记录",
    "returns": "预约记录列表",
    "params": [
      {
        "name": "customer_id",
        "type_hint": "str",
        "description": "客户ID"
      },
      {
        "name": "date",
        "type_hint": "Optional[str]",
        "description": "预约日期（可选）"
      }
    ]
  },
  {
    "name": "update_appointment",
    "doc": "更新预约记录",
    "returns": "更新结果",
    "params": [
      {
        "name": "appointment_id",
        "type_hint": "str",
        "description": "预约ID"
      },
      {
        "name": "status",
        "type_hint": "str",
        "description": "新状态"
      }
    ]
  }
]
```

## 5. 示例：使用云沙箱环境

### 5.1 E2B 云沙箱配置示例

```yaml
# @package _global_
defaults:
  - /tools/e2b/python_executor@toolkits.PythonTool
  - /tools/e2b/bash@toolkits.BashTool
  - /tools/e2b/file_edit@toolkits.FileTool
  - _self_

env:
  name: e2b
  config:
    request_timeout: 5

agent:
  name: e2b-agent
  instructions: "You are an assistant that can execute code."
```

### 5.2 启动 E2B 沙箱命令

```bash
# 使用 E2B Python 沙箱配置
python scripts/cli_chat.py --config_name e2b/e2b_python

# 使用 E2B 浏览器沙箱配置
python scripts/cli_chat.py --config_name e2b/e2b_browser
```

## 6. 注意事项

1. **安全性**：推荐使用云沙箱环境（E2BEnv、BrowserE2BEnv），提供更好的隔离性和安全性

2. **沙箱服务**：SandboxEnv 需要一个运行中的沙箱服务，确保 `base_url` 指向正确的沙箱服务地址

3. **工具定义**：确保 `interface_plan.json` 文件包含正确的工具定义，沙箱环境会基于此加载可用工具

4. **权限配置**：根据沙箱服务的要求，配置正确的访问令牌和权限

5. **版本兼容性**：确保使用与沙箱服务版本兼容的 Youtu-Agent 版本

## 7. 相关文件

- `utu/env/sandbox_env.py`：沙箱环境实现
- `configs/agents/examples/sandbox/it_asset_demo.yaml`：沙箱配置示例
- `scripts/cli_chat.py`：智能体启动脚本
- `.env.example` 和 `.env.full`：环境变量配置示例

通过以上步骤，你可以成功配置和使用 Youtu-Agent 的沙箱环境来运行智能体。