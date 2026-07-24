# rsvg-convert

Used by the **fireworks** engine as a fallback for SVG → PNG conversion when `cairosvg` is unavailable.

## 两个系统默认都不带

macOS 与 Windows **都不预装** `rsvg-convert`，需要手动安装。

## macOS：用 Homebrew 安装

macOS 系统本身不含 `rsvg-convert`，最常见的方式是通过 Homebrew：

```bash
brew install librsvg
```

装好后 `rsvg-convert` 随 `librsvg` 一起被装上。验证：

```bash
rsvg-convert --version
```

能输出版本号就说明可用。

> 💡 如果还没装 Homebrew，先跑：
> ```bash
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> ```

## Windows：需要用包管理器或手动装

Windows 同样没有预装，有三种常见方式：

**① Chocolatey（推荐）**

管理员 PowerShell：

```powershell
choco install rsvg-convert
```

**② Scoop**

```powershell
scoop bucket add r-bucket https://github.com/cderv/r-bucket.git
scoop install rsvg-convert
```

**③ 手动下载二进制**

从开源构建下载 `rsvg-convert.exe`，把所在目录加到系统 `PATH` 环境变量。

装完同样用 `rsvg-convert --version` 验证。

> ⚠️ 网上有些老的教程指向 `googlecode.com` 上的 exe，那个镜像早已过期，**别再用**。现在认准 Chocolatey 或 Scoop 即可。

## Linux (Debian/Ubuntu)

```bash
sudo apt install librsvg2-bin
```

## 快速对照

| 系统 | 是否预装 | 推荐安装命令 |
|---|---|---|
| macOS | 否 | `brew install librsvg` |
| Linux (Debian/Ubuntu) | 否 | `sudo apt install librsvg2-bin` |
| Linux (RHEL/CentOS) | 否 | `sudo yum install librsvg2-tools` |
| Windows | 否 | `choco install rsvg-convert`（管理员 PowerShell） |

两个平台装好后使用方式完全一致，例如：

```bash
rsvg-convert -w 512 -h 512 input.svg -o output.png
```

## 自动检测

```bash
bash tools/check.sh fireworks    # 检查 caffe / cairosvg / rsvg-convert
bash tools/check.sh fireworks --fix   # macOS/Linux 自动安装
```
