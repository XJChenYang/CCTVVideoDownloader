<h1 align="center">央视频下载器</h1>
<p align="center" class="shields">
    <a href="https://github.com/letr007/CCTVVideoDownloader/issues" style="text-decoration:none">
        <img src="https://img.shields.io/github/issues/letr007/CCTVVideoDownloader.svg" alt="GitHub issues"/>
    </a>
    <a href="https://github.com/letr007/CCTVVideoDownloader" style="text-decoration:none" >
        <img src="https://img.shields.io/github/stars/letr007/CCTVVideoDownloader.svg" alt="GitHub stars"/>
    </a>
    <a href="https://github.com/letr007/CCTVVideoDownloader" style="text-decoration:none" >
        <img src="https://img.shields.io/github/forks/letr007/CCTVVideoDownloader.svg" alt="GitHub forks"/>
    </a>
</p>

欢迎使用央视频下载器！该程序允许您从[央视网](https://tv.cctv.com)获取视频内容，并支持多线程处理。以下是该程序的一些主要功能和使用说明。

## :white_check_mark:功能特点

- 获取节目列表信息
- 支持多线程处理
- 支持从链接中解析视频ID
- 支持多选视频的批量下载流水线（下载-拼接-解密自动串联）
- 跳过已存在的分片文件以提升容错性，便于断点续传
- 下载与列表界面优化，增加交互提示

## :zap:如何运行

1. **获取可执行文件**：直接使用 `artifacts/CCTVVideoDownloader-x64-Release` 中的打包目录（或自行编译后运行 `bin/Release/CCTVVideoDownloader.exe`）。
2. **运行程序**：双击可执行文件启动，界面会自动加载频道与栏目列表。

### 源码快速运行（git clone 后直接启动）

1. 准备环境：安装 **MSVC 2022**、**Qt 6.8.0 msvc2022_64**，并确保通过 **vcpkg** 安装 `cpr/libcurl/OpenSSL`（`vcpkg install cpr curl[openssl] openssl --triplet x64-windows`，建议执行 `vcpkg integrate install`）。
2. 克隆仓库：`git clone https://github.com/letr007/CCTVVideoDownloader.git && cd CCTVVideoDownloader`。
3. 一键构建并启动：
   ```powershell
   # 将 Qt/vcpkg 路径换成你的本地路径，默认 Debug 配置；如需 Release 可添加 -Configuration Release
   powershell -ExecutionPolicy Bypass -File scripts/run-local.ps1 \ \
       -QtInstallRoot "C:\\Qt\\6.8.0\\msvc2022_64" -VcpkgRoot "C:\\vcpkg"
   ```
   脚本会自动调用 `msbuild` 生成二进制并在同一终端中启动应用；若已在 VS 中编译过，可带上 `-SkipBuild` 仅启动。

## :clapper:使用步骤

1. **选择栏目**：左侧列表点击一个栏目，右侧会刷新该栏目的视频列表。
2. **多选视频**：按住 Ctrl 或 Shift 进行多选，确认想要下载的视频条目。
3. **开始批量下载**：点击“下载”按钮，任务会按“下载 → 拼接 → 解密”顺序自动串联，状态栏会提示当前进度。
4. **查看与暂停**：下载列表中可以查看每个任务的进度、速度和错误信息，必要时可暂停/继续。

### 断点续传与容错

- 下载时会跳过已存在的分片文件，重新启动应用或恢复任务时无需重复已完成的分片。
- 任务失败后重新点击“继续”即可从上次进度续传；如果文件夹被清理，任务会自动重新下载缺失的分片。

### 下载保存位置与线程数

在菜单栏的“设置”中可调整保存路径、并发线程数等参数，修改后重新开始的任务会使用新配置。

## :package:构建与打包

1. 准备环境：安装 **MSVC 2022**、**Qt 6.8.0 msvc2022_64**，并通过 **vcpkg** 提供 `cpr/libcurl/OpenSSL` 依赖（设置好 `VCPKG_ROOT`）。
2. 在 *x64 Native Tools Command Prompt* 中验证代码可编译与测试：
   - `msbuild CCTVVideoDownloader.vcxproj /p:Configuration=Release /p:Platform=x64`
   - `msbuild test/test.vcxproj /p:Configuration=Release /p:Platform=x64`
   - 使用 `vstest.console.exe test/x64/Release/test.dll --parallel` 运行测试（若已安装测试组件）。
3. 打包成可运行目录：
   - `powershell -ExecutionPolicy Bypass -File scripts/package-windows.ps1 -QtInstallRoot "C:\\Qt\\6.8.0\\msvc2022_64" -VcpkgRoot "C:\\vcpkg"`
   - 脚本会在 `artifacts/CCTVVideoDownloader-x64-Release` 生成包含可执行文件、Qt 运行库、vcpkg DLL 及 `decrypt` 数据的发布目录。

## :pencil:配置设置

您可以通过`设置`菜单来配置程序的一些参数，包括保存路径、线程数等设置。

## :beers:帮助与反馈

如有任何疑问或建议，请提交[issues](https://github.com/letr007/CCTVVideoDownload/issues)。

## :rotating_light: 免责声明  

1. **使用限制**
   - 本工具仅供**技术研究**和**学习交流**使用
   - 严禁用于任何侵犯版权的行为
   - 禁止用于商业用途

2. **版权说明**
   - 央视网（CCTV）所有视频内容版权归中央广播电视总台所有
   - 未经授权，禁止以任何形式下载、传播或商用
   - 使用者应遵守《中华人民共和国著作权法》及相关法规

3. **免责条款**
   - 开发者不对工具的滥用行为负责
   - 使用者需自行承担因使用本工具而产生的所有法律责任
   - 如不同意以上条款，请立即停止使用本工具

##

<img alt="Star History Chart" src="https://api.star-history.com/svg?repos=letr007/CCTVVideoDownloader&type=Date" />


