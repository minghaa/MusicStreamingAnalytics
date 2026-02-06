# Hướng dẫn Upload lên GitHub

## Bước 1: Tạo Repository trên GitHub

1. Truy cập [github.com/new](https://github.com/new)
2. Đặt tên repository: `MusicStreamingAnalytics`
3. Description: `SQL Portfolio Project - Music Streaming Analytics with PostgreSQL and Looker Studio`
4. Chọn **Public** (để cho vào portfolio)
5. **KHÔNG** chọn "Add README" (vì đã có sẵn)
6. Click **Create repository**

## Bước 2: Upload từ Terminal

Mở Terminal và chạy các lệnh sau:

```bash
# Di chuyển vào thư mục project
cd ~/Downloads/MusicStreamingAnalytics

# Khởi tạo Git repository
git init

# Thêm tất cả files
git add .

# Commit đầu tiên
git commit -m "Initial commit: Music Streaming Analytics SQL Project"

# Thêm remote (thay YOUR_USERNAME bằng GitHub username của bạn)
git remote add origin https://github.com/YOUR_USERNAME/MusicStreamingAnalytics.git

# Push lên GitHub
git branch -M main
git push -u origin main
```

## Bước 3: Verify Upload

1. Refresh trang GitHub repository
2. Kiểm tra tất cả files đã upload
3. README.md sẽ hiển thị tự động với link dashboard

## 🎉 Hoàn thành!

Repository URL của bạn sẽ là:
```
https://github.com/YOUR_USERNAME/MusicStreamingAnalytics
```

Thêm link này vào CV/Portfolio của bạn!
