#!/bin/sh

# Tai 项目打包脚本
# 使用方法: sh manager.sh package

# 项目根目录
PROJECT_ROOT=$(pwd)
# 打包输出目录
PACKAGE_DIR="$PROJECT_ROOT/ReleasePackage"
# 压缩包名称
ZIP_NAME="Tai1.5.0.6.zip"

# 打印信息
log() {
    echo -e "[INFO] $1"
}

# 打印错误
error() {
    echo -e "[ERROR] $1"
    exit 1
}

# 清理旧的打包文件
cleanup() {
    log "清理旧的打包文件..."
    if [ -d "$PACKAGE_DIR" ]; then
        rm -rf "$PACKAGE_DIR"
    fi
    if [ -f "$PROJECT_ROOT/$ZIP_NAME" ]; then
        rm -f "$PROJECT_ROOT/$ZIP_NAME"
    fi
}

# 创建打包目录
create_package_dir() {
    log "创建打包目录..."
    mkdir -p "$PACKAGE_DIR"
}

# 复制文件到打包目录
copy_files() {
    log "复制文件到打包目录..."
    
    # 复制 UI 项目文件
    UI_RELEASE_DIR="$PROJECT_ROOT/UI/bin/Release"
    if [ -d "$UI_RELEASE_DIR" ]; then
        cp -r "$UI_RELEASE_DIR"/* "$PACKAGE_DIR/"
        log "UI 项目文件复制完成"
    else
        error "UI 项目 Release 目录不存在，请先在 IDE 中构建项目"
    fi
    
    # 复制 TaiBug 模块文件
    TAIBUG_RELEASE_DIR="$PROJECT_ROOT/TaiBug/bin/Release"
    if [ -d "$TAIBUG_RELEASE_DIR" ]; then
        cp -r "$TAIBUG_RELEASE_DIR"/* "$PACKAGE_DIR/"
        log "TaiBug 模块文件复制完成"
    else
        error "TaiBug 模块 Release 目录不存在，请先在 IDE 中构建项目"
    fi
    
    # 复制 Updater 模块文件
    UPDATER_RELEASE_DIR="$PROJECT_ROOT/Updater/bin/Release"
    if [ -d "$UPDATER_RELEASE_DIR" ]; then
        cp -r "$UPDATER_RELEASE_DIR"/* "$PACKAGE_DIR/"
        log "Updater 模块文件复制完成"
    else
        error "Updater 模块 Release 目录不存在，请先在 IDE 中构建项目"
    fi
    
    # 复制 WebExtensions 目录
    WEBEXTENSIONS_DIR="$PROJECT_ROOT/WebExtensions"
    if [ -d "$WEBEXTENSIONS_DIR" ]; then
        cp -r "$WEBEXTENSIONS_DIR" "$PACKAGE_DIR/"
        log "WebExtensions 目录复制完成"
    else
        error "WebExtensions 目录不存在"
    fi
    
    log "文件复制完成"
}

# 创建压缩包
create_zip() {
    log "创建压缩包..."
    
    # 检查是否安装了 zip
    if command -v zip >/dev/null 2>&1; then
        # 进入打包目录，然后创建压缩包
        cd "$PACKAGE_DIR" && zip -r "$PROJECT_ROOT/$ZIP_NAME" *
        # 回到项目根目录
        cd "$PROJECT_ROOT"
        if [ $? -ne 0 ]; then
            log "警告：创建压缩包失败，请手动创建压缩包"
        else
            log "压缩包创建成功: $PROJECT_ROOT/$ZIP_NAME"
        fi
    else
        log "警告：未找到压缩工具 (zip)，请手动创建压缩包"
        log "打包文件已准备就绪，位于: $PACKAGE_DIR"
    fi
}

# 清理临时文件
cleanup_package() {
    log "清理临时文件..."
    if [ -d "$PACKAGE_DIR" ]; then
        rm -rf "$PACKAGE_DIR"
    fi
    log "临时文件清理完成"
}

# 清理编译缓存
clean() {
    log "---\n开始清理编译缓存..."
    
    # 切换到项目根目录
    cd "$PROJECT_ROOT"
    
    # 清理 UI 项目的编译缓存
    UI_BIN_DIR="UI/bin"
    UI_OBJ_DIR="UI/obj"
    if [ -d "$UI_BIN_DIR" ]; then
        rm -rf "$UI_BIN_DIR"
        log "清理 UI/bin 目录"
    fi
    if [ -d "$UI_OBJ_DIR" ]; then
        rm -rf "$UI_OBJ_DIR"
        log "清理 UI/obj 目录"
    fi
    
    # 清理 TaiBug 项目的编译缓存
    TAIBUG_BIN_DIR="TaiBug/bin"
    TAIBUG_OBJ_DIR="TaiBug/obj"
    if [ -d "$TAIBUG_BIN_DIR" ]; then
        rm -rf "$TAIBUG_BIN_DIR"
        log "清理 TaiBug/bin 目录"
    fi
    if [ -d "$TAIBUG_OBJ_DIR" ]; then
        rm -rf "$TAIBUG_OBJ_DIR"
        log "清理 TaiBug/obj 目录"
    fi
    
    # 清理 Updater 项目的编译缓存
    UPDATER_BIN_DIR="Updater/bin"
    UPDATER_OBJ_DIR="Updater/obj"
    if [ -d "$UPDATER_BIN_DIR" ]; then
        rm -rf "$UPDATER_BIN_DIR"
        log "清理 Updater/bin 目录"
    fi
    if [ -d "$UPDATER_OBJ_DIR" ]; then
        rm -rf "$UPDATER_OBJ_DIR"
        log "清理 Updater/obj 目录"
    fi
    
    log "编译缓存清理完成！"
}

# 打包命令
package() {
    log "---\n开始打包流程..."
    cleanup
    create_package_dir
    copy_files
    create_zip
    # 检查是否创建了压缩包，如果没有创建，就不要清理临时目录
    if [ -f "$PROJECT_ROOT/$ZIP_NAME" ]; then
        cleanup_package
        log "打包完成！"
    else
        log "打包文件已准备就绪，位于: $PACKAGE_DIR"
        log "请手动创建压缩包，然后删除临时目录"
        log "打包流程完成！"
    fi
}

# 编译项目
build() {
    log "---\n开始编译项目..."
    
    # 切换到项目根目录
    cd "$PROJECT_ROOT"

    # 编译配置
    CONFIGURATION=$1
    if [ -z "$CONFIGURATION" ]; then
        CONFIGURATION="Debug"
    fi
    
    # 检查是否存在已编译的文件
    UI_EXE="UI/bin/$CONFIGURATION/Tai.exe"
    if [ -f "$UI_EXE" ]; then
        log "发现已编译的 $CONFIGURATION 版本，跳过编译步骤"
        log "如果需要重新编译，请执行 clean 后再次运行"
        log "编译成功！"
        return 0
    fi
    
    # 尝试使用不同的方法查找和执行 MSBuild
    MSBUILD_FOUND=false
    
    # 方法 1: 尝试使用系统路径中的 msbuild
    if command -v msbuild >/dev/null 2>&1; then
        log "使用系统路径中的 msbuild 编译项目..."
        msbuild Tai.sln -property:Configuration=$CONFIGURATION -property:"Platform=Any CPU"
        if [ $? -eq 0 ]; then
            MSBUILD_FOUND=true
        fi
    fi
    
    # 方法 2: 尝试使用常见的 Visual Studio MSBuild 路径
    if [ "$MSBUILD_FOUND" = false ]; then
        # 设置常见的 MSBuild 路径
        MSBUILD_PATHS=("/c/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/MSBuild/Current/Bin/MSBuild.exe" "/c/Program Files/Microsoft Visual Studio/2022/BuildTools/MSBuild/Current/Bin/MSBuild.exe")
        for MSBUILD_PATH in "${MSBUILD_PATHS[@]}"; do
            if [ -f "$MSBUILD_PATH" ]; then
                log "找到 MSBuild：$MSBUILD_PATH"
                log "使用 MSBuild 编译项目..."
                "$MSBUILD_PATH" --version
                "$MSBUILD_PATH" Tai.sln -property:Configuration=$CONFIGURATION -property:"Platform=Any CPU"
                if [ $? -eq 0 ]; then
                    MSBUILD_FOUND=true
                    break
                fi
            fi
        done
    fi
    
    # 方法 3: 尝试使用 dotnet 命令（作为后备）
    if [ "$MSBUILD_FOUND" = false ]; then
        if command -v dotnet >/dev/null 2>&1; then
            log "尝试使用 dotnet 命令编译项目..."
            dotnet build Tai.sln -c Release
            if [ $? -eq 0 ]; then
                MSBUILD_FOUND=true
            fi
        fi
    fi
    
    # 检查编译结果
    if [ -f "$UI_EXE" ]; then
        log "编译成功！"
        log "可执行文件位置: $UI_EXE"
    else
        # 如果所有编译方法都失败，提示用户手动编译
        log "自动编译失败，尝试了以下方法："
        log "1. 系统路径中的 msbuild"
        log "2. 常见 Visual Studio 安装路径中的 msbuild"
        log "3. dotnet 命令"
        log ""
        log "请手动在 Visual Studio 中编译项目："
        log "1. 打开 Tai.sln 解决方案"
        log "2. 选择 Release 配置"
        log "3. 构建整个解决方案"
        log "4. 构建完成后，再次运行此脚本"
        error "编译失败：自动编译失败，请手动在 Visual Studio 中编译项目"
    fi
}

# 本地调试运行
run() {
    log "---\n开始本地调试运行..."
    
    # 切换到项目根目录
    cd "$PROJECT_ROOT"
    
    # 检查 UI 项目的 Debug 版本是否存在
    UI_DEBUG_EXE="UI/bin/Debug/Tai.exe"
    if [ -f "$UI_DEBUG_EXE" ]; then
        log "运行 Debug 版本..."
        # 使用 cmd.exe /c 来运行可执行文件，避免权限问题
        "$UI_DEBUG_EXE"
        log "运行成功！"
        return 0
    fi
    
    # 如果 Debug 版本不存在，检查 Release 版本是否存在
    UI_RELEASE_EXE="UI/bin/Release/Tai.exe"
    if [ -f "$UI_RELEASE_EXE" ]; then
        log "Debug 版本不存在，运行 Release 版本..."
        # 使用 cmd.exe /c 来运行可执行文件，避免权限问题
        "UI_RELEASE_EXE$"
        log "运行成功！"
        return 0
    fi
    
    # 如果都不存在，提示用户手动编译项目
    log "未找到已编译的可执行文件"
    log "请先运行 sh manager.sh build 编译项目"
    error "运行失败：请先编译项目"
}

# 主函数
main() {
    case "$1" in
        build)
            build Debug
            ;;
        r|release)
            build Release
            ;;
        run)
            build Debug
            run
            ;;
        c|clean)
            clean
            ;;
        p|package)
            package
            ;;
        *)
            echo "使用方法: sh manager.sh [package|build|run|clean]"
            echo "  package: 打包项目"
            echo "  build: 编译项目"
            echo "  run: 本地调试运行"
            echo "  clean: 清理编译缓存"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
