#!/bin/bash

# 启动脚本：以E2B沙箱形式运行WebWalker评测并记录总时长

# 颜色定义
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# 计时开始
echo -e "${YELLOW}=== 开始启动E2B沙箱评测程序 ===${NC}"
START_TIME=$(date +%s)

# 设置工作目录
WORKDIR="/Users/a111/Desktop/code/youtu-agent"
cd "$WORKDIR" || {
    echo -e "${RED}错误：无法进入工作目录 $WORKDIR${NC}"
    exit 1
}

# 设置环境变量
echo -e "${GREEN}1. 设置环境变量...${NC}"

# 从.env文件加载环境变量
echo -e "   - 从.env文件加载配置..."
if [ -f ".env" ]; then
    # 读取并导出LLM相关的环境变量
    export UTU_LLM_TYPE=$(grep -E '^UTU_LLM_TYPE=' .env | cut -d= -f2 | tr -d ' "')
    export UTU_LLM_MODEL=$(grep -E '^UTU_LLM_MODEL=' .env | cut -d= -f2 | tr -d ' "')
    export UTU_LLM_BASE_URL=$(grep -E '^UTU_LLM_BASE_URL=' .env | cut -d= -f2 | tr -d ' "')
    export UTU_LLM_API_KEY=$(grep -E '^UTU_LLM_API_KEY=' .env | cut -d= -f2 | tr -d ' "')
    
    # 读取并导出评委LLM相关的环境变量
    export JUDGE_LLM_TYPE=$(grep -E '^JUDGE_LLM_TYPE=' .env | cut -d= -f2 | tr -d ' "')
    export JUDGE_LLM_MODEL=$(grep -E '^JUDGE_LLM_MODEL=' .env | cut -d= -f2 | tr -d ' "')
    export JUDGE_LLM_BASE_URL=$(grep -E '^JUDGE_LLM_BASE_URL=' .env | cut -d= -f2 | tr -d ' "')
    export JUDGE_LLM_API_KEY=$(grep -E '^JUDGE_LLM_API_KEY=' .env | cut -d= -f2 | tr -d ' "')
    
    # 读取并导出数据库环境变量
    export UTU_DB_URL=$(grep -E '^UTU_DB_URL=' .env | cut -d= -f2 | tr -d ' "')
    
    # 读取并导出E2B沙箱环境变量
    export E2B_API_KEY=$(grep -E '^E2B_API_KEY=' .env | cut -d= -f2 | tr -d ' "')
    
    # 读取并导出搜索工具环境变量
    export SERPER_API_KEY=$(grep -E '^SERPER_API_KEY=' .env | cut -d= -f2 | tr -d ' "')
    export JINA_API_KEY=$(grep -E '^JINA_API_KEY=' .env | cut -d= -f2 | tr -d ' "')
    
    # 验证E2B API密钥
    if [ -z "$E2B_API_KEY" ] || [ "$E2B_API_KEY" = "your-e2b-api-key-here" ]; then
        echo -e "${RED}错误：E2B_API_KEY环境变量未设置或使用默认值${NC}"
        echo -e "${YELLOW}请访问 https://e2b.dev/docs/getting-started/api-key 获取API密钥并在.env文件中配置${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}警告：未找到.env文件，使用默认值${NC}"
    # 默认LLM环境变量
    export UTU_LLM_TYPE="chat.completions"
    export UTU_LLM_MODEL="glm-4-flash"
    export UTU_LLM_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
    export UTU_LLM_API_KEY="be2ea5e8b122437a868326cbddd2eb8a.UP3dANdh9Ss4H5zv"
    
    # 默认评委LLM环境变量
    export JUDGE_LLM_TYPE="chat.completions"
    export JUDGE_LLM_MODEL="glm-4-flash"
    export JUDGE_LLM_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
    export JUDGE_LLM_API_KEY="be2ea5e8b122437a868326cbddd2eb8a.UP3dANdh9Ss4H5zv"
    
    # 默认数据库环境变量
    export UTU_DB_URL="sqlite:///test.db"
    
    # 默认搜索工具环境变量
    export SERPER_API_KEY="3b1bc2dba25cef8d16bcab1c6c0c001954919f29"
    export JINA_API_KEY="jina_5ed65630426841ccb45bc97451946e6d_xQ-6uXcO5Fjce01uRz3AbrwJ-38"
    
    # 提示用户设置E2B API密钥
    echo -e "${YELLOW}警告：请确保已在.env文件中设置E2B_API_KEY环境变量${NC}"
    echo -e "${YELLOW}注册并获取API密钥：https://e2b.dev/docs/getting-started/api-key${NC}"
fi

# 显示环境变量摘要
echo -e "   - LLM模型: ${UTU_LLM_MODEL}"
echo -e "   - 评测配置: ww_e2b"
echo -e "   - E2B API密钥: ${E2B_API_KEY:0:8}...${NC}"

# 检查Python环境
echo -e "${GREEN}2. 检查Python环境...${NC}"
python --version
if [ $? -ne 0 ]; then
    echo -e "${RED}错误：Python未找到${NC}"
    exit 1
fi

# 检查依赖
echo -e "${GREEN}3. 检查必要依赖...${NC}"
pip list | grep -E "utu|e2b|e2b-code-interpreter"

# 启动评测程序
echo -e "${GREEN}4. 启动E2B沙箱评测程序...${NC}"
echo -e "${YELLOW}   评测配置：ww_e2b${NC}"
echo -e "${YELLOW}   数据集：WebWalkerQA${NC}"
echo -e "${YELLOW}   并发数：50${NC}"
echo -e "${YELLOW}   开始时间：$(date)${NC}"

# 运行评测程序
python scripts/run_eval.py --config_name ww_e2b

# 计时结束
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
HOURS=$((DURATION / 3600))
MINUTES=$(( (DURATION % 3600) / 60 ))
SECONDS=$((DURATION % 60))

# 显示结果
echo -e "${GREEN}=== 评测程序结束 ===${NC}"
echo -e "${GREEN}   结束时间：$(date)${NC}"
echo -e "${GREEN}   总时长：${HOURS}小时${MINUTES}分钟${SECONDS}秒${NC}"

# 显示结果路径
echo -e "${GREEN}   评测结果：results/${exp_id}${NC}"

if [ -n "$exp_id" ]; then
    echo -e "${GREEN}   结果可视化：frontend/exp_analysis/src/app/${exp_id}${NC}"
fi
