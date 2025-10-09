export declare class UploadService {
    private static uploadDir;
    static ensureUploadDir(): Promise<void>;
    static processAndSaveProfilePhoto(buffer: Buffer, userId: number, userType?: 'user' | 'coordinator' | 'company' | 'admin'): Promise<string>;
    static deleteProfilePhoto(photoPath: string): Promise<void>;
    static getPhotoUrl(photoPath: string | null): string | null;
}
//# sourceMappingURL=uploadService.d.ts.map