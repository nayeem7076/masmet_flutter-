require('dotenv').config();

const cors = require('cors');
const express = require('express');
const nodemailer = require('nodemailer');

const app = express();
const port = Number(process.env.PORT || 5000);

app.use(cors());
app.use(express.json());

function createTransporter() {
  const smtpPort = Number(process.env.SMTP_PORT || 587);
  const smtpSecure = String(process.env.SMTP_SECURE || 'false') === 'true';

  return nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: smtpPort,
    secure: smtpSecure,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
}

function isEmail(value) {
  return typeof value === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

app.get('/health', (req, res) => {
  res.json({ ok: true, service: 'MessMate Email Backend' });
});

app.post('/api/send-notice-email', async (req, res) => {
  try {
    const { emails, title, message } = req.body;

    if (!Array.isArray(emails) || emails.length === 0) {
      return res.status(400).json({ ok: false, error: 'emails array is required' });
    }

    const cleanEmails = [...new Set(emails.map(String).map((x) => x.trim()).filter(isEmail))];

    if (cleanEmails.length === 0) {
      return res.status(400).json({ ok: false, error: 'No valid email address found' });
    }

    if (!title || !message) {
      return res.status(400).json({ ok: false, error: 'title and message are required' });
    }

    if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
      return res.status(500).json({ ok: false, error: 'SMTP_USER or SMTP_PASS missing in .env' });
    }

    const transporter = createTransporter();
    const fromName = process.env.MAIL_FROM_NAME || process.env.APP_NAME || 'MessMate';
    const fromAddress = process.env.MAIL_FROM_ADDRESS || process.env.SMTP_USER;

    const info = await transporter.sendMail({
      from: `"${fromName}" <${fromAddress}>`,
      to: cleanEmails.join(','),
      subject: `[MessMate Notice] ${title}`,
      html: `
        <div style="font-family:Arial,sans-serif;line-height:1.6;color:#111827">
          <div style="max-width:600px;margin:auto;border:1px solid #e5e7eb;border-radius:16px;overflow:hidden">
            <div style="background:#1E88E5;color:white;padding:18px 22px">
              <h2 style="margin:0">MessMate Notice</h2>
            </div>
            <div style="padding:22px">
              <h3 style="margin-top:0;color:#0D47A1">${escapeHtml(title)}</h3>
              <p>${escapeHtml(message).replace(/\n/g, '<br>')}</p>
              <p style="margin-top:24px;color:#6b7280;font-size:13px">Sent from MessMate</p>
            </div>
          </div>
        </div>
      `,
    });

    res.json({ ok: true, messageId: info.messageId, sentTo: cleanEmails.length });
  } catch (error) {
    console.error(error);
    res.status(500).json({ ok: false, error: error.message || 'Email send failed' });
  }
});

function escapeHtml(input) {
  return String(input)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

app.listen(port, () => {
  console.log(`MessMate email backend running on http://localhost:${port}`);
});
