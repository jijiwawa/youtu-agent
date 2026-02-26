#!/bin/bash

# 启动本地Phoenix服务器

# 设置颜色
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

# 检查Python环境
if ! command -v python &> /dev/null; then
    echo -e "${RED}错误：Python未安装！${NC}"
    exit 1
fi

# 检查Phoenix是否安装
if ! python -c "import phoenix" &> /dev/null; then
    echo -e "${YELLOW}警告：Phoenix未安装，正在安装...${NC}"
    pip install arize-phoenix
fi

# 创建项目内工作目录
WORKING_DIR="$(pwd)/.phoenix"
mkdir -p "$WORKING_DIR"

# 检查start_phoenix.py脚本是否存在
if [ -f "start_phoenix.py" ]; then
    echo -e "${GREEN}使用start_phoenix.py启动Phoenix服务器...${NC}"
    
    # 启动Phoenix服务器
    python start_phoenix.py
    
else
    echo -e "${RED}错误：start_phoenix.py脚本不存在！${NC}"
    echo -e "${YELLOW}正在尝试创建脚本...${NC}"
    
    # 创建简单的启动脚本
    cat > start_phoenix.py << 'EOF'
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
EOF
    
    chmod +x start_phoenix.py
    echo -e "${GREEN}已创建start_phoenix.py脚本，正在启动...${NC}"
    python start_phoenix.py
fi