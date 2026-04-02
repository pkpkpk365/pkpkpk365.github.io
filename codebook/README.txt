代码记录本 Pro 使用说明

1. 把整个 codebook 文件夹放进你的 GitHub Pages 仓库。
2. 访问 /codebook/ 即可打开页面。
3. 新增代码时：
   - 在 codebook/snippets/ 对应目录下新建代码文件
   - 再编辑 snippets.json 增加一条记录
4. 建议字段：
   - title: 标题
   - language: 语言
   - category: 分类
   - description: 说明
   - tags: 标签数组
   - source: 来源/场景
   - updated: 更新时间
   - pinned: 是否收藏
   - file: 代码文件路径

GitHub 网页端新建“文件夹”的方法：
直接新建文件时，文件名写成完整路径，例如：
codebook/snippets/python/new_tool.py
GitHub 会自动连同中间目录一起创建。
