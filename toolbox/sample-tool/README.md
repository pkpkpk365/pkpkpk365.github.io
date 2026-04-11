# 示例工具：加法计算器

这是一个演示用工具，用来说明你的工具目录应该怎么组织。

## 文件结构

```text
sample-tool/
├─ index.html
└─ README.md
```

## 说明

- `index.html` 是实际工具页面
- `README.md` 是该工具的补充说明
- 在 `tools.json` 中登记后，首页会自动显示这个工具

## 对应的 tools.json 示例

```json
{
  "name": "示例工具：加法计算器",
  "description": "一个最简单的示例工具，用来演示目录页如何自动读取和展示工具。",
  "url": "./sample-tool/index.html",
  "readme": "./sample-tool/README.md",
  "tags": ["示例", "计算器", "演示"]
}
```
