# 代码记录本使用说明

这是一个基于静态网页的个人代码记录本，适合托管在 GitHub Pages 上使用。

## 已实现功能
- 默认显示全部分类
- 按语言分类筛选
- 搜索标题和说明
- 轻量分页（每页 10 条）
- 代码正文按需加载
- 一键复制代码
- Prism 语法高亮（对部分语言适配）

## 根目录结构
- `index.html`：页面入口
- `app.js`：分类、搜索、分页、加载代码逻辑
- `style.css`：页面样式
- `index.json`：根索引，只登记各分类目录的索引文件

## 根目录 index.json 规则
采用做法 A：根索引只登记分类。

示例：

```json
[
  { "language": "python", "index": "python/index.json" },
  { "language": "excel", "index": "excel/index.json" }
]
```

## 使用步骤
1. 在对应语言目录内新增代码文件
2. 修改该语言目录下的 `index.json`
3. 提交到 GitHub 仓库
4. GitHub Pages 页面会按索引自动展示

## 注意事项
- `language` 必须使用固定小写键名
- 每个语言目录的 `index.json` 只登记本目录内容
- 代码正文不要写进 json，单独保存为实际文件
