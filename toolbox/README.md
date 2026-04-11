
# 工具箱使用说明（极简版）

本工具箱用于 GitHub Pages 部署，采用“JSON + 文件夹”方式管理工具。

---

## 一、目录结构

```
/（站点根）
│
├── index.html
│
└── toolbox/
    │
    ├── index.html
    ├── tools.json
    │
    ├── example/
    │   └── index.html
```

---

## 二、如何新增工具

### 第一步：新建工具文件夹

在 toolbox 目录下创建文件夹，例如：

```
toolbox/calculator/
```

---

### 第二步：创建工具页面

在该文件夹内创建：

```
index.html
```

注意：**必须叫 index.html**

---

### 第三步：修改 tools.json

新增一条：

```json
{
  "name": "计算器",
  "folder": "calculator"
}
```

---

## 三、tools.json 格式说明

```json
[
  {
    "name": "工具名称",
    "folder": "文件夹名称"
  }
]
```

字段说明：

- name：页面显示名称
- folder：工具所在文件夹（自动打开 index.html）

---

## 四、删除工具

1. 删除对应文件夹
2. 删除 tools.json 中对应项

---

## 五、注意事项（非常重要）

1. 所有工具页面必须叫：
   index.html

2. folder 必须和文件夹名称完全一致（区分大小写）

3. 建议使用英文文件夹名（避免路径问题）

4. JSON 不能写错格式（特别是逗号）

---

## 六、常见错误

### 1. 页面显示“JSON加载失败”

原因：

- tools.json 格式错误
- 多写或少写逗号

---

### 2. 点击工具打不开（404）

原因：

- folder 名写错
- 文件夹不存在
- index.html 不存在

---

## 七、设计原则（你要记住）

本方案核心是：

👉 简单 > 自动化  
👉 稳定 > 花哨  

只要保证：

- 文件夹存在
- JSON 正确

这个系统就不会出问题。
