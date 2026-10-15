<#macro emailLayout>
<html lang="${locale.language}" dir="${(ltr)?then('ltr','rtl')}">
<head>
    <meta charset="utf-8">
    <meta name="color-scheme" content="light">
</head>
<body style="margin:0;padding:0;background-color:#F6F8FB;font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',Arial,sans-serif;color:#0A1A2F;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#F6F8FB;padding:24px 0;">
        <tr>
            <td align="center">
                <table role="presentation" width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;background-color:#FFFFFF;border:1px solid #D5DDE7;border-radius:8px;overflow:hidden;">
                    <tr>
                        <td style="background-color:#0A1A2F;border-bottom:4px solid #C6A14A;padding:20px 32px;">
                            <span style="color:#C6A14A;font-weight:700;font-size:18px;letter-spacing:3px;text-transform:uppercase;">Shree Krupa</span>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:32px;font-size:15px;line-height:1.7;color:#0A1A2F;">
                            <#nested>
                        </td>
                    </tr>
                    <tr>
                        <td style="background-color:#F6F8FB;border-top:1px solid #E6EDF5;padding:18px 32px;font-size:12px;color:#5C677D;">
                            This is an automated message from Shree Krupa. Please do not reply to this email.
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
</#macro>
