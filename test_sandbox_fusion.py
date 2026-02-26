#!/usr/bin/env python3

"""
SandboxFusion测试脚本
验证SandboxFusion是否正常工作，并测试基本功能
"""

import sys
import os
from sandbox_fusion import run_code, RunCodeRequest


def test_sandbox_fusion():
    """测试SandboxFusion基本功能"""
    print("=== SandboxFusion测试开始 ===")
    
    # 检查环境变量是否配置
    print(f"当前工作目录: {os.getcwd()}")
    
    try:
        # 运行简单的Python代码
        print("\n1. 测试运行简单Python代码:")
        code = "print('Hello from SandboxFusion!')\nimport sys\nprint(f'Python版本: {sys.version}')"
        
        # 创建RunCodeRequest对象
        request = RunCodeRequest(
            code=code,
            language="python",
            compile_timeout=10,
            run_timeout=10,
            stdin=None,
            files={},
            fetch_files=[]
        )
        
        # 调用run_code函数
        result = run_code(request)
        
        print(f"执行状态: {result.status}")
        
        # 处理编译结果
        if result.compile_result:
            print(f"编译状态: {result.compile_result.status}")
            if result.compile_result.stdout:
                print(f"编译输出: {result.compile_result.stdout}")
            if result.compile_result.stderr:
                print(f"编译错误: {result.compile_result.stderr}")
        
        # 处理运行结果
        if result.run_result:
            print(f"运行状态: {result.run_result.status}")
            if result.run_result.stdout:
                print(f"运行输出: {result.run_result.stdout}")
            if result.run_result.stderr:
                print(f"运行错误: {result.run_result.stderr}")
        
        if result.status.value == "Success":
            print("✓ 简单Python代码执行成功")
        else:
            print("✗ 简单Python代码执行失败")
            
        # 运行更复杂的代码
        print("\n2. 测试运行复杂Python代码:")
        complex_code = """
import os
import json

# 创建测试文件
with open('test.json', 'w') as f:
    json.dump({'message': 'Hello SandboxFusion!'}, f)

# 读取测试文件
with open('test.json', 'r') as f:
    data = json.load(f)
    print(f"读取的数据: {data}")

# 列出目录内容
print(f"\n当前目录内容: {os.listdir('.')}")

print("测试完成！")
"""
        
        # 创建复杂代码的请求
        complex_request = RunCodeRequest(
            code=complex_code,
            language="python",
            compile_timeout=15,
            run_timeout=30,
            stdin=None,
            files={},
            fetch_files=["test.json"]  # 下载创建的文件
        )
        
        # 调用run_code函数
        complex_result = run_code(complex_request)
        
        print(f"执行状态: {complex_result.status}")
        
        # 处理编译结果
        if complex_result.compile_result:
            print(f"编译状态: {complex_result.compile_result.status}")
            if complex_result.compile_result.stderr:
                print(f"编译错误: {complex_result.compile_result.stderr}")
        
        # 处理运行结果
        if complex_result.run_result:
            print(f"运行状态: {complex_result.run_result.status}")
            if complex_result.run_result.stdout:
                print(f"运行输出: {complex_result.run_result.stdout}")
            if complex_result.run_result.stderr:
                print(f"运行错误: {complex_result.run_result.stderr}")
        
        # 处理下载的文件
        if complex_result.files:
            print(f"\n下载的文件: {list(complex_result.files.keys())}")
            if "test.json" in complex_result.files:
                import base64
                import json
                # 解码base64编码的文件内容
                file_content = base64.b64decode(complex_result.files["test.json"]).decode('utf-8')
                print(f"test.json内容: {json.loads(file_content)}")
        
        if complex_result.status.value == "Success":
            print("✓ 复杂Python代码执行成功")
        else:
            print("✗ 复杂Python代码执行失败")
            
    except Exception as e:
        print(f"\n错误: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    print("\n=== SandboxFusion测试完成 ===")
    return True


if __name__ == "__main__":
    success = test_sandbox_fusion()
    sys.exit(0 if success else 1)
