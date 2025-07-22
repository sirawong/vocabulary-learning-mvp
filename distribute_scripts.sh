#!/bin/bash

# --- Configuration ---
# โฟลเดอร์ที่เก็บไฟล์สคริปต์รวม (Input)
INPUT_DIR="script_download"
# โฟลเดอร์ที่จะสร้างโครงสร้างและไฟล์ผลลัพธ์ (Output)
OUTPUT_DIR="scripts"

# --- Validation ---
# ตรวจสอบว่าโฟลเดอร์ต้นทางมีอยู่จริงหรือไม่
if [ ! -d "$INPUT_DIR" ]; then
    echo "ข้อผิดพลาด: ไม่พบโฟลเดอร์ต้นทาง '$INPUT_DIR'"
    echo "กรุณาสร้างโฟลเดอร์ '$INPUT_DIR' และนำไฟล์สคริปต์รวมไปไว้ข้างใน"
    exit 1
fi

# --- Main Logic ---
# ลบและสร้างโฟลเดอร์ผลลัพธ์ใหม่ เพื่อให้แน่ใจว่าเริ่มต้นจากศูนย์
echo "กำลังล้างข้อมูลเก่าและเตรียมพื้นที่ทำงานในโฟลเดอร์ '$OUTPUT_DIR'..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# ตัวแปรสำหรับเก็บชื่อไฟล์เป้าหมายปัจจุบัน
CURRENT_TARGET_FILE=""

echo "กำลังเริ่มประมวลผลและกระจายไฟล์..."

# วนลูปอ่านไฟล์ทั้งหมดในโฟลเดอร์ INPUT_DIR
for source_file in "$INPUT_DIR"/*; do
    echo "=> กำลังอ่านไฟล์: $source_file"
    
    # อ่านไฟล์ต้นทางทีละบรรทัด
    while IFS= read -r line || [[ -n "$line" ]]; do
    
        # [FIXED] ปรับปรุง Regular Expression ให้แม่นยำขึ้น
        # จะจับคู่ path ที่ขึ้นต้นด้วย 'scripts/' และหยุดที่ช่องว่างแรก
        if [[ "$line" =~ ^#\ (scripts\/[^ ]+) ]]; then
            # ดึงเอาเฉพาะ path ของไฟล์ออกมา (e.g., scripts/test.sh)
            CURRENT_TARGET_FILE="${BASH_REMATCH[1]}"
            
            # สร้าง directory ของไฟล์เป้าหมาย หากยังไม่มี
            target_dir=$(dirname "$CURRENT_TARGET_FILE")
            mkdir -p "$target_dir"
            
            # เขียนบรรทัดเริ่มต้น (บรรทัดที่เจอ) ลงในไฟล์เป้าหมาย
            echo "$line" > "$CURRENT_TARGET_FILE"
            
        # หากเจอตัวคั่นจบสคริปต์
        elif [[ "$line" == "# ---" ]]; then
            # ตรวจสอบว่าเรากำลังเขียนไฟล์อยู่หรือไม่
            if [[ -n "$CURRENT_TARGET_FILE" ]]; then
                # เขียนบรรทัดปิดท้ายลงในไฟล์ แล้วเคลียร์ค่าตัวแปร
                echo "$line" >> "$CURRENT_TARGET_FILE"
                echo "   -> เขียนไฟล์ '$CURRENT_TARGET_FILE' เรียบร้อย"
                CURRENT_TARGET_FILE="" # รีเซ็ตค่าเพื่อรอสคริปต์บล็อกถัดไป
            fi
            
        # หากเราอยู่ในระหว่างการเขียนไฟล์ (CURRENT_TARGET_FILE มีค่า)
        elif [[ -n "$CURRENT_TARGET_FILE" ]]; then
            # ให้เขียนบรรทัดปัจจุบันลงในไฟล์เป้าหมาย
            echo "$line" >> "$CURRENT_TARGET_FILE"
        fi
        
    done < "$source_file"
done

echo ""
echo "--- การกระจายไฟล์ทั้งหมดเสร็จสมบูรณ์ ---"
echo "โครงสร้างไฟล์ที่ได้:"

# ตรวจสอบว่ามีคำสั่ง 'tree' หรือไม่
if command -v tree &> /dev/null; then
    # ถ้ามี ให้ใช้ tree
    tree "$OUTPUT_DIR"
else
    # ถ้าไม่มี ให้ใช้ ls -R แทน และแจ้งให้ผู้ใช้ทราบ
    echo "(คำแนะนำ: หากต้องการมุมมองที่ดีกว่านี้ ลองติดตั้ง 'tree' ด้วยคำสั่ง เช่น 'sudo apt-get install tree' หรือ 'sudo yum install tree')"
    ls -R "$OUTPUT_DIR"
fi

