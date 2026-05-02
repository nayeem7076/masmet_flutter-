# MessMate Email Backend

This backend sends notice emails using SMTP/Nodemailer.

## Important security
Do not commit or share your `.env` file. Use a Gmail App Password, not your Gmail normal password.

## Setup

```bash
cd backend
npm install
cp .env.example .env
npm start
```

Edit `.env` and set your real SMTP details:

```env
PORT=5000
APP_NAME=MessMate
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_new_gmail_app_password
MAIL_FROM_ADDRESS=your_email@gmail.com
MAIL_FROM_NAME=MessMate
```

For Gmail port 587, use `SMTP_SECURE=false`.

## Flutter API URL

In `lib/services/email_notice_service.dart`:

- Android emulator: `http://10.0.2.2:5000`
- Physical phone: use your computer IP, e.g. `http://192.168.0.100:5000`
- Hosted server: use your public URL

## Test

Open:

```text
http://localhost:5000/health
```

Then add member emails in the app and send a notice from manager account.
