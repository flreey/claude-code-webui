#!/bin/bash

# Claude Code Web UI 启动脚本
# 用法: ./start.sh [--build] [--host HOST] [--port PORT]

set -e

# 默认配置
DEFAULT_HOST="0.0.0.0"
DEFAULT_PORT="3001"
BUILD_FLAG=false

# 解析参数
HOST=$DEFAULT_HOST
PORT=$DEFAULT_PORT

while [[ $# -gt 0 ]]; do
  case $1 in
    --build)
      BUILD_FLAG=true
      shift
      ;;
    --host)
      HOST="$2"
      shift 2
      ;;
    --port)
      PORT="$2"
      shift 2
      ;;
    --help)
      echo "用法: $0 [选项]"
      echo "选项:"
      echo "  --build          重新构建应用"
      echo "  --host HOST      绑定主机地址 (默认: $DEFAULT_HOST)"
      echo "  --port PORT      绑定端口 (默认: $DEFAULT_PORT)"
      echo "  --help           显示此帮助信息"
      exit 0
      ;;
    *)
      echo "未知选项: $1"
      echo "使用 --help 查看帮助"
      exit 1
      ;;
  esac
done

echo "🚀 Claude Code Web UI 启动脚本"
echo "📍 主机: $HOST"
echo "🔌 端口: $PORT"

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未找到，请先安装 Node.js >= 20.0.0"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "❌ Node.js 版本过低，需要 >= 20.0.0，当前版本: $(node --version)"
    exit 1
fi

echo "✅ Node.js 版本: $(node --version)"

# 检查是否需要构建
if [ "$BUILD_FLAG" = true ] || [ ! -f "dist/claude-code-webui" ]; then
    echo "🔨 开始构建应用..."
    
    # 检查依赖
    if [ ! -d "frontend/node_modules" ]; then
        echo "📦 安装前端依赖..."
        cd frontend && npm ci && cd ..
    fi
    
    if [ ! -d "backend/node_modules" ]; then
        echo "📦 安装后端依赖..."
        cd backend && npm ci && cd ..
    fi
    
    # 构建应用
    if command -v make &> /dev/null && [ -f "Makefile" ]; then
        echo "🏗️ 使用 Makefile 构建..."
        make build-executable
    else
        echo "🏗️ 手动构建..."
        # 构建前端
        cd frontend && npm run build && cd ..
        
        # 复制前端文件
        rm -rf backend/static
        cp -r frontend/dist backend/static
        
        # 构建后端
        cd backend && npm run build && cd ..
        
        # 创建可执行文件
        mkdir -p dist
        cp -r backend/dist/* dist/
        mv dist/cli/node.js dist/claude-code-webui
        rmdir dist/cli 2>/dev/null || true
        chmod +x dist/claude-code-webui
    fi
    
    echo "✅ 构建完成"
fi

# 检查可执行文件
if [ ! -f "dist/claude-code-webui" ]; then
    echo "❌ 可执行文件不存在: dist/claude-code-webui"
    echo "💡 请使用 --build 选项重新构建"
    exit 1
fi

echo "🎯 启动应用..."
echo "🌐 访问地址: http://$HOST:$PORT"
echo "⏹️  按 Ctrl+C 停止服务"
echo ""

# 启动应用
node ./dist/claude-code-webui --host "$HOST" --port "$PORT"