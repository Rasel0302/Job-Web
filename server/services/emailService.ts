import nodemailer from 'nodemailer';
import { logger } from '../utils/logger.js';
import { getConnection } from '../config/database.js';

interface EmailOptions {
  to: string;
  subject: string;
  html: string;
  type?: 'otp' | 'invitation' | 'application_status' | 'job_match' | 'general';
}

class EmailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER || 'raselmadrideomarana@gmail.com',
        pass: process.env.EMAIL_PASS || 'ddxx kivl klno telq'
      }
    });
  }

  async sendEmail(options: EmailOptions): Promise<boolean> {
    try {
      const mailOptions = {
        from: process.env.EMAIL_FROM || 'ACC Career Connect <raselmadrideomarana@gmail.com>',
        to: options.to,
        subject: options.subject,
        html: options.html
      };

      const result = await this.transporter.sendMail(mailOptions);
      
      // Log email to database
      await this.logEmail(options, true);
      
      logger.info(`Email sent successfully to ${options.to}`, result.messageId);
      return true;
    } catch (error) {
      logger.error('Failed to send email:', error);
      
      // Log failed email to database
      await this.logEmail(options, false, (error as Error).message);
      
      return false;
    }
  }

  private async logEmail(options: EmailOptions, isSent: boolean, errorMessage?: string) {
    try {
      const connection = getConnection();
      await connection.execute(
        'INSERT INTO email_notifications (recipient_email, subject, body, type, is_sent, error_message) VALUES (?, ?, ?, ?, ?, ?)',
        [
          options.to,
          options.subject,
          options.html,
          options.type || 'general',
          isSent,
          errorMessage || null
        ]
      );
    } catch (dbError) {
      logger.error('Failed to log email to database:', dbError);
    }
  }

  async sendOTP(email: string, otp: string, purpose: string = 'verification'): Promise<boolean> {
    const subject = `Your ACC Verification Code`;
    const html = this.generateOTPTemplate(otp, purpose);
    
    return await this.sendEmail({
      to: email,
      subject,
      html,
      type: 'otp'
    });
  }

  async sendWelcomeEmail(email: string, firstName: string, role: string): Promise<boolean> {
    const subject = 'Welcome to Asiatech Career Connect!';
    const html = this.generateWelcomeTemplate(firstName, role);
    
    return await this.sendEmail({
      to: email,
      subject,
      html,
      type: 'general'
    });
  }

  async sendInvitationEmail(email: string, inviterName: string, companyName: string, inviteLink: string): Promise<boolean> {
    const subject = 'Invitation to Join ACC Career Connect';
    const html = this.generateInvitationTemplate(inviterName, companyName, inviteLink);
    
    return await this.sendEmail({
      to: email,
      subject,
      html,
      type: 'invitation'
    });
  }

  async sendApplicationStatusUpdate(email: string, jobTitle: string, companyName: string, status: string): Promise<boolean> {
    const subject = `Application Update: ${jobTitle} at ${companyName}`;
    const html = this.generateApplicationStatusTemplate(jobTitle, companyName, status);
    
    return await this.sendEmail({
      to: email,
      subject,
      html,
      type: 'application_status'
    });
  }

  async sendJobMatchNotification(email: string, jobTitle: string, companyName: string, matchScore: number): Promise<boolean> {
    const subject = `New Job Match Found: ${jobTitle}`;
    const html = this.generateJobMatchTemplate(jobTitle, companyName, matchScore);
    
    return await this.sendEmail({
      to: email,
      subject,
      html,
      type: 'job_match'
    });
  }

  private generateOTPTemplate(otp: string, purpose: string): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .otp-box { background: white; border: 2px solid #16a34a; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }
          .otp-code { font-size: 32px; font-weight: bold; color: #16a34a; letter-spacing: 5px; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>ACC Career Connect</h1>
            <p>Asiatech Career Connect</p>
          </div>
          <div class="content">
            <h2>Verification Code</h2>
            <p>Your verification code for ${purpose} is:</p>
            <div class="otp-box">
              <div class="otp-code">${otp}</div>
            </div>
            <p><strong>This code will expire in 10 minutes.</strong></p>
            <p>If you didn't request this code, please ignore this email.</p>
          </div>
          <div class="footer">
            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  private generateWelcomeTemplate(firstName: string, role: string): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Welcome to ACC!</h1>
            <p>Asiatech Career Connect</p>
          </div>
          <div class="content">
            <h2>Hello ${firstName}!</h2>
            <p>Welcome to Asiatech Career Connect! We're excited to have you join our platform as a ${role}.</p>
            <p>ACC is designed to make job finding easier for OJT college students and alumni. Our platform connects students with opportunities that match their skills and career goals.</p>
            <p>Get started by completing your profile and exploring the available opportunities.</p>
            <a href="${process.env.FRONTEND_URL}" class="btn">Start Exploring</a>
          </div>
          <div class="footer">
            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  private generateInvitationTemplate(inviterName: string, companyName: string, inviteLink: string): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>You're Invited!</h1>
            <p>Asiatech Career Connect</p>
          </div>
          <div class="content">
            <h2>Join ACC as ${companyName}</h2>
            <p>Hello!</p>
            <p>${inviterName} has invited you to join Asiatech Career Connect as a company representative for ${companyName}.</p>
            <p>ACC connects talented OJT students and alumni with great companies like yours. Join us to find the perfect candidates for your open positions.</p>
            <a href="${inviteLink}" class="btn">Accept Invitation</a>
            <p><small>This invitation link will expire in 7 days.</small></p>
          </div>
          <div class="footer">
            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  private generateApplicationStatusTemplate(jobTitle: string, companyName: string, status: string): string {
    const statusColors: {[key: string]: string} = {
      'reviewed': '#f59e0b',
      'interviewed': '#3b82f6',
      'accepted': '#10b981',
      'rejected': '#ef4444'
    };
    
    const statusColor = statusColors[status] || '#6b7280';
    
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .status-badge { display: inline-block; background: ${statusColor}; color: white; padding: 8px 16px; border-radius: 20px; font-weight: bold; text-transform: uppercase; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Application Update</h1>
            <p>Asiatech Career Connect</p>
          </div>
          <div class="content">
            <h2>${jobTitle} at ${companyName}</h2>
            <p>Your application status has been updated:</p>
            <div style="text-align: center; margin: 20px 0;">
              <span class="status-badge">${status}</span>
            </div>
            <p>Thank you for using ACC to advance your career. Keep exploring new opportunities!</p>
          </div>
          <div class="footer">
            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  private generateJobMatchTemplate(jobTitle: string, companyName: string, matchScore: number): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #16a34a; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .match-score { background: white; border: 2px solid #10b981; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0; }
          .score { font-size: 48px; font-weight: bold; color: #10b981; }
          .btn { display: inline-block; background: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Perfect Match Found!</h1>
            <p>Asiatech Career Connect</p>
          </div>
          <div class="content">
            <h2>${jobTitle}</h2>
            <p><strong>Company:</strong> ${companyName}</p>
            <p>We found a great job match for you based on your resume and preferences!</p>
            <div class="match-score">
              <div class="score">${matchScore}%</div>
              <p>Match Score</p>
            </div>
            <p>This position aligns well with your skills and experience. Don't miss this opportunity!</p>
            <a href="${process.env.FRONTEND_URL}/jobs" class="btn">View Job Details</a>
          </div>
          <div class="footer">
            <p>© 2024 Asiatech Career Connect. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  async sendApprovalEmail(email: string, userType: string, approved: boolean, reason?: string): Promise<boolean> {
    const subject = approved 
      ? `✅ Your ${userType} account has been approved!`
      : `❌ Your ${userType} account application`;

    const actionColor = approved ? '#16a34a' : '#ef4444';
    const actionText = approved ? 'APPROVED' : 'REJECTED';
    const message = approved 
      ? `Great news! Your ${userType} account has been approved and is now active.`
      : `We regret to inform you that your ${userType} account application was not approved.`;

    const nextSteps = approved 
      ? (userType === 'admin' 
          ? 'You now have full administrative access to the ACC Career Connect platform. You can login and start managing the system.'
          : `You can now login to your ${userType} account and start using ACC Career Connect.`)
      : 'If you believe this is an error or would like to reapply, please contact our support team.';

    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Account ${actionText}</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5; }
          .container { max-width: 600px; margin: 0 auto; background-color: white; }
          .header { background-color: ${actionColor}; color: white; padding: 30px; text-align: center; }
          .content { padding: 30px; }
          .status-badge { 
            display: inline-block; 
            padding: 8px 16px; 
            background-color: ${actionColor}; 
            color: white; 
            border-radius: 20px; 
            font-weight: bold; 
            font-size: 12px; 
            text-transform: uppercase; 
            margin-bottom: 20px;
          }
          .button { 
            display: inline-block; 
            padding: 12px 24px; 
            background-color: #3b82f6; 
            color: white; 
            text-decoration: none; 
            border-radius: 5px; 
            margin: 20px 0; 
          }
          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 14px; }
          .reason-box { 
            background-color: #fef2f2; 
            border: 1px solid #fecaca; 
            border-radius: 5px; 
            padding: 15px; 
            margin: 20px 0;
            color: #991b1b;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Account ${actionText}</h1>
            <p>ACC Career Connect</p>
          </div>
          
          <div class="content">
            <div class="status-badge">${actionText}</div>
            
            <h2>Hello,</h2>
            
            <p>${message}</p>
            
            ${!approved && reason ? `
              <div class="reason-box">
                <strong>Reason:</strong> ${reason}
              </div>
            ` : ''}
            
            <p><strong>Account Type:</strong> ${userType.charAt(0).toUpperCase() + userType.slice(1)}</p>
            <p><strong>Email:</strong> ${email}</p>
            
            <h3>What's Next?</h3>
            <p>${nextSteps}</p>
            
            ${approved ? `
              <a href="${process.env.FRONTEND_URL}/login" class="button">Login to Your Account</a>
            ` : ''}
            
            <p>If you have any questions, please don't hesitate to contact our support team.</p>
            
            <p>Best regards,<br>
            <strong>ACC Career Connect Team</strong></p>
          </div>
          
          <div class="footer">
            <p>© 2025 ACC Career Connect. All rights reserved.</p>
            <p>Asiatech College Career Platform</p>
          </div>
        </div>
      </body>
      </html>
    `;

    return await this.sendEmail({
      to: email,
      subject,
      html,
      type: 'general'
    });
  }

  async sendCompanyInvitation(params: {
    recipientEmail: string;
    recipientName: string;
    coordinatorName: string;
    coordinatorEmail: string;
    course: string;
    message: string;
    invitationToken: string;
    expirationDate: Date;
  }): Promise<boolean> {
    const subject = `Invitation to Join ACC Career Connect Platform - ${params.course}`;
    const registrationUrl = `${process.env.FRONTEND_URL}/register?token=${params.invitationToken}`;
    
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Company Invitation - ACC Career Connect</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }
          .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }
          .content { padding: 30px; }
          .message-box { background-color: #f8f9fa; border-left: 4px solid #007bff; padding: 20px; margin: 20px 0; }
          .coordinator-info { background-color: #e3f2fd; padding: 15px; border-radius: 8px; margin: 15px 0; }
          .button { 
            display: inline-block; 
            padding: 15px 30px; 
            background-color: #007bff; 
            color: white; 
            text-decoration: none; 
            border-radius: 5px; 
            margin: 20px 0; 
            font-weight: bold; 
          }
          .token-info { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 15px 0; }
          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #666; }
          .expiry-notice { background-color: #f8d7da; border: 1px solid #f1c2c2; padding: 10px; border-radius: 5px; margin: 15px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎓 ACC Career Connect</h1>
            <h2>Company Partnership Invitation</h2>
          </div>
          
          <div class="content">
            <h3>Dear ${params.recipientName},</h3>
            
            <p>You have been invited to join the ACC Career Connect platform as a company partner!</p>
            
            <div class="coordinator-info">
              <h4>📧 Invitation From:</h4>
              <p><strong>Coordinator:</strong> ${params.coordinatorName}</p>
              <p><strong>Email:</strong> ${params.coordinatorEmail}</p>
              <p><strong>Course/Department:</strong> ${params.course}</p>
            </div>
            
            <div class="message-box">
              <h4>💌 Personal Message:</h4>
              <p style="font-style: italic; line-height: 1.6;">"${params.message}"</p>
            </div>
            
            <h4>🚀 What You Can Do:</h4>
            <ul style="line-height: 1.8;">
              <li><strong>Post Job Opportunities:</strong> Share internship, part-time, and full-time positions</li>
              <li><strong>Access Talented Candidates:</strong> Connect with skilled students and alumni</li>
              <li><strong>Review Applications:</strong> Manage applications with our comprehensive tools</li>
              <li><strong>Build Your Team:</strong> Find the right talent for your company</li>
            </ul>
            
            <div class="token-info">
              <h4>🔑 Your Invitation Details:</h4>
              <p><strong>Invitation Token:</strong> <code>${params.invitationToken}</code></p>
              <p><strong>Invited Email:</strong> ${params.recipientEmail}</p>
              <p><em>You'll need this token during registration to verify your invitation.</em></p>
            </div>
            
            <div style="text-align: center;">
              <a href="${registrationUrl}" class="button">🎯 Join ACC Career Connect Now</a>
            </div>
            
            <div class="expiry-notice">
              <p><strong>⏰ Important:</strong> This invitation expires on <strong>${params.expirationDate.toLocaleDateString()}</strong>. Please register before this date.</p>
            </div>
            
            <h4>📋 How to Register:</h4>
            <ol style="line-height: 1.8;">
              <li>Click the registration button above</li>
              <li>Select "Company/Business Owner" during registration</li>
              <li>Use your invitation token: <strong>${params.invitationToken}</strong></li>
              <li>Complete your company profile</li>
              <li>Start posting jobs and finding talent!</li>
            </ol>
            
            <p>If you have any questions or need assistance, please don't hesitate to contact the coordinator directly at <a href="mailto:${params.coordinatorEmail}">${params.coordinatorEmail}</a>.</p>
            
            <p>We look forward to having you as a partner in connecting students with great career opportunities!</p>
            
            <p>Best regards,<br>
            <strong>ACC Career Connect Team</strong><br>
            <em>Asiatech College Career Platform</em></p>
          </div>
          
          <div class="footer">
            <p>© 2025 ACC Career Connect. All rights reserved.</p>
            <p>This invitation was sent by ${params.coordinatorName} (${params.coordinatorEmail})</p>
            <p>If you received this email by mistake, please ignore it.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    return await this.sendEmail({
      to: params.recipientEmail,
      subject,
      html,
      type: 'invitation'
    });
  }
}

export const emailService = new EmailService();
