#!/bin/bash

# 启动脚本：以沙箱形式运行WebWalker评测并记录总时长

# 颜色定义
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# 计时开始
echo -e "${YELLOW}=== 开始启动评测程序 ===${NC}"
START_TIME=$(date +%s)

# 设置工作目录
WORKDIR="/Users/a111/Desktop/code/youtu-agent"
cd "$WORKDIR" || {
    echo -e "${RED}错误：无法进入工作目录 $WORKDIR${NC}"
    exit 1
}

# 设置环境变量
echo -e "${GREEN}1. 设置环境变量...${NC}"

# 沙箱环境变量
export SANDBOX_BASE_URL="http://localhost:8848"
export SANDBOX_ACCESS_TOKEN="your-sandbox-token"

# 从.env文件加载LLM环境变量
echo -e "   - 从.env文件加载LLM配置..."
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
fi

# 显示环境变量摘要
echo -e "   - 沙箱服务URL: ${SANDBOX_BASE_URL}"
echo -e "   - LLM模型: ${UTU_LLM_MODEL}"
echo -e "   - 评测配置: ww_sandbox"

# 检查Python环境
echo -e "${GREEN}2. 检查Python环境...${NC}"
python --version
if [ $? -ne 0 ]; then
    echo -e "${RED}错误：Python未找到${NC}"
    exit 1
fi

# 检查依赖
echo -e "${GREEN}3. 检查必要依赖...${NC}"
pip list | grep -E "utu|httpx|pydantic"

# 启动评测程序
echo -e "${GREEN}4. 启动沙箱评测程序...${NC}"
echo -e "${YELLOW}   评测配置：ww_sandbox${NC}"
echo -e "${YELLOW}   数据集：WebWalkerQA${NC}"
echo -e "${YELLOW}   并发数：50${NC}"
echo -e "${YELLOW}   开始时间：$(date)${NC}"

# 运行评测程序
python scripts/run_eval.py --config_name ww_sandbox

# 计时结束
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
HOURS=$((DURATION / 3600))
MINUTES=$(( (DURATION % 3600) / 60 ))
SECONDS=$((DURATION % 60))

# 显示结果
echo -e "${GREEN}=== 评测程序结束 ===${NC}"
echo -e "${GREEN}   结束时间：$(date)${NC}"
echo -e "${GREEN}   总时长：${HOURS}小时 ${MINUTES}分钟 ${SECONDS}秒${NC}"

# 保存结果到日志文件
LOG_FILE="sandbox_eval_log_$(date +%Y%m%d_%H%M%S).txt"
echo "=== 沙箱评测日志 ===" > "$LOG_FILE"
echo "开始时间: $(date -r $START_TIME)" >> "$LOG_FILE"
echo "结束时间: $(date -r $END_TIME)" >> "$LOG_FILE"
echo "总时长: ${HOURS}小时 ${MINUTES}分钟 ${SECONDS}秒" >> "$LOG_FILE"
echo "沙箱URL: ${SANDBOX_BASE_URL}" >> "$LOG_FILE"
echo "LLM模型: ${UTU_LLM_MODEL}" >> "$LOG_FILE"
echo "评测配置: ww_sandbox" >> "$LOG_FILE"
echo "日志文件已保存到: $LOG_FILE"
