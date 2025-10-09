export declare const hashPassword: (password: string) => Promise<string>;
export declare const comparePassword: (password: string, hashedPassword: string) => Promise<boolean>;
export declare const generateJWT: (payload: object) => string;
export declare const verifyJWT: (token: string) => any;
export declare const generateOTP: () => string;
export declare const generateToken: () => string;
export declare const validatePassword: (password: string) => {
    isValid: boolean;
    message?: string;
};
export declare const validateAsiatechEmail: (email: string) => boolean;
export declare const validateEmail: (email: string) => boolean;
//# sourceMappingURL=auth.d.ts.map