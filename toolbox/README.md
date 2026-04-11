# HTML 工具箱（适用于 GitHub Pages）

这是一个可直接部署到 GitHub Pages 的静态 HTML 工具箱模板。

## 功能特点

- 根目录中的 `index.html` 会自动读取同目录下的 `tools.json`
- 新增、删除工具时，只需要修改 `tools.json`
- 不需要每次手动改页面 HTML
- 索引页自带“返回整个站点根目录”链接：`../`
- 支持给每个工具配置说明文档链接
- 附带一个示例工具，方便你照着仿制

---

## 建议目录结构

```text
你的仓库/
├─ index.html                  # 工具箱索引页
├─ tools.json                  # 工具清单
├─ README.md                   # 本说明文件
├─ sample-tool/
│  ├─ index.html
│  └─ README.md
├─ calculator/
│  ├─ index.html
│  └─ README.md
└─ another-tool/
   ├─ index.html
   └─ README.md
```

如果你的工具箱不是放在站点根目录，而是放在某个子目录，例如：

```text
你的仓库/
├─ index.html                  # 整个站点首页
└─ tools/
   ├─ index.html               # 本工具箱页
   ├─ tools.json
   ├─ README.md
   └─ xxx-tool/
```

那么本模板中的返回链接 `../` 就会返回整个站点根目录，这正符合你的需求。

---

## 如何新增一个工具

假设你要新增一个“年化收益率计算器”，建议这样放：

```text
calculator-annual-return/
├─ index.html
└─ README.md
```

然后在 `tools.json` 里新增一项。

---

## tools.json 格式说明

`tools.json` 的基本结构如下：

```json
{
  "tools": [
    {
      "name": "工具名称",
      "description": "工具简介",
      "url": "./工具文件夹/index.html",
      "readme": "./工具文件夹/README.md",
      "tags": ["标签1", "标签2"]
    }
  ]
}
```

### 字段说明

- `name`：工具名称，必填
- `description`：工具简介，建议填写
- `url`：工具页面地址，必填
- `readme`：说明文档地址，可选但建议填写
- `tags`：标签数组，可选

---

## JSON 示例

下面是一个更完整的示例：

```json
{
  "tools": [
    {
      "name": "股市年化收益率计算器",
      "description": "输入本金、终值和持有年数，自动计算年化收益率。",
      "url": "./stock-annual-return/index.html",
      "readme": "./stock-annual-return/README.md",
      "tags": ["金融", "计算器", "收益率"]
    },
    {
      "name": "Power Query 时间格式转换器",
      "description": "把 20260307120325 这类文本转换为标准日期时间格式。",
      "url": "./pq-datetime-converter/index.html",
      "readme": "./pq-datetime-converter/README.md",
      "tags": ["Power Query", "日期", "转换"]
    }
  ]
}
```

---

## 删除工具的方法

1. 删除对应工具文件夹
2. 从 `tools.json` 中删掉对应那一项

页面会自动更新，不需要改 `index.html`

---

## 注意事项

### 1. 路径要写相对路径

推荐统一写法：

- `./tool-folder/index.html`
- `./tool-folder/README.md`

这样迁移仓库或改域名时更稳。

### 2. GitHub Pages 对文件名大小写敏感

例如：

- `README.md` 和 `readme.md` 不是同一个文件
- `Index.html` 和 `index.html` 不是同一个文件

建议统一使用：

- 页面文件：`index.html`
- 说明文件：`README.md`

### 3. 中文路径尽量少用

虽然可以用，但后期维护、复制链接、排查问题会更麻烦。更稳的做法是：

- 文件夹名用英文或英文加短横线
- 页面标题和工具名称再写中文

例如：

```text
stock-annual-return/
```

而不是：

```text
股市年化收益率计算器/
```

---

## 你以后实际维护时怎么做

最省事的方式是：

1. 新建一个工具文件夹
2. 把该工具的 `index.html` 放进去
3. 视情况写一个 `README.md`
4. 在 `tools.json` 追加一条记录
5. 提交到 GitHub 仓库

页面就会自动显示新工具。

---

## 常见问题

### 页面没有显示工具怎么办？

优先检查：

- `tools.json` 是否是合法 JSON
- JSON 里有没有多写逗号
- `url` 路径是否正确
- 工具文件夹里是否真的有 `index.html`

### 点击 README 打不开怎么办？

检查：

- `readme` 路径是否正确
- 文件名大小写是否一致
- 是否真的存在对应 `README.md`

---

## 适合后续扩展的方向

你后续还可以继续加这些功能：

- 分类筛选
- 图标显示
- 按更新时间排序
- 收藏常用工具
- 深色模式
- 搜索高亮
- 多级目录

如果后面你要，我可以继续把这个版本升级成：
1. 支持分类分组
2. 支持图标
3. 支持置顶常用工具
4. 支持按 JSON 自动排序
