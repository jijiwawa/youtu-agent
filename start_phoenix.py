#!/usr/bin/env python3

from phoenix import launch_app

print("正在启动Phoenix服务器...")
app = launch_app()
print("Phoenix服务器已启动！")
print("访问地址: http://localhost:6006")

# 保持运行
import time
while True:
    time.sleep(1)
