# SandboxFusion 运行指南

## 项目介绍
SandboxFusion 是字节开源的代码执行沙箱框架，支持多语言代码执行和安全隔离。

## 系统要求
- macOS/Linux
- Python 3.13+
- Rust 1.90+ (用于编译 pydantic-core)

## 安装步骤

### 1. 克隆仓库
```bash
git clone https://github.com/bytedance/SandboxFusion.git
cd SandboxFusion
```

### 2. 安装依赖

#### 2.1 安装 Rust 编译器（如果未安装）
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
```

#### 2.2 安装 Python 依赖
```bash
# 使用国内镜像源加速下载
pip install pydantic transformers aiofiles databases fastapi uvicorn structlog requests tenacity psutil safetensors -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 3. 创建必要的目录
```bash
mkdir -p docs/build
echo '<html><body><h1>SandboxFusion API</h1><p>API文档正在建设中...</p></body></html>' > docs/build/index.html
```

### 4. 启动服务
```bash
# 使用2个worker进程启动服务
python -m uvicorn sandbox.server.server:app --host 0.0.0.0 --port 8000 --workers 2
```

## API 调用示例

### Python代码执行
```python
import requests

url = "http://localhost:8000/run_code"

# 测试简单的Python代码
test_data = {
    "code": "print('Hello, SandboxFusion!')",
    "language": "python",
    "compile_timeout": 10,
    "run_timeout": 10
}

response = requests.post(url, json=test_data)
result = response.json()
print(f"输出: {result.get('stdout')}")
```

### C++代码执行
```python
test_data = {
    "code": "#include <iostream>\nint main() { std::cout << \"Hello from C++!\" << std::endl; return 0; }",
    "language": "cpp",
    "compile_timeout": 10,
    "run_timeout": 10
}

response = requests.post(url, json=test_data)
result = response.json()
print(f"输出: {result.get('stdout')}")
```

## 常见问题及解决方案

### 1. pydantic-core 构建失败
**错误信息**: `TypeError: ForwardRef._evaluate() missing 1 required keyword-only argument: 'recursive_guard'`

**解决方案**: 安装最新版本的 pydantic 和 pydantic-core
```bash
pip install pydantic>=2.12.0 pydantic-core>=2.41.0
```

### 2. 缺失模块错误
**错误信息**: `ModuleNotFoundError: No module named 'databases'`

**解决方案**: 安装缺失的模块
```bash
pip install 缺失的模块名
```

### 3. 文档目录不存在
**错误信息**: `RuntimeError: Directory '/path/to/SandboxFusion/docs/build' does not exist`

**解决方案**: 创建文档目录并添加默认页面
```bash
mkdir -p docs/build
echo '<html><body><h1>SandboxFusion API</h1></body></html>' > docs/build/index.html
```

### 4. 下载速度慢
**解决方案**: 使用国内镜像源加速下载
```bash
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple 包名
```

### 5. 端口占用
**解决方案**: 更换端口或杀死占用端口的进程
```bash
# 查看端口占用
lsof -i :8000

# 杀死进程
kill -9 进程ID

# 使用其他端口启动
python -m uvicorn sandbox.server.server:app --host 0.0.0.0 --port 8080
```

## 最佳实践

1. **使用虚拟环境**: 建议使用虚拟环境隔离依赖
   ```bash
   python -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate  # Windows
   ```

2. **定期更新依赖**: 定期更新依赖包以获得最新功能和修复
   ```bash
   pip install --upgrade pydantic transformers
   ```

3. **监控服务**: 生产环境建议使用进程管理工具如 PM2 或 Supervisor 管理服务

4. **安全配置**: 生产环境中建议配置防火墙和访问控制

## 测试脚本

创建测试脚本 `test_sandbox.py`:
```python
import requests

def test_python_code():
    url = "http://localhost:8000/run_code"
    
    test_cases = [
        ("print('Hello')", "Hello"),
        ("print(1 + 2)", "3"),
        ("for i in range(3): print(i)", "0\n1\n2")
    ]
    
    print("=== Python代码执行测试 ===")
    
    for code, expected in test_cases:
        data = {
            "code": code,
            "language": "python",
            "compile_timeout": 10,
            "run_timeout": 10
        }
        
        response = requests.post(url, json=data)
        
        if response.status_code == 200:
            result = response.json()
            stdout = result.get('stdout', '').strip()
            print(f"代码: {code}")
            print(f"预期: {expected}")
            print(f"实际: {stdout}")
            print(f"状态: {'通过' if stdout == expected else '失败'}")
        else:
            print(f"请求失败: {response.status_code}")
        
        print("-" * 50)

if __name__ == "__main__":
    test_python_code()
```

运行测试:
```bash
python test_sandbox.py
```

## 总结

通过以上步骤，您应该能够成功安装和运行 SandboxFusion 服务。如果遇到问题，请参考"常见问题及解决方案"部分。

## 更新记录

- 2026-02-26: 首次创建，记录了完整的安装和配置过程
- 2026-02-26: 增加了API调用示例和测试脚本
- 2026-02-26: 补充了常见问题和解决方案