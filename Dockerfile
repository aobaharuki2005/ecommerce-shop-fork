# Sử dụng Node.js phiên bản 24
FROM node:24-bullseye

# Cập nhật hệ thống và cài đặt các công cụ cần thiết
RUN apt-get update && apt-get upgrade -y && apt-get install -y netcat-openbsd

# Khai báo thư mục làm việc
WORKDIR /app

# Sao chép các file cấu hình package trước (tận dụng Docker Cache)
COPY package*.json ./
COPY server/package*.json ./server/

# Cài đặt Node.js dependencies cho cả frontend lẫn backend
RUN npm install
RUN cd server && npm install

# Copy toàn bộ mã nguồn vào container
COPY . .

# Phân quyền thực thi cho script chờ database
RUN chmod +x ./server/node_modules/.bin/prisma

# Cổng cho frontend (3000) và backend (3001)
EXPOSE 3000 3001

# Lệnh khởi chạy cải tiến
# 1. Chờ DB sẵn sàng (thông qua script hoặc lệnh sleep)
# 2. npx prisma db push (Cập nhật schema)
# 3. node server/utills/insertDemoData.js (Chèn dữ liệu)
# 4. Chạy Frontend & Backend
CMD ["sh", "-c", "until nc -z db 3306; do echo 'Waiting for MySQL...'; sleep 1; done; cd server && npx prisma db push && node utills/insertDemoData.js && node app.js & npm run dev"]