@echo off
echo 🚀 Starting ACC Portal with JWT_SECRET...

set JWT_SECRET=acc_portal_jwt_secret_development_2024
set DB_HOST=localhost
set DB_USER=root
set DB_PASSWORD=
set DB_NAME=acc_database
set AI_SERVICE_URL=http://localhost:5001

npm start

pause
