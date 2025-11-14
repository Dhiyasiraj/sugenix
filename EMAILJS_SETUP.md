# EmailJS Setup Instructions

This document explains how to set up EmailJS for sending email notifications when admin approves or rejects pharmacy and doctor accounts.

## Step 1: Sign Up for EmailJS

1. Go to [https://www.emailjs.com/](https://www.emailjs.com/)
2. Sign up for a free account (allows 200 emails/month)
3. Verify your email address

## Step 2: Create an Email Service

1. Go to **Email Services** in the dashboard
2. Click **Add New Service**
3. Choose your email provider (Gmail, Outlook, etc.)
4. Follow the setup instructions for your provider
5. Note your **Service ID** (e.g., `service_abc123`)

## Step 3: Create Email Template

1. Go to **Email Templates** in the dashboard
2. Click **Create New Template**
3. Name it: `Approval Template` (this single template is used for both approval and rejection)
4. Use this template:

```
Subject: {{subject}}

{{title}}

{{message}}

---
{{app_name}} Team
For support, contact: {{support_email}}
Login: {{login_url}}
```

**Important:** All content (subject, title, message) is sent from the code, so the template just displays the variables. This allows you to customize the email content dynamically.

5. Note your **Template ID** (e.g., `template_xyz789`)

## Step 4: Get Your Public Key

1. Go to **Account** > **General**
2. Find your **Public Key** (e.g., `abc123xyz789`)
3. Copy this key

## Step 5: Update the Code

1. Open `lib/services/emailjs_service.dart`
2. Replace the following constants with your actual values:

```dart
static const String _serviceId = 'your_service_id_here';
static const String _templateId = 'your_template_id_here'; // Single template for both
static const String _publicKey = 'your_public_key_here';
```

**Note:** Only one template is needed! All email content (subject, title, message) is drafted from the code, so you can customize it without changing the EmailJS template.

## Step 6: Test the Integration

1. Approve or reject a pharmacy/doctor account from the admin panel
2. Check the console logs for email sending status
3. Verify that the email was received

## Template Variables

The following variables are sent from the code and can be used in your template:

- `{{to_email}}` - Recipient email address
- `{{to_name}}` - Recipient name
- `{{subject}}` - Email subject (drafted from code)
- `{{title}}` - Email title/heading (drafted from code)
- `{{message}}` - Email body message (drafted from code)
- `{{app_name}}` - Application name (Sugenix)
- `{{login_url}}` - Login page URL
- `{{support_email}}` - Support email address

All content is dynamically generated from the code, so you can modify email messages by editing `lib/services/emailjs_service.dart`.

## Troubleshooting

- **Email not sending**: Check that all IDs and keys are correct
- **Template variables not working**: Ensure variable names match exactly (case-sensitive)
- **Rate limit errors**: Free tier allows 200 emails/month, upgrade if needed
- **CORS errors**: EmailJS handles CORS automatically, but check browser console
- **Content not showing**: Make sure your template includes `{{subject}}`, `{{title}}`, and `{{message}}` variables

## Security Notes

- The Public Key is safe to use in client-side code
- Never expose your Private Key
- EmailJS automatically handles email delivery securely

## Support

For EmailJS support, visit: [https://www.emailjs.com/docs/](https://www.emailjs.com/docs/)

