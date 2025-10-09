interface EmailOptions {
    to: string;
    subject: string;
    html: string;
    type?: 'otp' | 'invitation' | 'application_status' | 'job_match' | 'general';
}
declare class EmailService {
    private transporter;
    constructor();
    sendEmail(options: EmailOptions): Promise<boolean>;
    private logEmail;
    sendOTP(email: string, otp: string, purpose?: string): Promise<boolean>;
    sendWelcomeEmail(email: string, firstName: string, role: string): Promise<boolean>;
    sendInvitationEmail(email: string, inviterName: string, companyName: string, inviteLink: string): Promise<boolean>;
    sendApplicationStatusUpdate(email: string, jobTitle: string, companyName: string, status: string): Promise<boolean>;
    sendJobMatchNotification(email: string, jobTitle: string, companyName: string, matchScore: number): Promise<boolean>;
    private generateOTPTemplate;
    private generateWelcomeTemplate;
    private generateInvitationTemplate;
    private generateApplicationStatusTemplate;
    private generateJobMatchTemplate;
    sendApprovalEmail(email: string, userType: string, approved: boolean, reason?: string): Promise<boolean>;
    sendCompanyInvitation(params: {
        recipientEmail: string;
        recipientName: string;
        coordinatorName: string;
        coordinatorEmail: string;
        course: string;
        message: string;
        invitationToken: string;
        expirationDate: Date;
    }): Promise<boolean>;
}
export declare const emailService: EmailService;
export {};
//# sourceMappingURL=emailService.d.ts.map