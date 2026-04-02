from docx import Document
import pandas as pd

EXCEL_PATH = "data.xlsx"
WORD_TEMPLATE = "template.docx"
MATCH_COLUMN = "身份证号码"
OUTPUT_PATH = "output.docx"

df = pd.read_excel(EXCEL_PATH, dtype=str).fillna("")
doc = Document(WORD_TEMPLATE)

target_id = "500000000000000000"
row = df[df[MATCH_COLUMN] == target_id]

if row.empty:
    raise ValueError(f"Excel 中未找到身份证号：{target_id}")

record = row.iloc[0].to_dict()

for para in doc.paragraphs:
    for key, value in record.items():
        placeholder = f"《《{key}》》"
        if placeholder in para.text:
            para.text = para.text.replace(placeholder, str(value))

doc.save(OUTPUT_PATH)
print(f"已输出：{OUTPUT_PATH}")
