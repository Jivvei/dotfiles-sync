#!/bin/bash

# 项目启动器脚本
# 智能检测和启动项目

echo "🚀 项目启动器"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查当前目录或项目目录
PROJECT_DIR="${1:-$(pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || PROJECT_DIR="$HOME/projects"

echo "📁 当前目录: $PROJECT_DIR"
echo ""

# 智能检测项目类型
detect_project_type() {
    if [ -f "package.json" ]; then
        echo "📦 检测到 Node.js 项目"
        return 1
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "Pipfile" ]; then
        echo "🐍 检测到 Python 项目"  
        return 2
    elif [ -f "Cargo.toml" ]; then
        echo "🦀 检测到 Rust 项目"
        return 3
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "☕ 检测到 Java 项目"
        return 4
    elif [ -f "docker-compose.yml" ] || [ -f "Dockerfile" ]; then
        echo "🐳 检测到 Docker 项目"
        return 5
    elif [ -f "go.mod" ]; then
        echo "🔵 检测到 Go 项目"
        return 6
    elif [ -d ".git" ]; then
        echo "📋 检测到 Git 仓库"
        return 7
    else
        echo "📂 通用项目目录"
        return 0
    fi
}

# 调用检测函数
detect_project_type
project_type=$?

echo ""
echo "选择操作:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

case $project_type in
    1) # Node.js
        echo "1) 📦 npm install      - 安装依赖"
        echo "2) 🚀 npm start        - 启动项目"
        echo "3) 🔧 npm run dev      - 开发模式"
        echo "4) 🧪 npm test         - 运行测试"
        echo "5) 📊 npm run build    - 构建项目"
        echo "6) 📱 开发环境设置     - 创建开发窗口"
        ;;
    2) # Python
        echo "1) 🐍 创建虚拟环境     - python -m venv venv"
        echo "2) 📦 安装依赖         - pip install -r requirements.txt"
        echo "3) 🚀 运行主程序       - python main.py"
        echo "4) 🧪 运行测试         - pytest"
        echo "5) 📊 Django服务器     - python manage.py runserver"
        echo "6) 📱 开发环境设置     - 创建Python开发窗口"
        ;;
    3) # Rust
        echo "1) 🦀 构建项目         - cargo build"
        echo "2) 🚀 运行项目         - cargo run"
        echo "3) 🧪 运行测试         - cargo test"
        echo "4) 📊 发布构建         - cargo build --release"
        echo "5) 🔍 检查代码         - cargo check"
        echo "6) 📱 开发环境设置     - 创建Rust开发窗口"
        ;;
    4) # Java
        echo "1) ☕ Maven构建        - mvn compile"
        echo "2) 🚀 Maven运行        - mvn exec:java"
        echo "3) 🧪 Maven测试        - mvn test"
        echo "4) 📊 Gradle构建       - ./gradlew build"
        echo "5) 🔧 清理项目         - mvn clean"
        echo "6) 📱 开发环境设置     - 创建Java开发窗口"
        ;;
    5) # Docker
        echo "1) 🐳 构建镜像         - docker-compose build"
        echo "2) 🚀 启动服务         - docker-compose up"
        echo "3) 📊 后台启动         - docker-compose up -d"
        echo "4) 🛑 停止服务         - docker-compose down"
        echo "5) 📋 查看日志         - docker-compose logs"
        echo "6) 📱 Docker环境设置   - 创建Docker监控窗口"
        ;;
    6) # Go
        echo "1) 🔵 构建项目         - go build"
        echo "2) 🚀 运行项目         - go run ."
        echo "3) 🧪 运行测试         - go test"
        echo "4) 📦 下载依赖         - go mod download"
        echo "5) 🔧 整理依赖         - go mod tidy"
        echo "6) 📱 开发环境设置     - 创建Go开发窗口"
        ;;
    7) # Git 仓库
        echo "1) 📋 Git状态          - git status"
        echo "2) 📈 Git日志          - git log --oneline"
        echo "3) 🌿 分支列表         - git branch -a"
        echo "4) 📥 拉取更新         - git pull"
        echo "5) 📤 推送代码         - git push"
        echo "6) 📱 Git环境设置      - 创建Git管理窗口"
        ;;
    *) # 通用
        echo "1) 📁 浏览目录         - ls -la"
        echo "2) 🔍 查找文件         - find . -name"
        echo "3) 📝 编辑文件         - vim/nano"
        echo "4) 🔧 创建新项目       - 初始化项目结构"
        echo "5) 📋 项目模板         - 选择项目模板"
        echo "6) 📱 通用环境设置     - 创建开发窗口"
        ;;
