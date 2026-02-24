#!/usr/bin/env python3
"""
E2B沙箱配置测试脚本
用于验证E2B依赖是否正确安装，以及E2B环境是否可以正常初始化
"""

import asyncio
import os
import sys

async def test_e2b_setup():
    """测试E2B沙箱设置"""
    print("=== E2B沙箱配置测试 ===")
    
    # 1. 检查环境变量
    print("\n1. 检查E2B API密钥...")
    e2b_api_key = os.getenv("E2B_API_KEY")
    if e2b_api_key:
        print(f"   ✅ E2B API密钥已设置: {e2b_api_key[:8]}...")
    else:
        print("   ❌ E2B_API_KEY环境变量未设置")
        print("   请访问 https://e2b.dev/docs/getting-started/api-key 获取API密钥")
        print("   并在.env文件中设置E2B_API_KEY=your-api-key")
    
    # 2. 检查E2B依赖
    print("\n2. 检查E2B依赖...")
    try:
        import e2b
        import e2b_code_interpreter
        print(f"   ✅ e2b已安装")
        print(f"   ✅ e2b_code_interpreter已安装")
    except ImportError as e:
        print(f"   ❌ E2B依赖未正确安装: {e}")
        print("   请运行: pip install -e '.[e2b]'")
        return False
    
    # 3. 测试E2B沙箱创建（如果有API密钥）
    if e2b_api_key and not e2b_api_key == "your-e2b-api-key-here":
        print("\n3. 测试E2B沙箱创建...")
        try:
            from e2b_code_interpreter import AsyncSandbox
            
            # 设置API密钥
            os.environ["E2B_API_KEY"] = e2b_api_key
            
            # 创建沙箱实例
            sandbox = await AsyncSandbox.create(template="code-interpreter-v1", timeout=30)
            print(f"   ✅ E2B沙箱创建成功: {sandbox.sandbox_id}")
            
            # 运行简单的Python代码
            print("   运行测试代码...")
            result = await sandbox.run_code("print('Hello from E2B sandbox!')")
            print(f"   ✅ 代码执行成功: {result.stdout.strip()}")
            
            # 清理资源
            await sandbox.kill()
            print("   ✅ 沙箱已清理")
            
        except Exception as e:
            print(f"   ❌ E2B沙箱测试失败: {e}")
            print("   请检查API密钥是否有效")
            return False
    else:
        print("\n3. 跳过E2B沙箱创建测试: 未设置有效API密钥")
    
    # 4. 检查项目结构
    print("\n4. 检查项目结构...")
    
    # 检查配置文件
    config_path = "./configs/eval/ww_e2b.yaml"
    if os.path.exists(config_path):
        print(f"   ✅ E2B评测配置文件存在: {config_path}")
    else:
        print(f"   ❌ E2B评测配置文件不存在: {config_path}")
    
    # 检查启动脚本
    script_path = "./start_e2b_eval.sh"
    if os.path.exists(script_path):
        print(f"   ✅ E2B启动脚本存在: {script_path}")
    else:
        print(f"   ❌ E2B启动脚本不存在: {script_path}")
    
    print("\n=== 测试完成 ===")
    return True

if __name__ == "__main__":
    success = asyncio.run(test_e2b_setup())
    sys.exit(0 if success else 1)