esac

echo "0) ❌ 取消"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "请选择操作 [0-6]: " choice

# 执行对应操作
execute_action() {
    case $project_type in
        1) # Node.js
            case $choice in
                1) tmux send-keys "npm install" Enter ;;
                2) tmux send-keys "npm start" Enter ;;
                3) tmux send-keys "npm run dev" Enter ;;
                4) tmux send-keys "npm test" Enter ;;
                5) tmux send-keys "npm run build" Enter ;;
                6) setup_nodejs_env ;;
            esac
            ;;
        2) # Python
            case $choice in
                1) tmux send-keys "python3 -m venv venv && source venv/bin/activate" Enter ;;
                2) tmux send-keys "pip install -r requirements.txt" Enter ;;
                3) tmux send-keys "python main.py" Enter ;;
                4) tmux send-keys "pytest" Enter ;;
                5) tmux send-keys "python manage.py runserver" Enter ;;
                6) setup_python_env ;;
            esac
            ;;
        3) # Rust
            case $choice in
                1) tmux send-keys "cargo build" Enter ;;
                2) tmux send-keys "cargo run" Enter ;;
                3) tmux send-keys "cargo test" Enter ;;
                4) tmux send-keys "cargo build --release" Enter ;;
                5) tmux send-keys "cargo check" Enter ;;
                6) setup_rust_env ;;
            esac
            ;;
        5) # Docker
            case $choice in
                1) tmux send-keys "docker-compose build" Enter ;;
                2) tmux send-keys "docker-compose up" Enter ;;
                3) tmux send-keys "docker-compose up -d" Enter ;;
                4) tmux send-keys "docker-compose down" Enter ;;
                5) tmux send-keys "docker-compose logs -f" Enter ;;
                6) setup_docker_env ;;
            esac
            ;;
        6) # 通用环境设置
            tmux rename-window 'DEV'
            tmux split-window -h -c "$PROJECT_DIR"
            tmux split-window -v -c "$PROJECT_DIR"
            tmux select-pane -t 0
            ;;
    esac
}

# 环境设置函数
setup_nodejs_env() {
    tmux rename-window 'NODE'
    tmux split-window -h -c "$PROJECT_DIR"
    tmux send-keys -t 1 "npm run dev" Enter
    tmux split-window -v -c "$PROJECT_DIR"
    tmux send-keys -t 2 "npm test -- --watch" Enter
    tmux select-pane -t 0
}

setup_python_env() {
    tmux rename-window 'PYTHON'
    tmux split-window -h -c "$PROJECT_DIR"
    tmux send-keys -t 1 "source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate" Enter
    tmux split-window -v -c "$PROJECT_DIR"
    tmux select-pane -t 0
}

setup_rust_env() {
    tmux rename-window 'RUST'
    tmux split-window -h -c "$PROJECT_DIR"
    tmux send-keys -t 1 "cargo watch -x run" Enter
    tmux split-window -v -c "$PROJECT_DIR"
    tmux send-keys -t 2 "cargo test" Enter
    tmux select-pane -t 0
}

setup_docker_env() {
    tmux rename-window 'DOCKER'
    tmux new-window -n 'LOGS' -c "$PROJECT_DIR"
    tmux send-keys "docker-compose logs -f" Enter
    tmux split-window -h
    tmux send-keys "watch -n 2 docker ps" Enter
    tmux select-window -t 'DOCKER'
}

if [ "$choice" != "0" ] && [ "$choice" -ge 1 ] && [ "$choice" -le 6 ]; then
    echo "🔄 执行操作..."
    execute_action
    echo "✅ 操作完成"
else
    echo "❌ 已取消"
fi

echo ""
echo "按任意键继续..."
read 